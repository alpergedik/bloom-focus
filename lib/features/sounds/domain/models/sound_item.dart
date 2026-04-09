import 'package:flutter/material.dart';

class SoundItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String assetPath;
  final double volume;
  final bool isPlaying;

  const SoundItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.assetPath,
    required this.volume,
    this.isPlaying = false,
  });

  SoundItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
    Color? color,
    String? assetPath,
    double? volume,
    bool? isPlaying,
  }) {
    return SoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      assetPath: assetPath ?? this.assetPath,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}