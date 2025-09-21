import 'package:flutter/material.dart';

class SlidingBanners extends StatefulWidget {
  final List<Widget> banners;
  final double height;
  final Duration autoSlideDuration;

  const SlidingBanners({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoSlideDuration = const Duration(seconds: 3),
  });

  @override
  State<SlidingBanners> createState() => _SlidingBannersState();
}

class _SlidingBannersState extends State<SlidingBanners> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    Future.delayed(widget.autoSlideDuration, _autoSlide);
  }

  void _autoSlide() {
    if (!mounted) return;
    int nextPage = (_currentPage + 1) % widget.banners.length;
    _controller.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _currentPage = nextPage;
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => widget.banners[index],
          ),
          Positioned(
            bottom: 8,
            child: Row(
              children: List.generate(
                widget.banners.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
