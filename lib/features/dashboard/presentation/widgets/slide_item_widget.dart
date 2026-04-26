import 'package:flutter/material.dart';
import '../../../live_controller/domain/slide.dart';

class SlideItemWidget extends StatelessWidget {
  final Slide slide;
  final bool isActive;
  final VoidCallback onTap;

  const SlideItemWidget({
    super.key,
    required this.slide,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: slide.isBlank ? 24 : 28,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            left: BorderSide(color: isActive ? Colors.blue : Colors.transparent, width: 3),
          ),
        ),
        child: slide.isBlank 
          ? Center(
              child: Text(
                "[ BLANK SCREEN ]",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            )
          : Row(
              children: [
                // Section 1: Title/Ref (Grey, small)
                SizedBox(
                  width: 150,
                  child: Text(
                    slide.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                // Section 2: Shortcut Tag
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getShortcutColor(slide.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: _getShortcutColor(slide.type).withOpacity(0.3)),
                  ),
                  child: Text(
                    slide.shortcut,
                    style: TextStyle(
                      color: _getShortcutColor(slide.type),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Section 3: Content Preview
                Expanded(
                  child: Text(
                    slide.content.replaceAll('\n', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Color _getShortcutColor(SlideType type) {
    switch (type) {
      case SlideType.chorus:
        return Colors.orangeAccent;
      case SlideType.bridge:
        return Colors.purpleAccent;
      case SlideType.verse:
        return Colors.blueAccent;
      case SlideType.blank:
        return Colors.grey;
      default:
        return Colors.tealAccent;
    }
  }
}
