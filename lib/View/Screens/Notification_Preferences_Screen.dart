import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final NotificationService _notificationService = NotificationService();
  
  bool _emailReminders = true;
  bool _pushNotifications = true;
  List<String> _reminderFrequency = ['7days', '3days', '1day'];
  String _preferredTime = '09:00';
  String _timezone = 'UTC';
  bool _isLoading = false;

  final List<String> _availableFrequencies = ['7days', '3days', '1day', 'expired'];
  final List<String> _timeOptions = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    
    try {
      final preferences = await _notificationService.getNotificationPreferences();
      if (preferences != null) {
        setState(() {
          _emailReminders = preferences['emailReminders'] ?? true;
          _pushNotifications = preferences['pushNotifications'] ?? true;
          _reminderFrequency = List<String>.from(preferences['reminderFrequency'] ?? ['7days', '3days', '1day']);
          _preferredTime = preferences['preferredTime'] ?? '09:00';
          _timezone = preferences['timezone'] ?? 'UTC';
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);
    
    try {
      await _notificationService.updateNotificationPreferences(
        emailReminders: _emailReminders,
        pushNotifications: _pushNotifications,
        reminderFrequency: _reminderFrequency,
        preferredTime: _preferredTime,
        timezone: _timezone,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: const Color(0xFF6F41F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A55F8), // Top blue
              Color(0xFF6F41F3), // Middle purple
              Color(0xFF8A2BE2), // Bottom violet
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Reminders Section
                      _buildSectionCard(
                        title: 'Email Reminders',
                        icon: Icons.email,
                        child: SwitchListTile(
                          title: const Text('Receive email reminders'),
                          subtitle: const Text('Get notified via email when your subscription is about to expire'),
                          value: _emailReminders,
                          onChanged: (value) {
                            setState(() => _emailReminders = value);
                          },
                          activeColor: const Color(0xFF6F41F3),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Push Notifications Section
                      _buildSectionCard(
                        title: 'Push Notifications',
                        icon: Icons.notifications,
                        child: SwitchListTile(
                          title: const Text('Receive push notifications'),
                          subtitle: const Text('Get notified on your device when your subscription is about to expire'),
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                          },
                          activeColor: const Color(0xFF6F41F3),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Reminder Frequency Section
                      _buildSectionCard(
                        title: 'Reminder Frequency',
                        icon: Icons.schedule,
                        child: Column(
                          children: _availableFrequencies.map((frequency) {
                            final isSelected = _reminderFrequency.contains(frequency);
                            final title = _getFrequencyTitle(frequency);
                            final subtitle = _getFrequencySubtitle(frequency);
                            
                            return CheckboxListTile(
                              title: Text(title),
                              subtitle: Text(subtitle),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _reminderFrequency.add(frequency);
                                  } else {
                                    _reminderFrequency.remove(frequency);
                                  }
                                });
                              },
                              activeColor: const Color(0xFF6F41F3),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Preferred Time Section
                      _buildSectionCard(
                        title: 'Preferred Time',
                        icon: Icons.access_time,
                        child: ListTile(
                          title: const Text('Notification Time'),
                          subtitle: Text('Receive notifications at $_preferredTime'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showTimePicker(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Timezone Section
                      _buildSectionCard(
                        title: 'Timezone',
                        icon: Icons.public,
                        child: ListTile(
                          title: const Text('Timezone'),
                          subtitle: Text(_timezone),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showTimezonePicker(),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePreferences,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F41F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Save Preferences'),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6F41F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6F41F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _getFrequencyTitle(String frequency) {
    switch (frequency) {
      case '7days':
        return '7 Days Before';
      case '3days':
        return '3 Days Before';
      case '1day':
        return '1 Day Before';
      case 'expired':
        return 'When Expired';
      default:
        return frequency;
    }
  }

  String _getFrequencySubtitle(String frequency) {
    switch (frequency) {
      case '7days':
        return 'Get reminded 7 days before expiry';
      case '3days':
        return 'Get reminded 3 days before expiry';
      case '1day':
        return 'Get reminded 1 day before expiry';
      case 'expired':
        return 'Get notified when subscription expires';
      default:
        return '';
    }
  }

  void _showTimePicker() {
    final timeParts = _preferredTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _preferredTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _showTimezonePicker() {
    final timezones = [
      'UTC', 'EST', 'PST', 'CST', 'MST', 'GMT', 'CET', 'JST', 'AEST'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Timezone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timezones.map((tz) => ListTile(
            title: Text(tz),
            selected: tz == _timezone,
            onTap: () {
              setState(() => _timezone = tz);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
