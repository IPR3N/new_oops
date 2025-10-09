import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'story_creation_page.dart';
import 'story_model.dart';

class StoryFeedPage extends StatefulWidget {
  final List<Story>? drafts;

  const StoryFeedPage({this.drafts});

  @override
  _StoryFeedPageState createState() => _StoryFeedPageState();
}

class _StoryFeedPageState extends State<StoryFeedPage> {
  List<Story> stories = [];
  List<Story> drafts = [];
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    stories.addAll(_generateSampleStories());
    if (widget.drafts != null) drafts.addAll(widget.drafts!);
    _pageController.addListener(() {
      if (_pageController.page != null && _pageController.page! % 1 == 0) {
        Vibration.vibrate(duration: 50);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Story> _generateSampleStories() {
    return [
      Story(
        id: "1",
        title: "Aventure Nocturne",
        // subtitle: "Sous les étoiles",
        author: "Alex",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        elements: [
          StoryElement(
            type: 'text',
            content: "Une nuit magique...",
            position: const Offset(20, 100),
            font: 'Pacifico',
            fontSize: 18,
            width: 275,
            height: 100,
            initialWidth: 275,
            initialHeight: 100,
            textColor: const Color(0xFFE0E7E9),
            backgroundColor: Colors.grey,
            backgroundOpacity: 0.5,
          ),
          StoryElement(
            type: 'image',
            content: "assets/stars.jpg",
            position: const Offset(20, 300),
            width: 275,
            height: 200,
            initialWidth: 275,
            initialHeight: 200,
          ),
        ],
        backgroundColor: const Color(0xFF0F1B2C),
        textColor: const Color(0xFFE0E7E9),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: stories.length,
                    itemBuilder: (context, index) => _buildStoryCard(stories[index]),
                  ),
                ),
              ],
            ),
            // Positioned(
            //   bottom: 90,
            //   right: 174,
            //   child: FloatingActionButton(
            //     backgroundColor: Colors.green,
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => StoryCreationPage(
            //           onStoryCreated: (story) => setState(() => stories.add(story)),
            //         ),
            //       ),
            //     ),
            Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.04),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryCreationPage(
                      onStoryCreated: (story) => setState(() => stories.add(story)),
                    ),
                  ),
                ),
                child: Image.asset(
                  'assets/images/icon-oops.3.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.black87, Colors.black54]),
      ),
      child: Center(
        child: Text(
          "Stories",
          style: GoogleFonts.pacifico(
            fontSize: 32,
            color: Colors.white,
            shadows: [const Shadow(color: Colors.green, blurRadius: 8)],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(Story story) {
    return Animate(
      effects: [FadeEffect(duration: 600.ms), ScaleEffect(duration: 400.ms)],
      child: Center(
        child: Container(
          width: StoryCreationPage.storyWidth,
          height: StoryCreationPage.storyHeight,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: story.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: Stack(
            children: [
              if (story.backgroundImagePath != null)
                Positioned.fill(child: Image.file(File(story.backgroundImagePath!), fit: BoxFit.cover)),
              ...story.elements.map((element) => _buildStoryElement(element, story)),
              _buildStoryHeader(story),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {
                        print("Liked story: ${story.title}");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white),
                      onPressed: () {
                        print("Commented on story: ${story.title}");
                      },
                    ),
                    const SizedBox(width: 60),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        print("Shared story: ${story.title}");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        print("Viewed story: ${story.title}");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryElement(StoryElement element, Story story) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: Transform.rotate(
        angle: (element.rotation ?? 0) * 3.14159 / 180,
        child: Opacity(
          opacity: element.opacity ?? 1.0,
          child: Container(
            width: element.width,
            height: element.height,
            decoration: BoxDecoration(
              color: element.type == 'text' ? (element.backgroundColor ?? Colors.grey).withOpacity(element.backgroundOpacity ?? 0.5) : null,
              border: element.borderEnabled == true ? Border.all(color: story.textColor, width: 2) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: element.type == 'text'
                ? Text(
                    element.content ?? "",
                    style: GoogleFonts.getFont(
                      element.font ?? 'Roboto',
                      fontSize: element.fontSize ?? 16,
                      color: element.textColor ?? story.textColor,
                    ),
                    textAlign: element.textAlignment == 'center'
                        ? TextAlign.center
                        : element.textAlignment == 'right'
                            ? TextAlign.right
                            : TextAlign.left,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(element.content!), fit: BoxFit.cover),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryHeader(Story story) {
    return Positioned(
      top: 16,
      left: 16,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contrainte du titre à 2 lignes maximum
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: StoryCreationPage.storyWidth - 100, // Laisse de l'espace pour l'icône et le padding
                ),
                child: Text(
                  story.title,
                  style: GoogleFonts.pacifico(
                    fontSize: 24,
                    color: story.textColor,
                  ),
                  maxLines: 2, // Maximum 2 lignes
                  overflow: TextOverflow.ellipsis, // Ajoute "..." si le texte est trop long
                ),
              ),
              if (story.subtitle != null && story.subtitle!.isNotEmpty)
                Text(
                  story.subtitle!,
                  style: GoogleFonts.lato(fontSize: 6, color: story.textColor.withOpacity(0.7)),
                ),
              Text(
                "Par ${story.author}",
                style: GoogleFonts.lato(fontSize: 10, color: story.textColor.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}