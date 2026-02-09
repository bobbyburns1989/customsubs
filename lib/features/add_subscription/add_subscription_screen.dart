import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custom_subs/core/constants/app_colors.dart';
import 'package:custom_subs/core/constants/app_sizes.dart';
import 'package:custom_subs/core/utils/haptic_utils.dart';
import 'package:custom_subs/core/utils/snackbar_utils.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:custom_subs/data/models/reminder_config.dart';
import 'package:custom_subs/features/add_subscription/add_subscription_controller.dart';
import 'package:custom_subs/features/add_subscription/models/subscription_form_state.dart';
import 'package:custom_subs/features/add_subscription/widgets/template_grid_item.dart';
import 'package:custom_subs/features/add_subscription/widgets/reminder_config_widget.dart';
import 'package:custom_subs/features/add_subscription/widgets/notes_section.dart';
import 'package:custom_subs/features/add_subscription/widgets/subscription_details_section.dart';
import 'package:custom_subs/features/add_subscription/widgets/trial_section.dart';
import 'package:custom_subs/features/add_subscription/widgets/cancellation_section.dart';
import 'package:custom_subs/features/home/home_controller.dart';
import 'package:custom_subs/data/services/template_service.dart';
import 'package:custom_subs/core/widgets/form_section_card.dart';
import 'package:custom_subs/core/widgets/skeleton_widgets.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const AddSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SubscriptionFormState _formState;

  String _currencyCode = 'USD';
  SubscriptionCycle _cycle = SubscriptionCycle.monthly;
  SubscriptionCategory _category = SubscriptionCategory.entertainment;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  DateTime _startDate = DateTime.now();
  int? _colorValue; // Will be auto-assigned or loaded from existing/template
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
    _formState = SubscriptionFormState();
    _loadExistingSubscription();
  }

  Future<void> _loadExistingSubscription() async {
    if (widget.subscriptionId != null) {
      final subscription =
          await ref.read(addSubscriptionControllerProvider(widget.subscriptionId).future);

      if (subscription != null && mounted) {
        setState(() {
          _formState.loadFromSubscription(subscription);
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
          _cancelChecklist = List.from(subscription.cancelChecklist);
          _showTemplates = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _formState.dispose();
    super.dispose();
  }

  Future<void> _selectTemplate(SubscriptionTemplate template) async {
    await HapticUtils.light(); // Template selection feedback
    setState(() {
      _formState.loadFromTemplate(template);
      _currencyCode = template.defaultCurrency;
      _cycle = template.defaultCycle;
      _category = template.category;
      _colorValue = template.color;
      _showTemplates = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_formState.validate()) {
      SnackBarUtils.show(
        context,
        SnackBarUtils.warning('Please enter valid data'),
      );
      return;
    }

    // Capture BuildContext and Navigator before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isEditing = widget.subscriptionId != null;

    try {
      // Auto-assign color if not already set (from template or existing subscription)
      final colorValue = _colorValue ?? await _getNextAutoColor();

      final controller =
          ref.read(addSubscriptionControllerProvider(widget.subscriptionId).notifier);

      final formData = _formState.toFormData();

      await controller.saveSubscription(
        name: formData.name,
        amount: formData.amount,
        currencyCode: _currencyCode,
        cycle: _cycle,
        nextBillingDate: _nextBillingDate,
        startDate: _startDate,
        category: _category,
        colorValue: colorValue,
        reminders: _reminders,
        isTrial: _isTrial,
        trialEndDate: _trialEndDate,
        postTrialAmount: _postTrialAmount,
        cancelUrl: formData.cancelUrl,
        cancelPhone: formData.cancelPhone,
        cancelNotes: formData.cancelNotes,
        cancelChecklist: _cancelChecklist,
        notes: formData.notes,
      );

      if (!mounted) return;

      await HapticUtils.medium(); // Save success feedback

      // Invalidate home controller to refresh the list
      ref.invalidate(homeControllerProvider);

      scaffoldMessenger.showSnackBar(
        SnackBarUtils.success(
          isEditing
              ? 'Subscription updated!'
              : 'Subscription added!',
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBarUtils.error('Error: $e'),
      );
    }
  }

  /// Auto-assigns a color by cycling through the color palette
  /// based on the current number of subscriptions
  Future<int> _getNextAutoColor() async {
    final subscriptions = await ref.read(homeControllerProvider.future);
    final subscriptionCount = subscriptions.length;
    final colorIndex = subscriptionCount % AppColors.subscriptionColors.length;
    return AppColors.subscriptionColors[colorIndex].toARGB32();
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
          onPressed: () async {
            await HapticUtils.light();
            if (context.mounted) {
              context.pop();
            }
          },
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
                controller: _formState.searchController,
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
                loading: () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: AppSizes.sm,
                    mainAxisSpacing: AppSizes.sm,
                  ),
                  itemCount: 8, // 8 skeleton items
                  itemBuilder: (context, index) => const SkeletonTemplateItem(),
                ),
                error: (_, __) => const Text('Error loading templates'),
              ),
              const SizedBox(height: AppSizes.md),

              // Create custom button
              OutlinedButton.icon(
                onPressed: () async {
                  await HapticUtils.light();
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
              SubscriptionDetailsSection(
                nameController: _formState.nameController,
                amountController: _formState.amountController,
                currencyCode: _currencyCode,
                cycle: _cycle,
                nextBillingDate: _nextBillingDate,
                category: _category,
                onCurrencyChanged: (value) => setState(() => _currencyCode = value),
                onCycleChanged: (value) => setState(() => _cycle = value),
                onNextBillingDateChanged: (value) => setState(() => _nextBillingDate = value),
                onCategoryChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: AppSizes.md),

              // Free Trial Card (collapsed by default)
              TrialSection(
                isTrial: _isTrial,
                trialEndDate: _trialEndDate,
                postTrialAmount: _postTrialAmount,
                onTrialChanged: (value) {
                  setState(() {
                    _isTrial = value;
                    if (!value) {
                      _trialEndDate = null;
                      _postTrialAmount = null;
                    }
                  });
                },
                onTrialEndDateChanged: (value) => setState(() => _trialEndDate = value),
                onPostTrialAmountChanged: (value) => setState(() => _postTrialAmount = value),
                onSetTrialEndDate: () {
                  setState(() {
                    _trialEndDate = DateTime.now().add(const Duration(days: 7));
                  });
                },
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
              CancellationSection(
                cancelUrlController: _formState.cancelUrlController,
                cancelPhoneController: _formState.cancelPhoneController,
                cancelNotesController: _formState.cancelNotesController,
                cancelChecklist: _cancelChecklist,
                onChecklistChanged: (newList) => setState(() => _cancelChecklist = newList),
              ),

              const SizedBox(height: AppSizes.md),

              // General Notes
              NotesSection(
                notesController: _formState.notesController,
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
