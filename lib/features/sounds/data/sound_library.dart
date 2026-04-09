import 'package:flutter/material.dart';
import '../domain/models/sound_item.dart';

class SoundLibrary {
  static const List<SoundItem> items = [
    SoundItem(
      id: 'rain',
      title: 'Gentle Rain',
      subtitle: 'Soft rainfall on leaves',
      icon: '🌧️',
      color: Color(0xFF3FA7D6),
      assetPath: 'sounds/rain.mp3',
      volume: 0.70,
    ),
    SoundItem(
      id: 'wind',
      title: 'Forest Wind',
      subtitle: 'A breeze through the trees',
      icon: '🍃',
      color: Color(0xFF69B578),
      assetPath: 'sounds/wind.mp3',
      volume: 0.55,
    ),
    SoundItem(
      id: 'birds',
      title: 'Morning Birds',
      subtitle: 'Calm forest morning ambience',
      icon: '🐦',
      color: Color(0xFFFFB84D),
      assetPath: 'sounds/birds.mp3',
      volume: 0.50,
    ),
    SoundItem(
      id: 'brook',
      title: 'Babbling Brook',
      subtitle: 'Clear water over stones',
      icon: '💧',
      color: Color(0xFF4CC9F0),
      assetPath: 'sounds/brook.mp3',
      volume: 0.65,
    ),
    SoundItem(
      id: 'fire',
      title: 'Crackling Fire',
      subtitle: 'Warm campfire ambience',
      icon: '🔥',
      color: Color(0xFFFF7A59),
      assetPath: 'sounds/fire.mp3',
      volume: 0.55,
    ),
  ];
}