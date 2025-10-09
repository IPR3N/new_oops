import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/notification_settings/notification_settings.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  bool _availability = true;
  bool _messageSent = true;
  bool _lowStock = false;
  bool _maturity = true;
  bool _start = true;
  bool _progress50 = false;
  bool _progress80 = true;
  bool _harvest = true;
  int _harvestDays = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _availability = true;
      _messageSent = true;
      _lowStock = false;
      _maturity = true;
      _start = true;
      _progress50 = false;
      _progress80 = true;
      _harvest = true;
      _harvestDays = 3;
    });
    final availability = await NotificationSettings.getAvailabilityNotification();
    final messageSent = await NotificationSettings.getMessageSentNotification();
    final lowStock = await NotificationSettings.getLowStockNotification();
    final maturity = await NotificationSettings.getMaturityNotification();
    final start = await NotificationSettings.getStartNotification();
    final progress50 = await NotificationSettings.getProgress50Notification();
    final progress80 = await NotificationSettings.getProgress80Notification();
    final harvest = await NotificationSettings.getHarvestNotification();
    final harvestDays = await NotificationSettings.getHarvestDays();
    setState(() {
      _availability = availability;
      _messageSent = messageSent;
      _lowStock = lowStock;
      _maturity = maturity;
      _start = start;
      _progress50 = progress50;
      _progress80 = progress80;
      _harvest = harvest;
      _harvestDays = harvestDays;
    });
  }

  Widget _buildNotificationIcon({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.grey[800] : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.grey[800] : Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Limiter à 2 lignes pour éviter débordement
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocales.getTranslation('notification_settings', locale),
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section "Manage Notifications"
            Text(
              AppLocales.getTranslation('manage_notifications', locale),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8, // Ajuster pour éviter que les éléments soient trop hauts
                children: [
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_project_start', locale),
                    icon: Icons.play_arrow,
                    isActive: _start,
                    onTap: () {
                      setState(() { _start = !_start; });
                      NotificationSettings.setStartNotification(_start);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_progress_50', locale),
                    icon: Icons.timeline,
                    isActive: _progress50,
                    onTap: () {
                      setState(() { _progress50 = !_progress50; });
                      NotificationSettings.setProgress50Notification(_progress50);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_progress_80', locale),
                    icon: Icons.timeline,
                    isActive: _progress80,
                    onTap: () {
                      setState(() { _progress80 = !_progress80; });
                      NotificationSettings.setProgress80Notification(_progress80);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_harvest', locale),
                    icon: Icons.agriculture,
                    isActive: _harvest,
                    onTap: () {
                      setState(() { _harvest = !_harvest; });
                      NotificationSettings.setHarvestNotification(_harvest);
                    },
                  ),
                ],
              ),
            ),
            if (_harvest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocales.getTranslation('harvest_days_before', locale),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    DropdownButton<int>(
                      value: _harvestDays,
                      items: List.generate(30, (index) => index + 1)
                          .map((days) => DropdownMenuItem<int>(
                                value: days,
                                child: Text(
                                  '$days ${AppLocales.getTranslation('days', locale)}',
                                  style: TextStyle(color: textColor),
                                ),
                              ))
                          .toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() { _harvestDays = newValue; });
                          NotificationSettings.setHarvestDays(newValue);
                        }
                      },
                      dropdownColor: isDarkMode ? Colors.grey[800] : white,
                      underline: Container(height: 1, color: green),
                    ),
                  ],
                ),
              ),

            // Section "Marketplace Notifications"
            const SizedBox(height: 24),
            Text(
              AppLocales.getTranslation('marketplace_notifications', locale),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8, // Ajuster pour éviter débordement
                children: [
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_availability', locale),
                    icon: Icons.notifications,
                    isActive: _availability,
                    onTap: () {
                      setState(() { _availability = !_availability; });
                      NotificationSettings.setAvailabilityNotification(_availability);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_message_sent', locale),
                    icon: Icons.message,
                    isActive: _messageSent,
                    onTap: () {
                      setState(() { _messageSent = !_messageSent; });
                      NotificationSettings.setMessageSentNotification(_messageSent);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_low_stock', locale),
                    icon: Icons.inventory,
                    isActive: _lowStock,
                    onTap: () {
                      setState(() { _lowStock = !_lowStock; });
                      NotificationSettings.setLowStockNotification(_lowStock);
                    },
                  ),
                  _buildNotificationIcon(
                    label: AppLocales.getTranslation('notify_maturity', locale),
                    icon: Icons.eco,
                    isActive: _maturity,
                    onTap: () {
                      setState(() { _maturity = !_maturity; });
                      NotificationSettings.setMaturityNotification(_maturity);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}