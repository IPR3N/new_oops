import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // Nouveau package
import 'story_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class StoryCreationPage extends StatefulWidget {
  final Function(Story) onStoryCreated;
  final Story? draft;

  static const double storyWidth = 320;
  static const double storyHeight = 700;

  const StoryCreationPage({required this.onStoryCreated, this.draft});

  @override
  _StoryCreationPageState createState() => _StoryCreationPageState();
}

class _StoryCreationPageState extends State<StoryCreationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  List<StoryElement> _elements = [];
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<String> _fonts = ['Roboto', 'Lato', 'Pacifico', 'Caveat', 'Montserrat', 'Open Sans', 'Lobster'];

  Color _backgroundColor = Colors.black;
  File? _backgroundImage;
  Color _textColor = Colors.green;

  final Map<String, Map<String, dynamic>> _themes = {
    'Sépia': {'background': const Color(0xFFF4E4BC), 'text': const Color(0xFF5C4033), 'accent': Colors.brown},
    'Océan Profond': {'background': const Color(0xFF001F3F), 'text': const Color(0xFF7FDBFF), 'accent': const Color(0xFF39CCCC)},
    'Désert Aride': {'background': const Color(0xFFD2B48C), 'text': const Color(0xFF8B4513), 'accent': const Color(0xFFCD853F)},
    'Aurore Boréale': {'background': const Color(0xFF0A2342), 'text': const Color(0xFFA8DADC), 'accent': const Color(0xFFE63946)},
    'Jardin Secret': {'background': const Color(0xFF4B5320), 'text': const Color(0xFFD4E6B5), 'accent': const Color(0xFFA2C523)},
    'Ciel Étoilé': {'background': const Color(0xFF0F1B2C), 'text': const Color(0xFFE0E7E9), 'accent': const Color(0xFF6C5B7B)},
    'Feu de Camp': {'background': const Color(0xFF2C1A1D), 'text': const Color(0xFFFFA07A), 'accent': const Color(0xFFD2691E)},
    'Lavande et Miel': {'background': const Color(0xFFE6E6FA), 'text': const Color(0xFF4B0082), 'accent': const Color(0xFFFFD700)},
    'Cascade Fraîche': {'background': const Color(0xFF006D77), 'text': const Color(0xFFE0F2F7), 'accent': const Color(0xFF83C5BE)},
  };

  String _selectedTheme = 'Sépia';
  int _selectedLayer = -1;
  bool _gridVisible = true;
  double _gridSize = 20.0;
  bool _snapToGrid = true;
  List<List<StoryElement>> _undoStack = [];
  List<List<StoryElement>> _redoStack = [];
  Offset _editMenuPosition = const Offset(16, 100);
  bool _isMenuManuallyMoved = false;

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      _titleController.text = widget.draft!.title;
      _subtitleController.text = widget.draft!.subtitle ?? '';
      _elements = widget.draft!.elements.map((e) => e.copyWith()).toList();
      _backgroundColor = widget.draft!.backgroundColor;
      _backgroundImage = widget.draft!.backgroundImagePath != null ? File(widget.draft!.backgroundImagePath!) : null;
      _textColor = widget.draft!.textColor;
    } else {
      _setTheme('Sépia');
    }
  }

  void _saveStateForUndo() {
    setState(() {
      _undoStack.add(_elements.map((e) => e.copyWith()).toList());
      _redoStack.clear();
    });
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _redoStack.add(_elements.map((e) => e.copyWith()).toList());
        _elements = _undoStack.removeLast();
        _selectedLayer = -1;
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _undoStack.add(_elements.map((e) => e.copyWith()).toList());
        _elements = _redoStack.removeLast();
        _selectedLayer = -1;
      });
    }
  }

  void _setTheme(String theme) {
    _saveStateForUndo();
    setState(() {
      _selectedTheme = theme;
      _backgroundColor = _themes[theme]!['background'] as Color;
      _textColor = _themes[theme]!['text'] as Color;
      _backgroundImage = null;
      for (var element in _elements) {
        if (element.type == 'text' && element.textColor == null) {
          element.textColor = _textColor;
        }
      }
    });
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _saveStateForUndo();
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

  void _addText({String alignment = 'left'}) {
    _saveStateForUndo();
    setState(() {
      _elements.add(StoryElement(
        type: 'text',
        content: '',
        position: const Offset(20, 100),
        font: 'Roboto',
        fontSize: 16.0,
        width: 270,
        height: 100,
        initialWidth: 300,
        initialHeight: 100,
        textColor: _textColor,
        textAlignment: alignment,
        rotation: 0,
        opacity: 1.0,
        layer: _elements.length,
        backgroundColor: Colors.grey,
        backgroundOpacity: 0.5,
        borderEnabled: false,
        borderColor: _textColor,
      ));
      _selectedLayer = _elements.length - 1;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _saveStateForUndo();
      setState(() {
        _elements.add(StoryElement(
          type: 'image',
          content: pickedFile.path,
          position: const Offset(30, 150),
          width: 200,
          height: 200,
          initialWidth: 200,
          initialHeight: 200,
          rotation: 0,
          opacity: 1.0,
          layer: _elements.length,
          borderEnabled: false,
          borderColor: _textColor,
        ));
        _selectedLayer = _elements.length - 1;
      });
    }
  }

  void _updateElement(int index, Offset delta, {double? widthDelta, double? heightDelta, bool proportional = false, double? rotationDelta}) {
    _saveStateForUndo();
    setState(() {
      final element = _elements[index];
      Offset newPosition = element.position;
      double newWidth = element.width ?? element.initialWidth;
      double newHeight = element.height ?? element.initialHeight;
      double newRotation = element.rotation ?? 0;

      if (delta != Offset.zero) {
        newPosition = Offset(
          _snapToGrid ? ((delta.dx + element.position.dx) / _gridSize).round() * _gridSize : (delta.dx + element.position.dx),
          _snapToGrid ? ((delta.dy + element.position.dy) / _gridSize).round() * _gridSize : (delta.dy + element.position.dy),
        );
        newPosition = Offset(
          newPosition.dx.clamp(0, StoryCreationPage.storyWidth - newWidth),
          newPosition.dy.clamp(0, StoryCreationPage.storyHeight - newHeight),
        );
      }

      if (widthDelta != null) {
        newWidth = (newWidth + widthDelta).clamp(50.0, StoryCreationPage.storyWidth);
        if (proportional) {
          double aspectRatio = element.initialWidth / element.initialHeight;
          newHeight = newWidth / aspectRatio;
        }
      }
      if (heightDelta != null) {
        newHeight = (newHeight + heightDelta).clamp(50.0, StoryCreationPage.storyHeight);
      }
      if (rotationDelta != null) {
        newRotation = (newRotation + rotationDelta) % 360;
      }

      _elements[index] = element.copyWith(
        position: newPosition,
        width: newWidth,
        height: newHeight,
        rotation: newRotation,
      );
    });
  }

  void _updateElementProperty(int index,
      {String? font,
      double? fontSize,
      Color? textColor,
      String? textAlignment,
      double? opacity,
      int? layer,
      Color? backgroundColor,
      double? backgroundOpacity,
      bool? borderEnabled,
      Color? borderColor}) {
    _saveStateForUndo();
    setState(() {
      _elements[index] = _elements[index].copyWith(
        font: font,
        fontSize: fontSize,
        textColor: textColor,
        textAlignment: textAlignment,
        opacity: opacity,
        layer: layer,
        backgroundColor: backgroundColor,
        backgroundOpacity: backgroundOpacity,
        borderEnabled: borderEnabled,
        borderColor: borderColor,
      );
      _elements.sort((a, b) => (a.layer ?? 0).compareTo(b.layer ?? 0));
    });
  }

  Future<void> _saveDraftAsImageAndStory() async {
    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la capture de l'image")));
        return;
      }

      // Utilisation de image_gallery_saver_plus
      final result = await ImageGallerySaverPlus.saveImage(imageBytes, name: "Story_${DateTime.now().millisecondsSinceEpoch}");
      if (!result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la sauvegarde de l'image")));
        return;
      }

      final draft = Story(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.isEmpty ? "Brouillon" : _titleController.text,
        subtitle: _subtitleController.text,
        author: "Créateur",
        timestamp: DateTime.now(),
        elements: _elements,
        backgroundColor: _backgroundColor,
        backgroundImagePath: result['filePath'] != null ? result['filePath'].toString().replaceFirst("file://", "") : null,
        textColor: _textColor,
        isDraft: true,
      );

      Navigator.pop(context, draft);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story sauvegardée en image et brouillon !")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur inattendue : $e")));
    }
  }

  void _showSaveOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sauvegarder"),
        content: const Text("Comment voulez-vous sauvegarder ?"),
        actions: [
          TextButton(
            onPressed: () async {
              final Uint8List? imageBytes = await _screenshotController.capture();
              if (imageBytes != null) {
                await ImageGallerySaverPlus.saveImage(imageBytes, name: "Story_${DateTime.now().millisecondsSinceEpoch}");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image sauvegardée !")));
              }
              Navigator.pop(context);
            },
            child: const Text("Image uniquement"),
          ),
          TextButton(
            onPressed: () {
              _saveDraftAsImageAndStory();
              Navigator.pop(context);
            },
            child: const Text("Brouillon éditable"),
          ),
        ],
      ),
    );
  }

  void _publishStory() {
    if (_titleController.text.isEmpty || _elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ajoute un titre et au moins un élément !")));
      return;
    }
    final newStory = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      author: "Créateur",
      timestamp: DateTime.now(),
      elements: _elements,
      backgroundColor: _backgroundColor,
      backgroundImagePath: _backgroundImage?.path,
      textColor: _textColor,
    );
    widget.onStoryCreated(newStory);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: StoryCreationPage.storyWidth,
                  height: StoryCreationPage.storyHeight,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Stack(
                    children: [
                      if (_backgroundImage != null) Positioned.fill(child: Image.file(_backgroundImage!, fit: BoxFit.cover)),
                      if (_gridVisible) CustomPaint(size: Size.infinite, painter: MagneticGridPainter(gridSize: _gridSize, textColor: _textColor)),
                      ..._elements.map((element) => _buildElement(element)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: _editMenuPosition.dx,
              top: _editMenuPosition.dy,
              child: _buildDraggableEditMenu(isLargeScreen: isLargeScreen, screenHeight: screenHeight),
            ),
            Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomToolbar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: TextField(
              controller: _titleController,
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Titre",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              maxLength: 40,
              maxLines: 1,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _showSaveOptions,
          ),
          ElevatedButton(
            onPressed: _publishStory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/icon-oops.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Publier",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableEditMenu({required bool isLargeScreen, required double screenHeight}) {
    final selectedElement = _selectedLayer >= 0 && _selectedLayer < _elements.length ? _elements[_selectedLayer] : null;
    final isText = selectedElement != null && selectedElement.type == 'text';
    final isImage = selectedElement != null && selectedElement.type == 'image';

    print('Building edit menu - Selected: $_selectedLayer, IsText: $isText, IsImage: $isImage');

    return Draggable(
      feedback: Material(
        child: _buildEditMenuContent(selectedElement, isText, isImage, isLargeScreen: isLargeScreen, screenHeight: screenHeight),
      ),
      childWhenDragging: Container(),
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _editMenuPosition = Offset(
            offset.dx.clamp(0, MediaQuery.of(context).size.width - 200),
            offset.dy.clamp(0, MediaQuery.of(context).size.height - 150),
          );
          _isMenuManuallyMoved = true;
          print('Menu manually moved to: $_editMenuPosition');
        });
      },
      child: _buildEditMenuContent(selectedElement, isText, isImage, isLargeScreen: isLargeScreen, screenHeight: screenHeight),
    );
  }

  Widget _buildEditMenuContent(StoryElement? selectedElement, bool isText, bool isImage, {required bool isLargeScreen, required double screenHeight}) {
    final List<Widget> editOptions = [
      IconButton(
        icon: const Icon(Icons.text_fields, color: Colors.white),
        onPressed: _addText,
      ),
      IconButton(
        icon: const Icon(Icons.image, color: Colors.white),
        onPressed: _pickImage,
      ),
      if (isText) ...[
        DropdownButton<String>(
          value: selectedElement!.font,
          items: _fonts.map((font) => DropdownMenuItem(value: font, child: Text(font, style: const TextStyle(color: Colors.white)))).toList(),
          onChanged: (value) => _updateElementProperty(_selectedLayer, font: value),
          dropdownColor: Colors.black87,
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: const Icon(Icons.format_size, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, fontSize: (selectedElement!.fontSize ?? 16) + 2),
        ),
        IconButton(
          icon: const Icon(Icons.text_decrease, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, fontSize: (selectedElement!.fontSize ?? 16) - 2),
        ),
        IconButton(
          icon: const Icon(Icons.format_align_left, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, textAlignment: 'left'),
        ),
        IconButton(
          icon: const Icon(Icons.format_align_center, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, textAlignment: 'center'),
        ),
        IconButton(
          icon: const Icon(Icons.format_align_right, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, textAlignment: 'right'),
        ),
        IconButton(
          icon: const Icon(Icons.color_lens, color: Colors.white),
          onPressed: () => _showColorPicker(context, selectedElement!.textColor ?? _textColor, (color) => _updateElementProperty(_selectedLayer, textColor: color)),
        ),
        IconButton(
          icon: const Icon(Icons.format_color_fill, color: Colors.white),
          onPressed: () => _showColorPicker(context, selectedElement!.backgroundColor ?? Colors.grey,
              (color) => _updateElementProperty(_selectedLayer, backgroundColor: color)),
        ),
        IconButton(
          icon: const Icon(Icons.opacity, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, backgroundOpacity: (selectedElement!.backgroundOpacity ?? 0.5) + 0.1 > 1.0
              ? 1.0
              : (selectedElement!.backgroundOpacity ?? 0.5) + 0.1),
        ),
        IconButton(
          icon: const Icon(Icons.opacity_outlined, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, backgroundOpacity: (selectedElement!.backgroundOpacity ?? 0.5) - 0.1 < 0.0
              ? 0.0
              : (selectedElement!.backgroundOpacity ?? 0.5) - 0.1),
        ),
        IconButton(
          icon: Icon(selectedElement!.borderEnabled ?? false ? Icons.border_clear : Icons.border_all, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, borderEnabled: !(selectedElement!.borderEnabled ?? false)),
        ),
        IconButton(
          icon: const Icon(Icons.border_color, color: Colors.white),
          onPressed: () => _showColorPicker(context, selectedElement!.borderColor ?? _textColor,
              (color) => _updateElementProperty(_selectedLayer, borderColor: color)),
        ),
      ],
      if (isImage) ...[
        IconButton(
          icon: const Icon(Icons.opacity, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, opacity: (selectedElement!.opacity ?? 1.0) - 0.1 < 0.0 ? 0.0 : (selectedElement!.opacity ?? 1.0) - 0.1),
        ),
        IconButton(
          icon: Icon(selectedElement!.borderEnabled ?? false ? Icons.border_clear : Icons.border_all, color: Colors.white),
          onPressed: () => _updateElementProperty(_selectedLayer, borderEnabled: !(selectedElement!.borderEnabled ?? false)),
        ),
        IconButton(
          icon: const Icon(Icons.border_color, color: Colors.white),
          onPressed: () => _showColorPicker(context, selectedElement!.borderColor ?? _textColor,
              (color) => _updateElementProperty(_selectedLayer, borderColor: color)),
        ),
      ],
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: selectedElement != null
            ? () {
                setState(() {
                  _elements.removeAt(_selectedLayer);
                  _selectedLayer = -1;
                });
              }
            : null,
      ),
    ];

    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: isLargeScreen
            ? _buildVerticalEditMenu(editOptions, screenHeight)
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: StoryCreationPage.storyWidth - 32,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: editOptions,
                ),
              ),
      ),
    );
  }

  Widget _buildVerticalEditMenu(List<Widget> options, double screenHeight) {
    const double iconSizeWithPadding = 56.0;
    final int maxItemsPerColumn = (screenHeight / iconSizeWithPadding).floor();
    final int totalItems = options.length;

    if (totalItems <= maxItemsPerColumn) {
      return Column(children: options);
    } else {
      final List<Widget> column1 = options.sublist(0, (totalItems / 2).ceil());
      final List<Widget> column2 = options.sublist((totalItems / 2).ceil());
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: column1),
          const SizedBox(width: 8),
          Column(children: column2),
        ],
      );
    }
  }

  void _showColorPicker(BuildContext context, Color initialColor, Function(Color) onColorSelected) {
    Color pickerColor = initialColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildElement(StoryElement element) {
    final index = _elements.indexOf(element);
    final isSelected = _selectedLayer == index;

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => _updateElement(index, details.delta),
        onTap: () {
          setState(() {
            print('Single tap on element $index, type: ${element.type}');
          });
        },
        onDoubleTap: () {
          setState(() {
            _selectedLayer = index;
            if (!_isMenuManuallyMoved) {
              final screenHeight = MediaQuery.of(context).size.height;
              final elementBottom = element.position.dy + (element.height ?? element.initialHeight);
              final menuHeightEstimate = 150.0;
              if (elementBottom + menuHeightEstimate > screenHeight - 100) {
                _editMenuPosition = Offset(_editMenuPosition.dx, element.position.dy - menuHeightEstimate);
              } else {
                _editMenuPosition = Offset(_editMenuPosition.dx, elementBottom + 10);
              }
            }
            print('Double tap on element $index, type: ${element.type}, menu at: $_editMenuPosition');
          });
        },
        child: Stack(
          children: [
            Transform.rotate(
              angle: (element.rotation ?? 0) * 3.14159 / 180,
              child: Opacity(
                opacity: element.opacity ?? 1.0,
                child: Container(
                  width: element.width,
                  height: element.height,
                  decoration: BoxDecoration(
                    color: element.type == 'text' ? (element.backgroundColor ?? Colors.grey).withOpacity(element.backgroundOpacity ?? 0.5) : null,
                    border: isSelected
                        ? Border.all(color: Colors.blueAccent, width: 3)
                        : (element.borderEnabled == true ? Border.all(color: element.borderColor ?? _textColor, width: 2) : null),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: element.type == 'text'
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: StoryCreationPage.storyWidth - 40,
                          ),
                          child: TextField(
                            onChanged: (value) => _elements[index].content = value,
                            style: GoogleFonts.getFont(
                              element.font ?? 'Roboto',
                              fontSize: element.fontSize ?? 16,
                              color: element.textColor ?? _textColor,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            textAlign: element.textAlignment == 'center'
                                ? TextAlign.center
                                : element.textAlignment == 'right'
                                    ? TextAlign.right
                                    : TextAlign.left,
                            maxLines: null,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(element.content!), fit: BoxFit.cover),
                        ),
                ),
              ),
            ),
            if (isSelected) ...[
              Positioned(
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => _updateElement(index, Offset.zero, widthDelta: details.delta.dx),
                  child: const Icon(Icons.arrow_right, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) => _updateElement(index, Offset.zero, heightDelta: details.delta.dy),
                  child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Animate(
      effects: const [SlideEffect(begin: Offset(0, 1), duration: Duration(milliseconds: 400))],
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.palette, color: Colors.white),
              onSelected: _setTheme,
              itemBuilder: (context) => _themes.keys.map((theme) => PopupMenuItem(value: theme, child: Text(theme, style: const TextStyle(color: Colors.white)))).toList(),
            ),
            IconButton(
              icon: Icon(_gridVisible ? Icons.grid_on : Icons.grid_off, color: Colors.white),
              onPressed: () => setState(() => _gridVisible = !_gridVisible),
            ),
            IconButton(
              icon: Icon(_snapToGrid ? Icons.lock : Icons.lock_open, color: Colors.white),
              onPressed: () => setState(() => _snapToGrid = !_snapToGrid),
            ),
            IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: _undo),
            IconButton(icon: const Icon(Icons.redo, color: Colors.white), onPressed: _redo),
          ],
        ),
      ),
    );
  }
}

class MagneticGridPainter extends CustomPainter {
  final double gridSize;
  final Color textColor;

  MagneticGridPainter({required this.gridSize, required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}