import 'dart:ui';

class Story {
  final String id;
  final String title;
  final String? subtitle;
  final String author;
  final DateTime timestamp;
  final List<StoryElement> elements;
  final Color backgroundColor;
  final String? backgroundImagePath;
  final Color textColor;
  final bool isDraft;

  Story({
    required this.id,
    required this.title,
    this.subtitle,
    required this.author,
    required this.timestamp,
    required this.elements,
    required this.backgroundColor,
    this.backgroundImagePath,
    required this.textColor,
    this.isDraft = false,
  });
}

class StoryElement {
  final String type;
  String? content;
  final Offset position;
  final String? font;
  final double? fontSize;
  final double initialWidth;
  final double initialHeight;
  final double? width;
  final double? height;
  Color? textColor;
  final String? textAlignment;
  final double? rotation;
  final double? opacity;
  final int? layer;
  final Color? backgroundColor;
  final double? backgroundOpacity;
  final bool? borderEnabled;
  Color? borderColor; // Nouvelle propriété pour la couleur du contour

  StoryElement({
    required this.type,
    this.content,
    required this.position,
    this.font,
    this.fontSize,
    required this.initialWidth,
    required this.initialHeight,
    this.width,
    this.height,
    this.textColor,
    this.textAlignment,
    this.rotation,
    this.opacity,
    this.layer,
    this.backgroundColor,
    this.backgroundOpacity,
    this.borderEnabled,
    this.borderColor, // Ajout dans le constructeur
  });

  StoryElement copyWith({
    String? type,
    String? content,
    Offset? position,
    String? font,
    double? fontSize,
    double? initialWidth,
    double? initialHeight,
    double? width,
    double? height,
    Color? textColor,
    String? textAlignment,
    double? rotation,
    double? opacity,
    int? layer,
    Color? backgroundColor,
    double? backgroundOpacity,
    bool? borderEnabled,
    Color? borderColor, // Ajout dans copyWith
  }) {
    return StoryElement(
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      initialWidth: initialWidth ?? this.initialWidth,
      initialHeight: initialHeight ?? this.initialHeight,
      width: width ?? this.width,
      height: height ?? this.height,
      textColor: textColor ?? this.textColor,
      textAlignment: textAlignment ?? this.textAlignment,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      layer: layer ?? this.layer,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      borderEnabled: borderEnabled ?? this.borderEnabled,
      borderColor: borderColor ?? this.borderColor, // Ajout dans la copie
    );
  }
}