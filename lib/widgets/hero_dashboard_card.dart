import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class HeroDashboardCard extends StatefulWidget {
  final String username;
  final double totalUang;
  final double totalBeras;
  final double fitrahUang;
  final double fitrahBeras;
  final double profesiUang;
  final double maalUang;
  final double fidyahUang;
  final int todayCount;

  const HeroDashboardCard({
    super.key,
    required this.username,
    required this.totalUang,
    required this.totalBeras,
    required this.fitrahUang,
    required this.fitrahBeras,
    required this.profesiUang,
    required this.maalUang,
    required this.fidyahUang,
    required this.todayCount,
  });

  @override
  State<HeroDashboardCard> createState() => _HeroDashboardCardState();
}

class _HeroDashboardCardState extends State<HeroDashboardCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCardSlide({
    required String title,
    required String valueUang,
    String? valueBeras,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Icon(
              icon,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assalamu\'alaikum,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.todayCount} Hari Ini',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueUang,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (valueBeras != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.rice_bowl_rounded,
                          color: AppColors.gold,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          valueBeras,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final slides = [
      _buildCardSlide(
        title: 'TOTAL SEMUA ZAKAT',
        valueUang: currencyFormat.format(widget.totalUang),
        valueBeras: 'Sembako Beras: ${widget.totalBeras.toStringAsFixed(1)} Kg',
        colors: [AppColors.emeraldDeep, AppColors.emerald],
        icon: Icons.account_balance_wallet_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT FITRAH',
        valueUang: currencyFormat.format(widget.fitrahUang),
        valueBeras: 'Beras Fitrah: ${widget.fitrahBeras.toStringAsFixed(1)} Kg',
        colors: [AppColors.emeraldDeep, Colors.teal.shade700],
        icon: Icons.rice_bowl_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT PROFESI',
        valueUang: currencyFormat.format(widget.profesiUang),
        colors: [AppColors.emeraldDeep, AppColors.orangeGold],
        icon: Icons.work_outline_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL ZAKAT MAAL',
        valueUang: currencyFormat.format(widget.maalUang),
        colors: [AppColors.emeraldDeep, AppColors.gold],
        icon: Icons.account_balance_rounded,
      ),
      _buildCardSlide(
        title: 'TOTAL DANA FIDYAH',
        valueUang: currencyFormat.format(widget.fidyahUang),
        colors: [AppColors.emeraldDeep, Colors.purple.shade700],
        icon: Icons.calendar_today_rounded,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: slides,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.emeraldDeep
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}