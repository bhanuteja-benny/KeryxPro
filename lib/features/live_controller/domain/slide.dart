enum SlideType { verse, chorus, bridge, tag, blank, other }

class Slide {
  final String title;      // Song Title or Bible Reference
  final String? displayTitle; // Display title header (e.g. using imported alias book name)
  final String shortcut;   // "V1", "C", "B"
  final String content;    // Full lyrics/verse text
  final SlideType type;
  final bool isBlank;
  final bool isSong;
  final bool isFavorite;
  final bool isDualVersion;
  final String? secondaryTitle;
  final String? secondaryDisplayTitle;
  final String? secondaryContent;
  final bool isEdited;
  final String? customReference;

  Slide({
    required this.title,
    this.displayTitle,
    required this.shortcut,
    required this.content,
    required this.type,
    this.isBlank = false,
    this.isSong = true,
    this.isFavorite = false,
    this.isDualVersion = false,
    this.secondaryTitle,
    this.secondaryDisplayTitle,
    this.secondaryContent,
    this.isEdited = false,
    this.customReference,
  });

  // Factory for blank slides
  factory Slide.blank({
    required String title,
    String? displayTitle,
    bool isSong = true,
    bool isFavorite = false,
    bool isEdited = false,
    String? customReference,
  }) {
    return Slide(
      title: title,
      displayTitle: displayTitle,
      shortcut: "BK", // Blank
      content: "",
      type: SlideType.blank,
      isBlank: true,
      isSong: isSong,
      isFavorite: isFavorite,
      isEdited: isEdited,
      customReference: customReference,
    );
  }
}
