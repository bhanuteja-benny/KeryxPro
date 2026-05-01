enum SlideType { verse, chorus, bridge, tag, blank, other }

class Slide {
  final String title;      // Song Title or Bible Reference
  final String shortcut;   // "V1", "C", "B"
  final String content;    // Full lyrics/verse text
  final SlideType type;
  final bool isBlank;
  final bool isSong;
  final bool isFavorite;

  Slide({
    required this.title,
    required this.shortcut,
    required this.content,
    required this.type,
    this.isBlank = false,
    this.isSong = true,
    this.isFavorite = false,
  });

  // Factory for blank slides
  factory Slide.blank({required String title, bool isSong = true, bool isFavorite = false}) {
    return Slide(
      title: title,
      shortcut: "BK", // Blank
      content: "",
      type: SlideType.blank,
      isBlank: true,
      isSong: isSong,
      isFavorite: isFavorite,
    );
  }
}
