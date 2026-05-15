import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/auth_service.dart';
import '../widgets/amil_track_logo.dart';
import '../widgets/soft_surface_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _idleController;

  int _currentIndex = 0;
  bool _isSigningIn = false;

  late final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Catat zakat lebih rapi dan cepat',
      description:
          'Setiap langkah dibuat singkat agar input, pengecekan, dan penyimpanan terasa ringan sejak awal.',
      illustrationIcon: Icons.auto_graph_rounded,
      illustrationTitle: 'Alur kerja singkat',
      illustrationSubtitle:
          'Cocok untuk pencatatan harian tanpa banyak langkah.',
      primaryActionLabel: 'Selanjutnya',
    ),
    _OnboardingSlide(
      title: 'Nisab dan riwayat tetap mudah diverifikasi',
      description:
          'Input uang dan beras dipisah, sehingga batas nisab dan riwayat transaksi bisa dibaca lebih jelas.',
      illustrationIcon: Icons.fact_check_rounded,
      illustrationTitle: 'Nisab transparan',
      illustrationSubtitle:
          'Uang dan beras tampil dengan penjelasan yang lebih tegas.',
      primaryActionLabel: 'Selanjutnya',
    ),
    _OnboardingSlide(
      title: 'Kwitansi bisa langsung dikirim ke WhatsApp',
      description:
          'Setelah zakat tersimpan, Anda dapat membagikan kwitansi ke WhatsApp tanpa keluar dari aplikasi.',
      illustrationIcon: Icons.receipt_long_rounded,
      illustrationTitle: 'Kwitansi siap dibagikan',
      illustrationSubtitle: 'Simpan lalu kirim bukti transaksi ke WhatsApp.',
      primaryActionLabel: 'Mulai dengan Google',
      isFinalSlide: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await AuthService.instance.signInWithGoogle();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal masuk: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.emeraldDeep,
        body: PageView.builder(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _slides.length,
          itemBuilder: (context, index) {
            final slide = _slides[index];
            return _OnboardingPage(
              slide: slide,
              currentIndex: index,
              totalCount: _slides.length,
              pageController: _pageController,
              idleController: _idleController,
              onPrimaryAction: slide.isFinalSlide ? _signInWithGoogle : _goNext,
              isSigningIn: _isSigningIn && slide.isFinalSlide,
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.slide,
    required this.currentIndex,
    required this.totalCount,
    required this.pageController,
    required this.idleController,
    required this.onPrimaryAction,
    required this.isSigningIn,
  });

  final _OnboardingSlide slide;
  final int currentIndex;
  final int totalCount;
  final PageController pageController;
  final Animation<double> idleController;
  final VoidCallback? onPrimaryAction;
  final bool isSigningIn;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pageController, idleController]),
      builder: (context, child) {
        final page = pageController.hasClients
            ? (pageController.page ?? currentIndex.toDouble())
            : currentIndex.toDouble();
        final delta = (page - currentIndex).abs().clamp(0.0, 1.0);
        final active = 1.0 - delta;
        final pulse = 1 + (idleController.value * 0.022 * active);
        final lift = 14 * active;
        final fade = 0.56 + (0.44 * active);

        return SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.75,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          color: AppColors.emeraldDeep,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: AppSpacing.md),
                                Transform.translate(
                                  offset: Offset(0, -2 * active),
                                  child: Transform.scale(
                                    scale: pulse,
                                    child: _GlassLogoBadge(
                                      size: 130,
                                      child: const AmilTrackLogo(
                                        size: 96,
                                        showTitle: false,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Transform.translate(
                                  offset: Offset(0, -lift * 0.08),
                                  child: Opacity(
                                    opacity: fade,
                                    child: _IllustrationCard(
                                      slide: slide,
                                      isFinalSlide: slide.isFinalSlide,
                                      activeFactor: active,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _BottomSheet(
                        slide: slide,
                        currentIndex: currentIndex,
                        totalCount: totalCount,
                        onPrimaryAction: onPrimaryAction,
                        isSigningIn: isSigningIn,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({
    required this.slide,
    required this.isFinalSlide,
    required this.activeFactor,
  });

  final _OnboardingSlide slide;
  final bool isFinalSlide;
  final double activeFactor;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      backgroundColor: AppColors.backgroundWhite,
      borderRadius: BorderRadius.circular(34),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GlassBadge(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                scale: 1 + (0.015 * activeFactor),
                child: isFinalSlide
                    ? const _ReceiptWhatsAppGlyph(size: 58)
                    : Icon(
                        slide.illustrationIcon,
                        size: 62,
                        color: AppColors.emerald,
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              slide.illustrationTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.emeraldDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              slide.illustrationSubtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.slide,
    required this.currentIndex,
    required this.totalCount,
    required this.onPrimaryAction,
    required this.isSigningIn,
  });

  final _OnboardingSlide slide;
  final int currentIndex;
  final int totalCount;
  final VoidCallback? onPrimaryAction;
  final bool isSigningIn;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      backgroundColor: AppColors.backgroundWhite,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: List.generate(totalCount, (index) {
                final isActive = index == currentIndex;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.only(
                      right: index == totalCount - 1 ? 0 : 8,
                    ),
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.emerald : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.emerald.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: isSigningIn ? null : onPrimaryAction,
              child: isSigningIn
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      key: ValueKey(slide.isFinalSlide),
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (slide.isFinalSlide) ...[
                          const _GoogleLogoMark(size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(slide.primaryActionLabel),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.illustrationIcon,
    required this.illustrationTitle,
    required this.illustrationSubtitle,
    required this.primaryActionLabel,
    this.isFinalSlide = false,
  });

  final String title;
  final String description;
  final IconData illustrationIcon;
  final String illustrationTitle;
  final String illustrationSubtitle;
  final String primaryActionLabel;
  final bool isFinalSlide;
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: 132,
          height: 132,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GlassLogoBadge extends StatelessWidget {
  const _GlassLogoBadge({required this.child, required this.size});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoMark extends StatelessWidget {
  const _GoogleLogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      paint.strokeWidth / 2,
      paint.strokeWidth / 2,
      size.width - paint.strokeWidth,
      size.height - paint.strokeWidth,
    );
    final center = Offset(size.width / 2, size.height / 2);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.2, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.0, 1.0, false, paint);

    paint.color = const Color(0xFFFABB05);
    canvas.drawArc(rect, 2.0, 0.9, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 2.9, 0.9, false, paint);

    final connector = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx + size.width * 0.02, center.dy),
      Offset(size.width * 0.84, center.dy),
      connector,
    );
    canvas.drawLine(
      Offset(size.width * 0.66, center.dy),
      Offset(size.width * 0.66, size.height * 0.54),
      connector,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReceiptWhatsAppGlyph extends StatelessWidget {
  const _ReceiptWhatsAppGlyph({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: size,
            color: AppColors.emerald,
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_rounded,
                size: 16,
                color: Color(0xFF25D366),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
