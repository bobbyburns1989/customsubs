library;

/// Currency formatting and conversion utilities.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility class for currency operations.
///
/// Provides functionality for:
/// - Loading bundled exchange rates from assets
/// - Converting between 30+ currencies
/// - Formatting amounts with proper symbols and decimal places
/// - Currency metadata (symbols, names, supported currencies)
///
/// Exchange rates are bundled in the app (no network calls) and loaded
/// once during app initialization. Rates are relative to USD as the base
/// currency.
///
/// Example:
/// ```dart
/// // Load rates (call once at app startup)
/// await CurrencyUtils.loadExchangeRates();
///
/// // Convert EUR to USD
/// final usdAmount = CurrencyUtils.convert(100.0, 'EUR', 'USD');
///
/// // Format as currency
/// final formatted = CurrencyUtils.formatAmount(19.99, 'USD'); // "$19.99"
/// ```
class CurrencyUtils {
  static Map<String, double>? _exchangeRates;

  /// Load exchange rates from bundled JSON
  static Future<void> loadExchangeRates() async {
    if (_exchangeRates != null) return;

    final jsonString = await rootBundle.loadString('assets/data/exchange_rates.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    // Base currency is USD (stored in JSON but not used in code)
    final rates = jsonData['rates'] as Map<String, dynamic>;

    _exchangeRates = rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  /// Convert amount from one currency to another
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (_exchangeRates == null) {
      throw Exception('Exchange rates not loaded. Call loadExchangeRates() first.');
    }

    if (fromCurrency == toCurrency) return amount;

    final fromRate = _exchangeRates![fromCurrency] ?? 1.0;
    final toRate = _exchangeRates![toCurrency] ?? 1.0;

    // Convert to base currency (USD) first, then to target currency
    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }

  /// Format amount as currency with symbol
  static String formatAmount(double amount, String currencyCode) {
    return NumberFormat.currency(
      symbol: getCurrencySymbol(currencyCode),
      decimalDigits: _getDecimalDigits(currencyCode),
    ).format(amount);
  }

  /// Format amount without currency symbol
  static String formatAmountWithoutSymbol(double amount, String currencyCode) {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: _getDecimalDigits(currencyCode),
    ).format(amount).trim();
  }

  /// Get currency symbol for a currency code
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      case 'CHF':
        return 'Fr';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'NZD':
        return 'NZ\$';
      case 'HKD':
        return 'HK\$';
      case 'SGD':
        return 'S\$';
      case 'MXN':
        return 'Mex\$';
      default:
        return currencyCode;
    }
  }

  /// Get decimal digits for currency formatting
  static int _getDecimalDigits(String currencyCode) {
    // Some currencies don't use decimal places
    switch (currencyCode) {
      case 'JPY':
      case 'KRW':
      case 'VND':
      case 'IDR':
        return 0;
      default:
        return 2;
    }
  }

  /// Get list of supported currencies
  static List<String> getSupportedCurrencies() {
    return [
      'USD',
      'EUR',
      'GBP',
      'CAD',
      'AUD',
      'JPY',
      'INR',
      'BRL',
      'MXN',
      'CHF',
      'CNY',
      'KRW',
      'SEK',
      'NOK',
      'DKK',
      'PLN',
      'CZK',
      'HUF',
      'TRY',
      'ZAR',
      'NZD',
      'SGD',
      'HKD',
      'THB',
      'MYR',
      'PHP',
      'IDR',
      'VND',
      'AED',
      'SAR',
      'NGN',
    ];
  }

  /// Get currency display name
  static String getCurrencyName(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'JPY':
        return 'Japanese Yen';
      case 'INR':
        return 'Indian Rupee';
      case 'BRL':
        return 'Brazilian Real';
      case 'MXN':
        return 'Mexican Peso';
      case 'CHF':
        return 'Swiss Franc';
      case 'CNY':
        return 'Chinese Yuan';
      case 'KRW':
        return 'South Korean Won';
      case 'SEK':
        return 'Swedish Krona';
      case 'NOK':
        return 'Norwegian Krone';
      case 'DKK':
        return 'Danish Krone';
      default:
        return currencyCode;
    }
  }
}
