library;

/// Service icon mapping for subscription templates.
///
/// Maps service names to Material Icons for visual identification.

import 'package:flutter/material.dart';

class ServiceIcons {
  /// Get icon for a service by name.
  ///
  /// Returns a Material Icon that best represents the service.
  /// Falls back to a generic icon if no specific mapping exists.
  static IconData getIconForService(String serviceName) {
    final name = serviceName.toLowerCase();

    // Streaming Services
    if (name.contains('netflix')) return Icons.movie;
    if (name.contains('spotify')) return Icons.music_note;
    if (name.contains('apple music')) return Icons.library_music;
    if (name.contains('youtube')) return Icons.play_circle_filled;
    if (name.contains('disney')) return Icons.castle;
    if (name.contains('hulu')) return Icons.tv;
    if (name.contains('hbo')) return Icons.live_tv;
    if (name.contains('amazon prime') || name.contains('prime video')) {
      return Icons.video_library;
    }
    if (name.contains('paramount')) return Icons.theaters;
    if (name.contains('peacock')) return Icons.ondemand_video;
    if (name.contains('apple tv')) return Icons.tv;

    // Cloud Storage
    if (name.contains('icloud')) return Icons.cloud;
    if (name.contains('google one') || name.contains('google drive')) {
      return Icons.cloud_upload;
    }
    if (name.contains('dropbox')) return Icons.cloud_queue;
    if (name.contains('onedrive')) return Icons.cloud_done;

    // Apple Services
    if (name.contains('apple one')) return Icons.apps;
    if (name.contains('apple arcade')) return Icons.sports_esports;
    if (name.contains('apple fitness')) return Icons.fitness_center;

    // Gaming
    if (name.contains('xbox')) return Icons.games;
    if (name.contains('playstation') || name.contains('ps plus')) {
      return Icons.sports_esports;
    }
    if (name.contains('nintendo')) return Icons.videogame_asset;
    if (name.contains('twitch')) return Icons.cast;
    if (name.contains('discord')) return Icons.forum;

    // Productivity
    if (name.contains('microsoft 365') || name.contains('office 365')) {
      return Icons.business_center;
    }
    if (name.contains('adobe')) return Icons.design_services;
    if (name.contains('canva')) return Icons.palette;
    if (name.contains('notion')) return Icons.note;
    if (name.contains('evernote')) return Icons.book;

    // News & Reading
    if (name.contains('new york times') || name.contains('nyt')) {
      return Icons.newspaper;
    }
    if (name.contains('washington post')) return Icons.article;
    if (name.contains('medium')) return Icons.edit;
    if (name.contains('audible')) return Icons.headphones;
    if (name.contains('kindle')) return Icons.menu_book;

    // Fitness & Health
    if (name.contains('peloton')) return Icons.directions_bike;
    if (name.contains('strava')) return Icons.directions_run;
    if (name.contains('myfitnesspal')) return Icons.restaurant;
    if (name.contains('headspace') || name.contains('calm')) {
      return Icons.self_improvement;
    }

    // Dating & Social
    if (name.contains('tinder') || name.contains('bumble') || name.contains('hinge')) {
      return Icons.favorite;
    }
    if (name.contains('linkedin')) return Icons.work;

    // Learning
    if (name.contains('duolingo')) return Icons.translate;
    if (name.contains('masterclass') || name.contains('coursera') || name.contains('udemy')) {
      return Icons.school;
    }

    // Food & Delivery
    if (name.contains('doordash') || name.contains('uber eats') || name.contains('grubhub')) {
      return Icons.delivery_dining;
    }
    if (name.contains('instacart')) return Icons.shopping_cart;

    // Communications
    if (name.contains('zoom')) return Icons.video_call;
    if (name.contains('slack')) return Icons.chat;

    // News & Magazines
    if (name.contains('economist')) return Icons.newspaper;
    if (name.contains('wall street')) return Icons.business;

    // Default fallback icon
    return Icons.subscriptions;
  }

  /// Check if a service has a custom icon mapping.
  static bool hasCustomIcon(String serviceName) {
    return getIconForService(serviceName) != Icons.subscriptions;
  }

  /// Get display letter for services without custom icons.
  ///
  /// Returns the first letter of the service name in uppercase.
  static String getDisplayLetter(String serviceName) {
    if (serviceName.isEmpty) return '?';
    return serviceName[0].toUpperCase();
  }
}
