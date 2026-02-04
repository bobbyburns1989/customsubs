import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:custom_subs/data/models/subscription_cycle.dart';
import 'package:custom_subs/data/models/subscription_category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'template_service.g.dart';

class SubscriptionTemplate {
  final String id;
  final String name;
  final double defaultAmount;
  final String defaultCurrency;
  final SubscriptionCycle defaultCycle;
  final SubscriptionCategory category;
  final String? cancelUrl;
  final int color;
  final String? iconName;

  SubscriptionTemplate({
    required this.id,
    required this.name,
    required this.defaultAmount,
    required this.defaultCurrency,
    required this.defaultCycle,
    required this.category,
    this.cancelUrl,
    required this.color,
    this.iconName,
  });

  factory SubscriptionTemplate.fromJson(Map<String, dynamic> json) {
    return SubscriptionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultAmount: (json['defaultAmount'] as num).toDouble(),
      defaultCurrency: json['defaultCurrency'] as String,
      defaultCycle: _parseCycle(json['defaultCycle'] as String),
      category: _parseCategory(json['category'] as String),
      cancelUrl: json['cancelUrl'] as String?,
      color: int.parse((json['color'] as String).substring(2), radix: 16),
      iconName: json['iconName'] as String?,
    );
  }

  static SubscriptionCycle _parseCycle(String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return SubscriptionCycle.weekly;
      case 'biweekly':
        return SubscriptionCycle.biweekly;
      case 'monthly':
        return SubscriptionCycle.monthly;
      case 'quarterly':
        return SubscriptionCycle.quarterly;
      case 'biannual':
        return SubscriptionCycle.biannual;
      case 'yearly':
        return SubscriptionCycle.yearly;
      default:
        return SubscriptionCycle.monthly;
    }
  }

  static SubscriptionCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return SubscriptionCategory.entertainment;
      case 'productivity':
        return SubscriptionCategory.productivity;
      case 'fitness':
        return SubscriptionCategory.fitness;
      case 'news':
        return SubscriptionCategory.news;
      case 'cloud':
        return SubscriptionCategory.cloud;
      case 'gaming':
        return SubscriptionCategory.gaming;
      case 'education':
        return SubscriptionCategory.education;
      case 'finance':
        return SubscriptionCategory.finance;
      case 'shopping':
        return SubscriptionCategory.shopping;
      case 'utilities':
        return SubscriptionCategory.utilities;
      case 'health':
        return SubscriptionCategory.health;
      default:
        return SubscriptionCategory.other;
    }
  }
}

class TemplateService {
  List<SubscriptionTemplate>? _templates;

  /// Load templates from bundled JSON
  Future<List<SubscriptionTemplate>> loadTemplates() async {
    if (_templates != null) return _templates!;

    final jsonString = await rootBundle.loadString('assets/data/subscription_templates.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _templates = jsonList
        .map((json) => SubscriptionTemplate.fromJson(json as Map<String, dynamic>))
        .toList();

    return _templates!;
  }

  /// Search templates by name
  Future<List<SubscriptionTemplate>> searchTemplates(String query) async {
    final templates = await loadTemplates();

    if (query.isEmpty) return templates;

    final lowerQuery = query.toLowerCase();
    return templates
        .where((template) => template.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get template by ID
  Future<SubscriptionTemplate?> getTemplateById(String id) async {
    final templates = await loadTemplates();
    try {
      return templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get templates by category
  Future<List<SubscriptionTemplate>> getTemplatesByCategory(
      SubscriptionCategory category) async {
    final templates = await loadTemplates();
    return templates.where((template) => template.category == category).toList();
  }
}

@riverpod
TemplateService templateService(TemplateServiceRef ref) {
  return TemplateService();
}

@riverpod
Future<List<SubscriptionTemplate>> subscriptionTemplates(
    SubscriptionTemplatesRef ref) async {
  final service = ref.watch(templateServiceProvider);
  return service.loadTemplates();
}
