# Multi-Currency Support Guide

**Status**: ✅ Complete
**Last Updated**: February 4, 2026
**Relevant to**: Developers

**Complete guide to implementing and using multi-currency features in CustomSubs.**

This guide covers currency conversion, formatting, display patterns, and best practices for handling subscriptions in different currencies.

---

## Table of Contents

1. [Overview](#overview)
2. [Currency System Architecture](#currency-system-architecture)
3. [Using CurrencyUtils](#using-currencyutils)
4. [Display Patterns](#display-patterns)
5. [Conversion Strategy](#conversion-strategy)
6. [Supported Currencies](#supported-currencies)
7. [Best Practices](#best-practices)

---

## Overview

### How Multi-Currency Works in CustomSubs

**Key principles:**
1. **Each subscription stores its native currency** - No forced conversion
2. **Bundled exchange rates** - No network calls, offline-first
3. **Display in native currency** - Show what users actually pay
4. **Convert for totals** - Aggregate spending in user's primary currency
5. **Approximate rates** - Users understand rates aren't real-time

**Example scenario:**
```
User's primary currency: USD

Subscriptions:
- Netflix: $15.99 USD (native)
- Spotify: €9.99 EUR (native)
- BBC iPlayer: £6.99 GBP (native)

Monthly total display:
"≈ $32.50/month" (converted to USD at bundled rates)
```

---

## Currency System Architecture

### Components

```
CurrencyUtils (lib/core/utils/currency_utils.dart)
    ↓
Exchange Rates JSON (assets/data/exchange_rates.json)
    ↓
Subscription Model (stores currencyCode per subscription)
    ↓
Display Layer (shows native or converted amounts)
```

### Exchange Rates JSON Format

**Location:** `assets/data/exchange_rates.json`

```json
{
  "baseCurrency": "USD",
  "lastUpdated": "2024-01-15",
  "rates": {
    "USD": 1.0,
    "EUR": 0.85,
    "GBP": 0.73,
    "JPY": 110.0,
    "CAD": 1.25,
    "AUD": 1.35,
    ...
  }
}
```

**Key points:**
- All rates relative to USD (base currency)
- Updated monthly via app releases
- ~30 currencies supported
- Stored as asset (bundled with app)

### Initialization

**Load rates at app startup:**

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load exchange rates BEFORE runApp
  await CurrencyUtils.loadExchangeRates();

  // ... other initialization

  runApp(MyApp());
}
```

**Why before runApp?**
- Ensures rates available immediately
- No null checks needed in widgets
- Fast synchronous access after load

---

## Using CurrencyUtils

### Loading Exchange Rates

```dart
import 'package:custom_subs/core/utils/currency_utils.dart';

// Load once at app startup
await CurrencyUtils.loadExchangeRates();
```

**Important:** Call this in `main()` before `runApp()`. Throws exception if not loaded when conversion is attempted.

### Converting Between Currencies

```dart
// Convert 100 EUR to USD
final usdAmount = CurrencyUtils.convert(
  100.0,    // amount
  'EUR',    // from currency
  'USD',    // to currency
);
// Result: ~117.65 (depends on bundled rate)

// Same currency returns original amount
final same = CurrencyUtils.convert(50.0, 'USD', 'USD');
// Result: 50.0
```

**How conversion works:**
```
Amount in EUR
    ↓
Convert to USD (base currency)
    = amount / EUR rate
    ↓
Convert to target currency
    = amountInUSD * target rate
```

**Example calculation:**
```
100 EUR to GBP:
1. 100 / 0.85 = 117.65 USD
2. 117.65 * 0.73 = 85.88 GBP
```

### Formatting Amounts

**With currency symbol:**
```dart
final formatted = CurrencyUtils.formatAmount(15.99, 'USD');
// Result: "$15.99"

final formatted = CurrencyUtils.formatAmount(9.99, 'EUR');
// Result: "€9.99"

final formatted = CurrencyUtils.formatAmount(1500, 'JPY');
// Result: "¥1,500" (no decimals for JPY)
```

**Without currency symbol:**
```dart
final formatted = CurrencyUtils.formatAmountWithoutSymbol(15.99, 'USD');
// Result: "15.99"
```

**Get currency symbol only:**
```dart
final symbol = CurrencyUtils.getCurrencySymbol('USD');
// Result: "$"

final symbol = CurrencyUtils.getCurrencySymbol('EUR');
// Result: "€"

final symbol = CurrencyUtils.getCurrencySymbol('JPY');
// Result: "¥"
```

### Supported Currencies List

```dart
final supported = CurrencyUtils.supportedCurrencies;
// Returns: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', ...]

// Check if currency is supported
final isSupported = CurrencyUtils.isCurrencySupported('EUR');
// Result: true

final isSupported = CurrencyUtils.isCurrencySupported('XYZ');
// Result: false
```

---

## Display Patterns

### Pattern 1: Native Currency (Subscription Tiles)

**Always show what users actually pay:**

```dart
// In subscription list tile
Text(
  CurrencyUtils.formatAmount(
    subscription.amount,
    subscription.currencyCode,
  ),
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
)

// Examples:
// "$15.99" for USD
// "€9.99" for EUR
// "£6.99" for GBP
// "¥1,500" for JPY (no decimals)
```

**Why native currency?**
- Matches bank statements
- Matches service's pricing page
- Users recognize the amount
- No confusion about conversions

### Pattern 2: Converted Totals (Analytics, Summary Cards)

**Show aggregate spending in user's primary currency:**

```dart
// Calculate total in primary currency
double calculateTotalInPrimaryCurrency(
  List<Subscription> subscriptions,
  String primaryCurrency,
) {
  double total = 0.0;
  for (final sub in subscriptions) {
    final converted = CurrencyUtils.convert(
      sub.effectiveMonthlyAmount,
      sub.currencyCode,
      primaryCurrency,
    );
    total += converted;
  }
  return total;
}

// Display with "approximate" indicator
Text(
  '≈ ${CurrencyUtils.formatAmount(total, primaryCurrency)}/month',
  style: Theme.of(context).textTheme.displayMedium,
)
```

**Why "≈" symbol?**
- Indicates approximate conversion
- Manages user expectations
- Rates are bundled (not real-time)
- Conversion is for reference only

### Pattern 3: Multi-Currency Breakdown

**Show spending per currency before conversion:**

```dart
// Group subscriptions by currency
Map<String, double> getSpendingByCurrency(List<Subscription> subs) {
  final spending = <String, double>{};
  for (final sub in subs) {
    spending[sub.currencyCode] = (spending[sub.currencyCode] ?? 0.0) +
        sub.effectiveMonthlyAmount;
  }
  return spending;
}

// Display
final byCurrency = getSpendingByCurrency(subscriptions);
for (final entry in byCurrency.entries) {
  ListTile(
    title: Text(entry.key),  // "USD", "EUR", etc.
    trailing: Text(
      CurrencyUtils.formatAmount(entry.value, entry.key),
    ),
  ),
}
```

### Pattern 4: Detail View

**Show both native and converted (if different):**

```dart
// In SubscriptionDetailScreen
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Native amount (always show)
    Text(
      CurrencyUtils.formatAmount(
        subscription.amount,
        subscription.currencyCode,
      ),
      style: Theme.of(context).textTheme.displayMedium,
    ),

    // Converted amount (only if different currency)
    if (subscription.currencyCode != userPrimaryCurrency) ...[
      SizedBox(height: 4),
      Text(
        '≈ ${CurrencyUtils.formatAmount(
          CurrencyUtils.convert(
            subscription.amount,
            subscription.currencyCode,
            userPrimaryCurrency,
          ),
          userPrimaryCurrency,
        )} in $userPrimaryCurrency',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    ],
  ],
)
```

---

## Conversion Strategy

### When to Convert

**Convert:**
- ✅ Total spending calculations
- ✅ Analytics aggregations
- ✅ Budget comparisons
- ✅ Cross-currency comparisons

**Don't convert:**
- ❌ Individual subscription displays
- ❌ Form inputs
- ❌ Edit screens
- ❌ Anywhere user expects to see native amount

### Rounding Considerations

**For display:**
```dart
final converted = CurrencyUtils.convert(15.99, 'USD', 'EUR');
// Result: 13.5915 EUR

final formatted = CurrencyUtils.formatAmount(converted, 'EUR');
// Result: "€13.59" (automatically rounded for display)
```

**For calculations:**
```dart
// Don't round intermediate values
double total = 0.0;
for (final sub in subscriptions) {
  total += CurrencyUtils.convert(
    sub.amount,
    sub.currencyCode,
    'USD',
  );  // Keep full precision
}

// Only round for display
final formatted = CurrencyUtils.formatAmount(total, 'USD');
```

### Handling Unsupported Currencies

**Fallback to currency code:**
```dart
String formatSafely(double amount, String currencyCode) {
  try {
    return CurrencyUtils.formatAmount(amount, currencyCode);
  } catch (e) {
    // Currency not supported - show code instead of symbol
    return '$amount $currencyCode';
  }
}
```

**Warn user during selection:**
```dart
DropdownButtonFormField<String>(
  items: allCurrencyCodes.map((code) {
    final isSupported = CurrencyUtils.isCurrencySupported(code);
    return DropdownMenuItem(
      value: code,
      child: Row(
        children: [
          Text(code),
          if (!isSupported)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.warning_amber, size: 16),
            ),
        ],
      ),
    );
  }).toList(),
);
```

---

## Supported Currencies

### Full List (30+ currencies)

| Code | Name | Symbol | Decimals |
|------|------|--------|----------|
| USD | US Dollar | $ | 2 |
| EUR | Euro | € | 2 |
| GBP | British Pound | £ | 2 |
| JPY | Japanese Yen | ¥ | 0 |
| CAD | Canadian Dollar | C$ | 2 |
| AUD | Australian Dollar | A$ | 2 |
| CHF | Swiss Franc | CHF | 2 |
| CNY | Chinese Yuan | ¥ | 2 |
| INR | Indian Rupee | ₹ | 2 |
| KRW | South Korean Won | ₩ | 0 |
| BRL | Brazilian Real | R$ | 2 |
| MXN | Mexican Peso | $ | 2 |
| ZAR | South African Rand | R | 2 |
| SEK | Swedish Krona | kr | 2 |
| NOK | Norwegian Krone | kr | 2 |
| DKK | Danish Krone | kr | 2 |
| PLN | Polish Złoty | zł | 2 |
| THB | Thai Baht | ฿ | 2 |
| IDR | Indonesian Rupiah | Rp | 0 |
| HKD | Hong Kong Dollar | HK$ | 2 |
| SGD | Singapore Dollar | S$ | 2 |
| NZD | New Zealand Dollar | NZ$ | 2 |
| TRY | Turkish Lira | ₺ | 2 |
| AED | UAE Dirham | د.إ | 2 |
| SAR | Saudi Riyal | ﷼ | 2 |

**Note:** Some currencies have 0 decimal places (JPY, KRW, IDR) - no cents.

### Adding New Currencies

**Steps:**
1. Add rate to `assets/data/exchange_rates.json`
2. Add symbol to `CurrencyUtils.getCurrencySymbol()`
3. Update `supportedCurrencies` list if needed
4. Test conversion and formatting

---

## Best Practices

### 1. Always Show Native Currency on Individual Items

```dart
// ✅ CORRECT - User sees what they pay
Text(CurrencyUtils.formatAmount(sub.amount, sub.currencyCode))

// ❌ WRONG - Confusing converted amount
Text(CurrencyUtils.formatAmount(
  CurrencyUtils.convert(sub.amount, sub.currencyCode, 'USD'),
  'USD',
))
```

### 2. Use "≈" for Converted Totals

```dart
// ✅ CORRECT - Indicates approximation
Text('≈ ${CurrencyUtils.formatAmount(total, primaryCurrency)}/month')

// ❌ WRONG - Implies exactness
Text('${CurrencyUtils.formatAmount(total, primaryCurrency)}/month')
```

### 3. Load Exchange Rates Early

```dart
// ✅ CORRECT - Load in main() before runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyUtils.loadExchangeRates();
  runApp(MyApp());
}

// ❌ WRONG - Load on first use (can cause delays)
Widget build(BuildContext context) {
  CurrencyUtils.loadExchangeRates();  // Don't do this
  return /* ... */;
}
```

### 4. Don't Convert for Storage

```dart
// ✅ CORRECT - Store native currency
final subscription = Subscription(
  amount: 15.99,
  currencyCode: 'USD',  // Store as entered
);

// ❌ WRONG - Store converted (lossy, confusing)
final subscription = Subscription(
  amount: CurrencyUtils.convert(15.99, 'USD', primaryCurrency),
  currencyCode: primaryCurrency,  // Wrong!
);
```

### 5. Handle Zero-Decimal Currencies

```dart
// ✅ CORRECT - Respects currency decimal rules
CurrencyUtils.formatAmount(1500, 'JPY')  // "¥1,500" (no decimals)

// ❌ WRONG - Forces 2 decimals
NumberFormat.currency(symbol: '¥', decimalDigits: 2).format(1500)
// "¥1,500.00" (looks wrong for JPY)
```

### 6. Provide Currency Breakdown in Analytics

```dart
// ✅ CORRECT - Show both native and converted
Column(
  children: [
    Text('Total: ≈ $300.00 USD'),
    Divider(),
    Text('USD: $200.00'),
    Text('EUR: €85.00 (≈ $100.00)'),
  ],
)

// ❌ WRONG - Only show converted (loses detail)
Text('Total: $300.00')
```

### 7. Update Exchange Rates Monthly

**Process:**
1. Update `assets/data/exchange_rates.json` with current rates
2. Update `lastUpdated` field
3. Increment app version
4. Release update

**Display last update date:**
```dart
// In Settings screen
ListTile(
  title: Text('Exchange Rates'),
  subtitle: Text('Last updated: January 2024'),
  trailing: Text('Approximate'),
)
```

---

## User Communication

### Setting Expectations

**In Settings:**
```
Exchange Rates

Currency conversions use approximate bundled rates updated monthly.
For exact amounts, check your service's pricing page.

Last updated: January 2024
```

**In Analytics:**
```
Monthly Total: ≈ $274.50

Converted at approximate bundled rates.
Individual subscriptions show exact amounts in native currency.
```

### FAQ Responses

**Q: "Why don't conversions match my bank statement?"**
A: We use approximate exchange rates updated monthly. Your bank may use different rates with additional fees.

**Q: "Can I see real-time exchange rates?"**
A: No, CustomSubs works completely offline with bundled rates. This ensures the app works everywhere without internet.

**Q: "Why the ≈ symbol?"**
A: It indicates conversions are approximate. Your actual charges may differ slightly based on your bank's rates.

---

## Testing Multi-Currency Features

### Test Cases

1. **Single currency**
   - User has subscriptions all in USD
   - Total shows without ≈ symbol

2. **Multiple currencies**
   - User has USD, EUR, GBP subscriptions
   - Total shows with ≈ symbol
   - Breakdown shows each currency

3. **Zero-decimal currencies**
   - Add JPY subscription (¥1,500)
   - Verify no decimal places shown
   - Verify conversion works correctly

4. **Unsupported currency**
   - Add subscription with rare currency
   - Verify graceful fallback (show code)

5. **Primary currency change**
   - Change user's primary currency
   - Verify all totals recalculate
   - Verify individual subscriptions unchanged

---

## Quick Reference

| Task | Method |
|------|--------|
| Load rates | `await CurrencyUtils.loadExchangeRates()` |
| Convert | `CurrencyUtils.convert(amount, from, to)` |
| Format with symbol | `CurrencyUtils.formatAmount(amount, code)` |
| Get symbol | `CurrencyUtils.getCurrencySymbol(code)` |
| Check supported | `CurrencyUtils.isCurrencySupported(code)` |
| List supported | `CurrencyUtils.supportedCurrencies` |

---

## Summary

**Multi-currency implementation checklist:**

1. ✅ Load exchange rates in `main()` before `runApp()`
2. ✅ Store native currency per subscription
3. ✅ Display native currency on individual items
4. ✅ Convert only for totals and analytics
5. ✅ Show "≈" symbol for converted amounts
6. ✅ Handle zero-decimal currencies (JPY, KRW)
7. ✅ Provide currency breakdown in analytics
8. ✅ Update rates monthly via app releases
9. ✅ Set user expectations (approximate rates)
10. ✅ Test with multiple currencies and edge cases

**See also:**
- `lib/core/utils/currency_utils.dart` - Full implementation
- `assets/data/exchange_rates.json` - Exchange rates data
- `docs/architecture/overview.md` - Offline-first architecture
- ADR 003 - Why bundled rates vs live API
