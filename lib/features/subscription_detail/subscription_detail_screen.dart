import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Subscription Detail Screen - ID: $subscriptionId - TODO'),
      ),
    );
  }
}
