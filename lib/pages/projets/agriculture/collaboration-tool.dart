import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/membership/members.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/tasks/chatPage.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/tasks/tasks.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class ColloborationTool extends ConsumerStatefulWidget {
  final int id;
  final String nom;
  final String description;
  final String startDate;
  final String endDate;
  final int estimatedQuantityProduced;
  final int? basePrice;
  final Crop crop;
  final String imageUrl;
  final String? owner;
  final bool? isListedOnMarketplace;
  final List<Membership>
      memberships; // Changed from List<dynamic> to List<Membership>
  final List<Task>? tasks;

  const ColloborationTool({
    super.key,
    required this.nom,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.estimatedQuantityProduced,
    this.basePrice,
    required this.crop,
    required this.imageUrl,
    this.owner,
    this.isListedOnMarketplace,
    required this.memberships,
    this.tasks,
    required this.id,
  });

  @override
  ConsumerState<ColloborationTool> createState() =>
      _ColloborationToolState(); // Fixed override
}

class _ColloborationToolState extends ConsumerState<ColloborationTool> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocales.getTranslation('collaboration_tool', locale),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 70),
            _buildSectionTitle(
                AppLocales.getTranslation('collaborative_tools', locale)),
            const SizedBox(height: 16),
            _buildToolGrid(context, widget.tasks, widget.id, widget.nom,
                widget.memberships, locale),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: green,
        ),
      ),
    );
  }

  Widget _buildToolGrid(BuildContext context, List<Task>? tasks, int id,
      String nom, List<Membership> memberships, String locale) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 20,
      childAspectRatio: 0.8,
      children: [
        _buildToolTile(
          context,
          Icons.check_circle_outline,
          AppLocales.getTranslation('task_management', locale),
          AppLocales.getTranslation('track_assign_tasks', locale),
          Tasks(
            id: id,
            nom: nom,
            memberships: memberships,
            tasks: tasks ?? [],
          ),
        ),
        // _buildToolTile(
        //   context,
        //   Icons.chat_outlined,
        //   AppLocales.getTranslation('team_chat', locale),
        //   AppLocales.getTranslation('real_time_communication', locale),
        //   ChatPage(

        //   ),
        // ),
        _buildToolTile(
          context,
          Icons.note_add_outlined,
          AppLocales.getTranslation('shared_notes', locale),
          AppLocales.getTranslation('collaborate_notes', locale),
          Container(),
        ),
        _buildToolTile(
          context,
          Icons.group,
          AppLocales.getTranslation('team_memberships', locale),
          AppLocales.getTranslation('manage_team_memberships', locale),
          Memberships(
            id: id,
            nom: nom,
            memberships: memberships,
          ),
        ),
      ],
    );
  }

  Widget _buildToolTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget destinationPage,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : green;
    final textColorsmall = isDarkMode ? Colors.grey[700]! : Colors.grey[700]!;

    final cardColor = isDarkMode ? Colors.grey[900] : white;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final iconColor = isDarkMode ? Colors.green : black;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: green),
      ),
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => destinationPage,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: textColorsmall),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
