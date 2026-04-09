import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/sound_library.dart';
import '../domain/models/sound_item.dart';
import '../services/sounds_service.dart';

class SoundsPage extends StatefulWidget {
  const SoundsPage({super.key});

  @override
  State<SoundsPage> createState() => _SoundsPageState();
}

class _SoundsPageState extends State<SoundsPage> {
  late final SoundsService _soundsService;
  late List<SoundItem> _sounds;

  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPlayingCardIndex = 0;

  List<SoundItem> get _activeSounds =>
      _sounds.where((sound) => sound.isPlaying).toList();

  @override
  void initState() {
    super.initState();
    _soundsService = SoundsService();
    _sounds = List<SoundItem>.from(SoundLibrary.items);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _soundsService.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(String id) async {
    final index = _sounds.indexWhere((sound) => sound.id == id);
    if (index == -1) return;

    final sound = _sounds[index];

    if (sound.isPlaying) {
      await _soundsService.pause(id);

      setState(() {
        _sounds[index] = sound.copyWith(isPlaying: false);
      });
    } else {
      await _soundsService.play(
        id: sound.id,
        assetPath: sound.assetPath,
        volume: sound.volume,
      );

      setState(() {
        _sounds[index] = sound.copyWith(isPlaying: true);
      });

      final activeIndex = _activeSounds.indexWhere((item) => item.id == id);
      if (activeIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              activeIndex,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }

    if (_activeSounds.isEmpty) {
      setState(() {
        _currentPlayingCardIndex = 0;
      });
    } else if (_currentPlayingCardIndex >= _activeSounds.length) {
      setState(() {
        _currentPlayingCardIndex = _activeSounds.length - 1;
      });
    }
  }

  Future<void> _updateVolume(String id, double value) async {
    final index = _sounds.indexWhere((sound) => sound.id == id);
    if (index == -1) return;

    setState(() {
      _sounds[index] = _sounds[index].copyWith(volume: value);
    });

    await _soundsService.setVolume(id, value);
  }

  Future<void> _stopAll() async {
    await _soundsService.stopAll();

    setState(() {
      _sounds = _sounds
          .map((sound) => sound.copyWith(isPlaying: false))
          .toList();
      _currentPlayingCardIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSounds = _activeSounds;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F1),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE7F2E5),
              Color(0xFFF4F7F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _SoftBackgroundGlow(),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: _Header(
                        activeCount: activeSounds.length,
                        onStopAll: activeSounds.isEmpty ? null : _stopAll,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: activeSounds.isEmpty
                            ? const _IdleNowPlayingCard()
                            : SizedBox(
                                key: ValueKey(activeSounds.length),
                                height: activeSounds.length == 1 ? 118 : 138,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 118,
                                      child: PageView.builder(
                                        controller: _pageController,
                                        itemCount: activeSounds.length,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentPlayingCardIndex = index;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final sound = activeSounds[index];
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: _TopPlayingCard(
                                              sound: sound,
                                              onPause: () =>
                                                  _toggleSound(sound.id),
                                              onVolumeChanged: (value) =>
                                                  _updateVolume(
                                                sound.id,
                                                value,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (activeSounds.length > 1) ...[
                                      const SizedBox(height: 10),
                                      _PageDots(
                                        count: activeSounds.length,
                                        currentIndex:
                                            _currentPlayingCardIndex,
                                        activeColor: activeSounds[
                                                _currentPlayingCardIndex]
                                            .color,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: _sounds.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sound = _sounds[index];
                        return _SoundListCard(
                          sound: sound,
                          onToggle: () => _toggleSound(sound.id),
                          onVolumeChanged: (value) =>
                              _updateVolume(sound.id, value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.activeCount,
    required this.onStopAll,
  });

  final int activeCount;
  final VoidCallback? onStopAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AMBIENT',
          style: TextStyle(
            color: Color(0xFF9AAE9B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Nature Sounds',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF234E3E),
                ),
              ),
            ),
            if (activeCount > 0)
              TextButton(
                onPressed: onStopAll,
                child: const Text(
                  'Stop all',
                  style: TextStyle(
                    color: Color(0xFF5D8D76),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _IdleNowPlayingCard extends StatelessWidget {
  const _IdleNowPlayingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _IdleIcon(),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No sound playing',
                    style: TextStyle(
                      color: Color(0xFF274E3F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Select one or more sounds below',
                    style: TextStyle(
                      color: Color(0xFFA2B5A7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleIcon extends StatelessWidget {
  const _IdleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFE6EDE8),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: Color(0xFFA8B9AB),
          size: 22,
        ),
      ),
    );
  }
}

class _TopPlayingCard extends StatelessWidget {
  const _TopPlayingCard({
    required this.sound,
    required this.onPause,
    required this.onVolumeChanged,
  });

  final SoundItem sound;
  final VoidCallback onPause;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            sound.color,
            _darken(sound.color, 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: sound.color.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          children: [
            Row(
              children: [
                _EmojiIconBox(
                  emoji: sound.icon,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Now Playing',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sound.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onPause,
                  child: const _AnimatedEqualizerBadge(
                    color: Colors.white,
                    size: 22,
                    barColor: Colors.white,
                    backgroundOpacity: 0.14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.volume_off_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SoundSlider(
                    value: sound.volume,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    thumbColor: Colors.white,
                    onChanged: onVolumeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundListCard extends StatelessWidget {
  const _SoundListCard({
    required this.sound,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  final SoundItem sound;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    final isPlaying = sound.isPlaying;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPlaying
            ? sound.color.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isPlaying
              ? sound.color.withValues(alpha: 0.35)
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        child: Column(
          children: [
            Row(
              children: [
                _EmojiIconBox(
                  emoji: sound.icon,
                  backgroundColor: isPlaying
                      ? sound.color.withValues(alpha: 0.16)
                      : const Color(0xFFF0F4F1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound.title,
                        style: const TextStyle(
                          color: Color(0xFF2B5A49),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sound.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFA1B4A6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isPlaying
                      ? Container(
                          key: const ValueKey('playing'),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sound.color,
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onToggle,
                            child: _AnimatedEqualizerBadge(
                              color: sound.color,
                              size: 20,
                              barColor: Colors.white,
                              backgroundOpacity: 0.00,
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('paused'),
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF0F4F1),
                          ),
                          child: IconButton(
                            onPressed: onToggle,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF6C9B82),
                              size: 26,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (isPlaying) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.volume_off_rounded,
                    size: 17,
                    color: sound.color.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SoundSlider(
                      value: sound.volume,
                      activeColor: sound.color,
                      inactiveColor: sound.color.withValues(alpha: 0.15),
                      thumbColor: sound.color,
                      onChanged: onVolumeChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.volume_up_rounded,
                    size: 17,
                    color: sound.color.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SoundSlider extends StatelessWidget {
  const _SoundSlider({
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.onChanged,
  });

  final double value;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: activeColor,
        inactiveTrackColor: inactiveColor,
        thumbColor: thumbColor,
        overlayColor: activeColor.withValues(alpha: 0.18),
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 1,
        onChanged: onChanged,
      ),
    );
  }
}

class _EmojiIconBox extends StatelessWidget {
  const _EmojiIconBox({
    required this.emoji,
    required this.backgroundColor,
  });

  final String emoji;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: index == currentIndex ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? activeColor
                  : activeColor.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftBackgroundGlow extends StatelessWidget {
  const _SoftBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB7E2C3).withValues(alpha: 0.45),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -80,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDCECDD).withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEqualizerBadge extends StatelessWidget {
  const _AnimatedEqualizerBadge({
    required this.color,
    required this.size,
    required this.barColor,
    this.backgroundOpacity = 0.12,
  });

  final Color color;
  final double size;
  final Color barColor;
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: backgroundOpacity),
      ),
      alignment: Alignment.center,
      child: _EqualizerBars(
        color: barColor,
        size: size,
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars({
    required this.color,
    this.size = 20,
  });

  final Color color;
  final double size;

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(double min, double max, double phase) {
    final value = (phase + _controller.value) % 1.0;
    return lerpDouble(min, max, value) ?? min;
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size * 0.11;
    final spacing = widget.size * 0.08;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _EqBar(
                width: barWidth,
                height:
                    _barHeight(widget.size * 0.28, widget.size * 0.72, 0.10),
                color: widget.color,
              ),
              SizedBox(width: spacing),
              _EqBar(
                width: barWidth,
                height:
                    _barHeight(widget.size * 0.42, widget.size * 0.92, 0.45),
                color: widget.color,
              ),
              SizedBox(width: spacing),
              _EqBar(
                width: barWidth,
                height:
                    _barHeight(widget.size * 0.22, widget.size * 0.66, 0.75),
                color: widget.color,
              ),
              SizedBox(width: spacing),
              _EqBar(
                width: barWidth,
                height:
                    _barHeight(widget.size * 0.34, widget.size * 0.84, 0.25),
                color: widget.color,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EqBar extends StatelessWidget {
  const _EqBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeInOut,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return darker.toColor();
}