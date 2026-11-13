import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class MarketAsset {
  final String symbol;
  final double price;
  final double ema50;
  final double ema200;
  final double rsi;
  final String regime;
  final List<double> history;

  MarketAsset({
    required this.symbol,
    required this.price,
    required this.ema50,
    required this.ema200,
    required this.rsi,
    required this.regime,
    required this.history,
  });
}

class CurrencyRate {
  final String code;
  final String name;
  final String buying;
  final String selling;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.buying,
    required this.selling,
  });
}

class MarketService {
  // 1. Yahoo Finance Üzerinden Rejim Analizi (Orijinal Python Mantığı)
  static Future<MarketAsset?> analyzeSymbol(String symbol) async {
    try {
      final url = Uri.parse(
          'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=1y&interval=1d');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0'
      });

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final result = data['chart']['result'][0];
      final List<dynamic> rawCloses =
          result['indicators']['quote'][0]['close'];

      List<double> closes = rawCloses
          .where((element) => element != null)
          .map((e) => (e as num).toDouble())
          .toList();

      if (closes.length < 200) return null;

      double currentPrice = closes.last;
      double ema50 = _calculateEMA(closes, 50);
      double ema200 = _calculateEMA(closes, 200);
      double rsi = _calculateRSI(closes, 14);

      String regime;
      if (currentPrice > ema50 && ema50 > ema200 && rsi > 50) {
        regime = "GÜÇLÜ BOĞA (Strong Bull)";
      } else if (currentPrice > ema200 && rsi >= 45) {
        regime = "DENGELİ BOĞA (Balanced Bull)";
      } else if (currentPrice < ema50 && ema50 < ema200 && rsi < 45) {
        regime = "AYI PİYASASI (Bear Market)";
      } else {
        regime = "YATAY / KONSOLİDASYON";
      }

      return MarketAsset(
        symbol: symbol,
        price: currentPrice,
        ema50: ema50,
        ema200: ema200,
        rsi: rsi,
        regime: regime,
        history: closes.sublist(closes.length - 30),
      );
    } catch (e) {
      return null;
    }
  }

  static double _calculateEMA(List<double> prices, int period) {
    double multiplier = 2.0 / (period + 1);
    double ema = prices[0];
    for (int i = 1; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }
    return ema;
  }

  static double _calculateRSI(List<double> prices, int period) {
    if (prices.length <= period) return 50.0;
    double gains = 0.0;
    double losses = 0.0;

    for (int i = prices.length - period; i < prices.length; i++) {
      double diff = prices[i] - prices[i - 1];
      if (diff >= 0) {
        gains += diff;
      } else {
        losses -= diff;
      }
    }

    if (losses == 0) return 100.0;
    double rs = (gains / period) / (losses / period);
    return 100.0 - (100.0 / (1.0 + rs));
  }

  // 2. TCMB Günlük Kur Çekme (XML Parser)
  static Future<List<CurrencyRate>> fetchTCMBRates() async {
    try {
      final url = Uri.parse('https://www.tcmb.gov.tr/kurlar/today.xml');
      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
      final currencies = document.findAllElements('Currency');
      List<CurrencyRate> rates = [];

      for (var node in currencies) {
        String code = node.getAttribute('CurrencyCode') ?? '';
        if (['USD', 'EUR', 'GBP', 'CHF'].contains(code)) {
          rates.add(CurrencyRate(
            code: code,
            name: node.findElements('Isim').first.innerText,
            buying: node.findElements('ForexBuying').first.innerText,
            selling: node.findElements('ForexSelling').first.innerText,
          ));
        }
      }
      return rates;
    } catch (e) {
      return [];
    }
  }

  // 3. Harem Altın ve Kapalıçarşı Kurları
  static Future<List<CurrencyRate>> fetchHaremAltinRates() async {
    try {
      final url = Uri.parse('https://finans.truncgil.com/today.json');
      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final data = json.decode(utf8.decode(response.bodyBytes));
      List<CurrencyRate> goldRates = [];

      final items = {
        'gram-altin': 'Gram Altın (Has)',
        'ceyrek-altin': 'Çeyrek Altın',
        'yarim-altin': 'Yarım Altın',
        'tam-altin': 'Tam Altın',
        'ons': 'Ons Altın (\$)',
      };

      items.forEach((key, label) {
        if (data[key] != null) {
          goldRates.add(CurrencyRate(
            code: key.toUpperCase(),
            name: label,
            buying: data[key]['Alış'].toString(),
            selling: data[key]['Satış'].toString(),
          ));
        }
      });

      return goldRates;
    } catch (e) {
      return [];
    }
  }
}
