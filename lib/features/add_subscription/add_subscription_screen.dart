import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/currency_utils.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/features/add_subscription/add_subscription_controller.dart';
import 'package:custom_subs/features/add_subscription/widgets/template_grid_item.dart';
import 'package:custom_subs/features/add_subscription/widgets/color_picker_widget.dart';
import 'package:custom_subs/features/add_subscription/widgets/reminder_config_widget.dart';
import 'package:custom_subs/features/add_subscription/widgets/subscription_preview_card.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/data/services/template_service.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';
import 'package:custom_subs/core/widgets/styled_date_field.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const AddSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _cancelUrlController = TextEditingController();
  final _cancelPhoneController = TextEditingController();
  final _cancelNotesController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  String _currencyCode = 'USD';
  SubscriptionCycle _cycle = SubscriptionCycle.monthly;
  SubscriptionCategory _category = SubscriptionCategory.entertainment;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  DateTime _startDate = DateTime.now();
  int _colorValue = AppColors.subscriptionColors[0].toARGB32();
  ReminderConfig _reminders = ReminderConfig();

  bool _isTrial = false;
  DateTime? _trialEndDate;
  double? _postTrialAmount;

  List<String> _cancelChecklist = [];
  bool _showTemplates = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExistingSubscription();
  }

  Future<void> _loadExistingSubscription() async {
    if (widget.subscriptionId != null) {
      final subscription =
          await ref.read(addSubscriptionControllerProvider(widget.subscriptionId).future);

      if (subscription != null && mounted) {
        setState(() {
          _nameController.text = subscription.name;
          _amountController.text = subscription.amount.toString();
          _currencyCode = subscription.currencyCode;
          _cycle = subscription.cycle;
          _category = subscription.category;
          _nextBillingDate = subscription.nextBillingDate;
          _startDate = subscription.startDate;
          _colorValue = subscription.colorValue;
          _reminders = subscription.reminders;
          _isTrial = subscription.isTrial;
          _trialEndDate = subscription.trialEndDate;
          _postTrialAmount = subscription.postTrialAmount;
          _cancelUrlController.text = subscription.cancelUrl ?? '';
          _cancelPhoneController.text = subscription.cancelPhone ?? '';
          _cancelNotesController.text = subscription.cancelNotes ?? '';
          _notesController.text = subscription.notes ?? '';
          _cancelChecklist = List.from(subscription.cancelChecklist);
          _showTemplates = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _cancelUrlController.dispose();
    _cancelPhoneController.dispose();
    _cancelNotesController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectTemplate(SubscriptionTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _amountController.text = template.defaultAmount.toString();
      _currencyCode = template.defaultCurrency;
      _cycle = template.defaultCycle;
      _category = template.category;
      _colorValue = template.color;
      if (template.cancelUrl != null) {
        _cancelUrlController.text = template.cancelUrl!;
      }
      _showTemplates = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      final controller =
          ref.read(addSubscriptionControllerProvider(widget.subscriptionId).notifier);

      await controller.saveSubscription(
        name: name,
        amount: amount,
        currencyCode: _currencyCode,
        cycle: _cycle,
        nextBillingDate: _nextBillingDate,
        startDate: _startDate,
        category: _category,
        colorValue: _colorValue,
        reminders: _reminders,
        isTrial: _isTrial,
        trialEndDate: _trialEndDate,
        postTrialAmount: _postTrialAmount,
        cancelUrl: _cancelUrlController.text.trim().isEmpty
            ? null
            : _cancelUrlController.text.trim(),
        cancelPhone: _cancelPhoneController.text.trim().isEmpty
            ? null
            : _cancelPhoneController.text.trim(),
        cancelNotes: _cancelNotesController.text.trim().isEmpty
            ? null
            : _cancelNotesController.text.trim(),
        cancelChecklist: _cancelChecklist,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        // Invalidate home controller to refresh the list
        ref.invalidate(homeControllerProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.subscriptionId == null
                ? 'Subscription added!'
                : 'Subscription updated!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Builds the collapsed preview for the Appearance section
  /// Shows the selected color dot with "Tap to customize" text
  Widget _buildColorPreview() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(_colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Tap to customize',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templatesAsync = ref.watch(subscriptionTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subscriptionId == null
            ? 'Add Subscription'
            : 'Edit Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.base),
          children: [
            // Template Picker (only show when adding new)
            if (_showTemplates && widget.subscriptionId == null) ...[
              Text(
                'Choose from templates',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.sm),

              // Search bar
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search services...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: AppSizes.md),

              // Templates grid
              templatesAsync.when(
                data: (templates) {
                  final filteredTemplates = _searchQuery.isEmpty
                      ? templates
                      : templates
                          .where((t) =>
                              t.name.toLowerCase().contains(_searchQuery))
                          .toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: AppSizes.sm,
                      mainAxisSpacing: AppSizes.sm,
                    ),
                    itemCount: filteredTemplates.length,
                    itemBuilder: (context, index) {
                      return TemplateGridItem(
                        template: filteredTemplates[index],
                        onTap: () =>
                            _selectTemplate(filteredTemplates[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading templates'),
              ),
              const SizedBox(height: AppSizes.md),

              // Create custom button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showTemplates = false;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Custom'),
              ),
              const SizedBox(height: AppSizes.xl),
            ],

            // Main Form
            if (!_showTemplates || widget.subscriptionId != null) ...[
              // Subscription Details Card (always expanded - required fields)
              FormSectionCard(
                title: 'Subscription Details',
                icon: Icons.edit_outlined,
                isCollapsible: false,
                child: Column(
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Netflix, Spotify, etc.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}), // Refresh preview
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Amount and Currency
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount *',
                              hintText: '0.00',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Invalid amount';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}), // Refresh preview
                          ),
                        ),
                        const SizedBox(width: AppSizes.lg),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _currencyCode,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                            ),
                            items: CurrencyUtils.getSupportedCurrencies()
                                .map((code) => DropdownMenuItem(
                                      value: code,
                                      child: Text(code),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _currencyCode = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Billing Cycle
                    DropdownButtonFormField<SubscriptionCycle>(
                      value: _cycle,
                      decoration: const InputDecoration(
                        labelText: 'Billing Cycle *',
                      ),
                      items: SubscriptionCycle.values
                          .map((cycle) => DropdownMenuItem(
                                value: cycle,
                                child: Text(cycle.displayName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _cycle = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Next Billing Date (StyledDateField)
                    StyledDateField(
                      label: 'Next Billing Date *',
                      value: _nextBillingDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      onChanged: (date) {
                        setState(() {
                          _nextBillingDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Category
                    DropdownButtonFormField<SubscriptionCategory>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                      ),
                      items: SubscriptionCategory.values
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text('${cat.icon} ${cat.displayName}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Appearance Card (collapsed by default with color preview)
              FormSectionCard(
                title: 'Appearance',
                subtitle: 'Choose a color for your subscription',
                icon: Icons.palette_outlined,
                isCollapsible: true,
                initiallyExpanded: false,
                collapsedPreview: _buildColorPreview(),
                child: Column(
                  children: [
                    ColorPickerWidget(
                      selectedColorValue: _colorValue,
                      onColorSelected: (color) {
                        setState(() {
                          _colorValue = color;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    // Subscription Preview
                    SubscriptionPreviewCard(
                      name: _nameController.text,
                      amount: double.tryParse(_amountController.text),
                      currencyCode: _currencyCode,
                      cycle: _cycle,
                      colorValue: _colorValue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Free Trial Card (collapsed by default)
              FormSectionCard(
                title: 'Free Trial',
                subtitle: 'Track trial period and conversion date',
                icon: Icons.timer_outlined,
                isCollapsible: true,
                initiallyExpanded: false,
                child: Column(
                  children: [
                    // Trial Toggle
                    SwitchListTile(
                      title: const Text('This is a free trial'),
                      subtitle: const Text(
                          'Enable if subscription is currently in trial period'),
                      value: _isTrial,
                      onChanged: (value) {
                        setState(() {
                          _isTrial = value;
                          if (!value) {
                            _trialEndDate = null;
                            _postTrialAmount = null;
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),

                    // Trial Fields (animated)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isTrial
                          ? Column(
                              children: [
                                const SizedBox(height: AppSizes.md),
                                // Trial End Date
                                if (_trialEndDate != null)
                                  StyledDateField(
                                    label: 'Trial End Date',
                                    value: _trialEndDate!,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    onChanged: (date) {
                                      setState(() {
                                        _trialEndDate = date;
                                      });
                                    },
                                  )
                                else
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _trialEndDate = DateTime.now()
                                            .add(const Duration(days: 7));
                                      });
                                    },
                                    icon: const Icon(Icons.calendar_today),
                                    label: const Text('Set Trial End Date'),
                                  ),
                                const SizedBox(height: AppSizes.md),
                                // Post-Trial Amount
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Amount after trial',
                                    hintText: '0.00',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  initialValue: _postTrialAmount?.toString(),
                                  onChanged: (value) {
                                    _postTrialAmount = double.tryParse(value);
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Reminders Card (always visible - critical feature!)
              FormSectionCard(
                title: 'Reminders',
                subtitle: 'Get notified before each billing date',
                icon: Icons.notifications_outlined,
                isCollapsible: false,
                child: ReminderConfigWidget(
                  config: _reminders,
                  onChanged: (config) {
                    setState(() {
                      _reminders = config;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Cancellation Info Section
              FormSectionCard(
                title: 'Cancellation Info',
                subtitle: 'How to cancel this subscription',
                icon: Icons.exit_to_app_outlined,
                isCollapsible: true,
                initiallyExpanded: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cancelUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Cancellation URL',
                        hintText: 'https://...',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _cancelPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Cancellation Phone',
                        hintText: '+1 (555) 123-4567',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _cancelNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Cancellation Notes',
                        hintText: 'How to cancel...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Cancellation Checklist
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cancellation Steps',
                          style: theme.textTheme.titleSmall,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _cancelChecklist.add('');
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Step'),
                        ),
                      ],
                    ),
                    ..._cancelChecklist.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: entry.value,
                                decoration: InputDecoration(
                                  labelText: 'Step ${index + 1}',
                                  hintText: 'Enter step...',
                                ),
                                onChanged: (value) {
                                  _cancelChecklist[index] = value;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _cancelChecklist.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // General Notes
              FormSectionCard(
                title: 'Notes',
                subtitle: 'Add any additional notes',
                icon: Icons.note_outlined,
                isCollapsible: true,
                initiallyExpanded: false,
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'General Notes',
                    hintText: 'Add any additional notes...',
                  ),
                  maxLines: 4,
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // Save Button
              ElevatedButton(
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.base),
                  child: Text(
                    widget.subscriptionId == null
                        ? 'Add Subscription'
                        : 'Update Subscription',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
            ],
          ],
        ),
      ),
    );
  }
}
