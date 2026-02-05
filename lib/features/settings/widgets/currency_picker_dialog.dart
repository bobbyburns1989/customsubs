import 'package:flutter/material.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';

/// Currency picker dialog.
///
/// Shows a searchable list of all supported currencies with:
/// - Currency code (USD, EUR, etc.)
/// - Currency symbol ($, €, etc.)
/// - Currency name (US Dollar, Euro, etc.)
/// - Search functionality
///
/// ## Usage
/// ```dart
/// final selectedCurrency = await showDialog<String>(
///   context: context,
///   builder: (context) => CurrencyPickerDialog(
///     currentCurrency: 'USD',
///   ),
/// );
///
/// if (selectedCurrency != null) {
///   // Update currency
/// }
/// ```
class CurrencyPickerDialog extends StatefulWidget {
  final String currentCurrency;

  const CurrencyPickerDialog({
    super.key,
    required this.currentCurrency,
  });

  @override
  State<CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<CurrencyPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = CurrencyUtils.getSupportedCurrencies();
    _searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = CurrencyUtils.getSupportedCurrencies();
      } else {
        _filteredCurrencies = CurrencyUtils.getSupportedCurrencies()
            .where((code) {
          final name = CurrencyUtils.getCurrencyName(code).toLowerCase();
          final symbol = CurrencyUtils.getCurrencySymbol(code).toLowerCase();
          return code.toLowerCase().contains(query) ||
              name.contains(query) ||
              symbol.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Currency',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.base),
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search currencies...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.base,
                        vertical: AppSizes.sm,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Currency list
            Expanded(
              child: _filteredCurrencies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSizes.base),
                          Text(
                            'No currencies found',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final code = _filteredCurrencies[index];
                        final isSelected = code == widget.currentCurrency;

                        return _CurrencyTile(
                          code: code,
                          isSelected: isSelected,
                          onTap: () => Navigator.of(context).pop(code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Currency tile widget
class _CurrencyTile extends StatelessWidget {
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symbol = CurrencyUtils.getCurrencySymbol(code);
    final name = CurrencyUtils.getCurrencyName(code);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Center(
          child: Text(
            symbol,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        code,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
            )
          : null,
    );
  }
}
