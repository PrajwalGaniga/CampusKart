import 'package:flutter/material.dart';
import '../constants/api_constants.dart';

class AvatarPicker extends StatefulWidget {
  final String initialAvatar;
  final ValueChanged<String> onAvatarSelected;

  const AvatarPicker({
    super.key,
    this.initialAvatar = '2.jpg',
    required this.onAvatarSelected,
  });

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  late PageController _pageController;
  int _currentIndex = 1; // Default to '2.jpg' (index 1)
  
  final List<String> _avatars = [
    '1.jpg',
    '2.jpg',
    '3.jpg',
    '4.jpg',
    '5.jpg',
    '6.jpg',
    '7.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Find initial index
    _currentIndex = _avatars.indexOf(widget.initialAvatar);
    if (_currentIndex == -1) _currentIndex = 1;

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.4,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _avatars.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onAvatarSelected(_avatars[index]);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  } else {
                    // Fallback before dimensions are laid out
                    value = index == _currentIndex ? 1.0 : 0.7;
                  }

                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 100,
                      width: Curves.easeOut.transform(value) * 100,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (index == _currentIndex)
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('${ApiConstants.baseUrl}/static/avatars/${_avatars[index]}'),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Swipe to select avatar',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
