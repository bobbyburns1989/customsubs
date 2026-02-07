import 'package:custom_subs/data/models/subscription.dart';
import 'package:flutter/material.dart';

/// Temporary undo state cache with 5-second expiry
///
/// **Purpose:** Provides quick "undo" functionality for reversible user actions
/// with a 5-second window. After 5 seconds, cached data expires automatically.
///
/// **Supported Operations:**
/// 1. Subscription deletion - Restores full subscription + notifications
/// 2. Primary currency change - Reverts to previous currency setting
/// 3. Reminder time change - Reverts to previous default time
///
/// **Architecture:** Singleton pattern (matches NotificationService pattern in codebase)
///
/// **Usage:**
/// ```dart
/// // Cache before destructive action
/// final undoService = UndoService();
/// undoService.cacheDeletedSubscription(subscription);
///
/// // Later, in UNDO callback (within 5 seconds)
/// final cached = undoService.getDeletedSubscription();
/// if (cached != null) {
///   // Restore subscription
/// }
/// ```
///
/// **Design Decisions:**
/// - Simple memory cache (no persistence needed for temporary undo)
/// - 5-second TTL (user preference - quick restoration window)
/// - Singleton for global access without DI complexity
/// - Automatic expiry via timestamp checks
/// - Each operation has isolated cache slot (no conflicts)
class UndoService {
  // Singleton instance (private, accessed via factory)
  static final UndoService _instance = UndoService._();

  // Private constructor
  UndoService._();

  // Factory constructor returns singleton instance
  factory UndoService() => _instance;

  // --- SUBSCRIPTION DELETION UNDO ---
  // Stores deleted subscription for restoration
  Subscription? _deletedSubscription;
  DateTime? _deletedAt;

  // --- CURRENCY CHANGE UNDO ---
  // Stores previous currency code (e.g., "USD", "EUR")
  String? _previousCurrency;
  DateTime? _currencyChangedAt;

  // --- REMINDER TIME CHANGE UNDO ---
  // Stores previous default reminder time
  TimeOfDay? _previousReminderTime;
  DateTime? _reminderChangedAt;

  // ======================================================================
  // SUBSCRIPTION DELETION UNDO
  // ======================================================================

  /// Cache a subscription before deletion
  ///
  /// **Call this BEFORE** executing the delete operation so the full
  /// subscription object (with all fields, notifications config) is stored.
  ///
  /// **Example:**
  /// ```dart
  /// final undoService = UndoService();
  /// undoService.cacheDeletedSubscription(subscription);
  /// await repository.delete(subscription.id); // Now delete it
  /// ```
  void cacheDeletedSubscription(Subscription subscription) {
    _deletedSubscription = subscription;
    _deletedAt = DateTime.now();
  }

  /// Retrieve cached subscription if within 5-second window
  ///
  /// Returns `null` if:
  /// - No subscription was cached
  /// - More than 5 seconds have elapsed since deletion
  ///
  /// **Example:**
  /// ```dart
  /// final cached = undoService.getDeletedSubscription();
  /// if (cached != null) {
  ///   // Within 5-second window - restore subscription
  ///   await repository.upsert(cached);
  ///   await notificationService.scheduleNotificationsForSubscription(cached);
  /// } else {
  ///   // Expired - show message to user
  /// }
  /// ```
  Subscription? getDeletedSubscription() {
    if (_deletedSubscription != null && _deletedAt != null) {
      final elapsed = DateTime.now().difference(_deletedAt!);
      if (elapsed.inSeconds <= 5) {
        return _deletedSubscription; // Still within window
      }
    }
    // Expired - clear cache
    _clearDeletedSubscription();
    return null;
  }

  /// Internal: Clear subscription deletion cache
  void _clearDeletedSubscription() {
    _deletedSubscription = null;
    _deletedAt = null;
  }

  // ======================================================================
  // PRIMARY CURRENCY CHANGE UNDO
  // ======================================================================

  /// Cache previous currency before changing
  ///
  /// **Call this BEFORE** setting the new currency so the previous value
  /// can be restored if user taps UNDO.
  ///
  /// **Example:**
  /// ```dart
  /// final undoService = UndoService();
  /// undoService.cacheCurrencyChange(currentCurrency); // "USD"
  /// await settingsRepo.setPrimaryCurrency(newCurrency); // "EUR"
  /// ```
  void cacheCurrencyChange(String previousCurrency) {
    _previousCurrency = previousCurrency;
    _currencyChangedAt = DateTime.now();
  }

  /// Retrieve previous currency if within 5-second window
  ///
  /// Returns `null` if:
  /// - No currency change was cached
  /// - More than 5 seconds have elapsed
  ///
  /// **Example:**
  /// ```dart
  /// final previous = undoService.getPreviousCurrency();
  /// if (previous != null) {
  ///   // Within window - restore previous currency
  ///   await settingsRepo.setPrimaryCurrency(previous);
  /// }
  /// ```
  String? getPreviousCurrency() {
    if (_previousCurrency != null && _currencyChangedAt != null) {
      final elapsed = DateTime.now().difference(_currencyChangedAt!);
      if (elapsed.inSeconds <= 5) {
        return _previousCurrency; // Still within window
      }
    }
    // Expired - clear cache
    _clearCurrencyChange();
    return null;
  }

  /// Internal: Clear currency change cache
  void _clearCurrencyChange() {
    _previousCurrency = null;
    _currencyChangedAt = null;
  }

  // ======================================================================
  // REMINDER TIME CHANGE UNDO
  // ======================================================================

  /// Cache previous reminder time before changing
  ///
  /// **Call this BEFORE** setting the new default reminder time.
  ///
  /// **Example:**
  /// ```dart
  /// final undoService = UndoService();
  /// undoService.cacheReminderTimeChange(currentTime); // TimeOfDay(hour: 9, minute: 0)
  /// await settingsRepo.setDefaultReminderTime(newTime.hour, newTime.minute);
  /// ```
  void cacheReminderTimeChange(TimeOfDay previousTime) {
    _previousReminderTime = previousTime;
    _reminderChangedAt = DateTime.now();
  }

  /// Retrieve previous reminder time if within 5-second window
  ///
  /// Returns `null` if:
  /// - No time change was cached
  /// - More than 5 seconds have elapsed
  ///
  /// **Example:**
  /// ```dart
  /// final previous = undoService.getPreviousReminderTime();
  /// if (previous != null) {
  ///   // Within window - restore previous time
  ///   await settingsRepo.setDefaultReminderTime(previous.hour, previous.minute);
  /// }
  /// ```
  TimeOfDay? getPreviousReminderTime() {
    if (_previousReminderTime != null && _reminderChangedAt != null) {
      final elapsed = DateTime.now().difference(_reminderChangedAt!);
      if (elapsed.inSeconds <= 5) {
        return _previousReminderTime; // Still within window
      }
    }
    // Expired - clear cache
    _clearReminderTimeChange();
    return null;
  }

  /// Internal: Clear reminder time change cache
  void _clearReminderTimeChange() {
    _previousReminderTime = null;
    _reminderChangedAt = null;
  }

  // ======================================================================
  // UTILITY METHODS
  // ======================================================================

  /// Clear all undo caches
  ///
  /// Useful for:
  /// - App cleanup on logout (if auth is added later)
  /// - Testing scenarios
  /// - Explicit user action to clear undo history
  ///
  /// **Note:** Not typically needed since caches auto-expire after 5 seconds.
  void clearAll() {
    _clearDeletedSubscription();
    _clearCurrencyChange();
    _clearReminderTimeChange();
  }
}
