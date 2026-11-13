import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/market_service.dart';

void main() {
  runApp(const MarketRegimeApp());
}

class MarketRegimeApp extends StatefulWidget {
  const MarketRegimeApp({super.key});

  @override
  State<MarketRegimeApp> createState() => _MarketRegimeAppState();
}

class _MarketRegimeAppState extends State<MarketRegimeApp> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Market Regime Tracker',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E11),
        cardColor: const Color(0xFF151A21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0E11),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFA3),
          secondary: Color(0xFF00B8FF),
        ),
      ),
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF007A5E),
          secondary: Color(0xFF0066CC),
        ),
      ),
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<String> _symbols = ['TUPRS.IS', 'ASELS.IS', 'THYAO.IS', 'BTC-USD', 'GC=F', '^GSPC'];
  List<MarketAsset> _assets = [];
  List<CurrencyRate> _tcmbRates = [];
  List<CurrencyRate> _haremRates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSymbols = prefs.getStringList('tracked_symbols');
    if (savedSymbols != null && savedSymbols.isNotEmpty) {
      _symbols = savedSymbols;
    }
    await _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    setState(() => _isLoading = true);

    List<MarketAsset> loadedAssets = [];
    for (String sym in _symbols) {
      final asset = await MarketService.analyzeSymbol(sym);
      if (asset != null) loadedAssets.add(asset);
    }

    final tcmb = await MarketService.fetchTCMBRates();
    final harem = await MarketService.fetchHaremAltinRates();

    setState(() {
      _assets = loadedAssets;
      _tcmbRates = tcmb;
      _haremRates = harem;
      _isLoading = false;
    });
  }

  Future<void> _addSymbol(String newSymbol) async {
    String formatted = newSymbol.trim().toUpperCase();
    if (formatted.isEmpty || _symbols.contains(formatted)) return;

    setState(() {
      _symbols.add(formatted);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tracked_symbols', _symbols);
    _refreshAllData();
  }

  Future<void> _removeSymbol(String symbol) async {
    setState(() {
      _symbols.remove(symbol);
      _assets.removeWhere((item) => item.symbol == symbol);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tracked_symbols', _symbols);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildRegimeTab(),
      _buildRatesTab(),
      _buildSettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Regime Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Rejim Analizi'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'TCMB & Harem'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }

  Widget _buildRegimeTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        final isBull = asset.regime.contains('BOĞA');
        final statusColor = isBull
            ? const Color(0xFF00FFA3)
            : (asset.regime.contains('AYI') ? const Color(0xFFFF4D4D) : Colors.amber);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(asset.symbol, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(asset.price.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    asset.regime,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: asset.history
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: statusColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: statusColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EMA 50: ${asset.ema50.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    Text('EMA 200: ${asset.ema200.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    Text('RSI(14): ${asset.rsi.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatesTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text('TCMB Resmi Döviz Kurları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._tcmbRates.map((rate) => Card(
              child: ListTile(
                title: Text('${rate.code} - ${rate.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Alış: ${rate.buying} ₺  |  Satış: ${rate.selling} ₺'),
                trailing: const Icon(Icons.account_balance, color: Colors.blueAccent),
              ),
            )),
        const SizedBox(height: 20),
        const Text('Harem Altın / Piyasa Fiyatları', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._haremRates.map((rate) => Card(
              child: ListTile(
                title: Text(rate.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Alış: ${rate.buying}  |  Satış: ${rate.selling}'),
                trailing: const Icon(Icons.monetization_on, color: Colors.amber),
              ),
            )),
      ],
    );
  }

  Widget _buildSettingsTab() {
    final TextEditingController symbolController = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Koyu Tema (Dark Mode #0B0E11)'),
          subtitle: const Text('Orijinal terminal görünümü'),
          value: widget.isDarkMode,
          onChanged: widget.onThemeChanged,
        ),
        const Divider(height: 30),
        const Text('Takip Edilecek Sembol Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: symbolController,
                decoration: const InputDecoration(
                  hintText: 'Örn: EREGL.IS, ETH-USD, AAPL',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                _addSymbol(symbolController.text);
                symbolController.clear();
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Aktif Takip Listesi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._symbols.map((sym) => ListTile(
              title: Text(sym),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _removeSymbol(sym),
              ),
            )),
      ],
    );
  }
}
