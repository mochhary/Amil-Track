import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/app_watermark_background.dart'; 
import '../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _onboardingSteps = [
    {
      'title': 'Pencatatan Modern',
      'desc': 'Tinggalkan buku manual. Amil Track membantu Anda mengelola data muzakki dengan rapi, aman, dan terstruktur di cloud.',
      'icon': Icons.library_books_rounded,
    },
    {
      'title': 'Kalkulator BAZNAS',
      'desc': 'Tidak perlu bingung menghitung nisab. Sistem otomatis menghitung Zakat Profesi, Maal, dan Fitrah secara akurat.',
      'icon': Icons.calculate_rounded,
    },
    {
      'title': 'Kwitansi Instan',
      'desc': 'Kirim bukti penerimaan zakat yang sah langsung ke WhatsApp muzakki hanya dengan satu sentuhan.',
      'icon': Icons.phonelink_ring_rounded,
    },
    {
      'title': 'Siap Memulai?',
      'desc': 'Gunakan akun Google Anda untuk masuk. Data Anda akan disinkronisasikan dan tidak akan hilang meskipun berganti HP.',
      'icon': Icons.cloud_done_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal masuk: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _onboardingSteps.length - 1;

    return Scaffold(
      body: AppWatermarkBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER (LOGO & JARGON) ---
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bingkai Glassmorphism yang membungkus Logo Besar
                    GlassContainer(
                      padding: const EdgeInsets.all(6.0), // Padding super tipis sesuai request
                      borderRadius: 42.0, // Ditingkatkan agar serasi dengan ukuran baru
                      backgroundColor: Colors.white.withValues(alpha: 0.6), 
                      glassOpacity: 0.4,
                      blur: 24,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36.0), // Potongan squircle yang presisi
                        child: Image.asset(
                          'assets/images/logo_amil_track.png',
                          width: 165, // PERUBAHAN: Ukuran diperbesar signifikan
                          height: 165, // PERUBAHAN: Ukuran diperbesar signifikan
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 165,
                            height: 165,
                            color: AppColors.emerald.withValues(alpha: 0.1),
                            child: const Icon(Icons.mosque_rounded, size: 80, color: AppColors.emeraldDeep),
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 800.ms).scale(delay: 200.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 20),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Sahabat Cerdas Para Amil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emeraldDeep, 
                          letterSpacing: 0.5,
                          height: 1.3,
                        ),
                      ),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuart),
                  ],
                ),
              ),

              // --- BOTTOM GLASS CARD: CAROUSEL ---
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    glassOpacity: 0.5,
                    blur: 24,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemCount: _onboardingSteps.length,
                            itemBuilder: (context, index) {
                              final step = _onboardingSteps[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.emerald.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        step['icon'] as IconData,
                                        size: 48,
                                        color: AppColors.emeraldDeep,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      step['title'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.emeraldDeep,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      step['desc'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _onboardingSteps.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.emerald
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isLastPage
                                ? ElevatedButton(
                                    key: const ValueKey('btn_login'),
                                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      elevation: 2,
                                      shadowColor: Colors.black.withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24, height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  'G',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.red.shade700,
                                                    fontFamily: 'sans-serif',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              const Text(
                                                'Sign In with Google',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                  )
                                : ElevatedButton(
                                    key: const ValueKey('btn_next'),
                                    onPressed: _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Selanjutnya',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0, duration: 700.ms, curve: Curves.easeOutBack),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}