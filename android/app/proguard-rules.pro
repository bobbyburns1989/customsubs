# CustomSubs ProGuard Rules
# Required when isMinifyEnabled = true to prevent R8 from stripping
# reflection-dependent SDK classes.

# RevenueCat — uses reflection for purchase/entitlement deserialization
-keep class com.revenuecat.purchases.** { *; }

# PostHog — uses reflection for event serialization
-keep class com.posthog.** { *; }

# Flutter engine
-keep class io.flutter.** { *; }

# Preserve annotations used by both SDKs
-keepattributes *Annotation*
