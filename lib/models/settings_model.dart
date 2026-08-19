class SettingsModel {
  final bool messageNotification;
  final bool offerNotification;
  final bool jobNotification;
  final bool campaignNotification;
  final bool darkMode;

  SettingsModel({
    required this.messageNotification,
    required this.offerNotification,
    required this.jobNotification,
    required this.campaignNotification,
    required this.darkMode,
  });

  factory SettingsModel.fromMap(Map<String, dynamic>? map) {
    return SettingsModel(
      messageNotification: map?['messageNotification'] ?? true,
      offerNotification: map?['offerNotification'] ?? true,
      jobNotification: map?['jobNotification'] ?? true,
      campaignNotification: map?['campaignNotification'] ?? true,
      darkMode: map?['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageNotification': messageNotification,
      'offerNotification': offerNotification,
      'jobNotification': jobNotification,
      'campaignNotification': campaignNotification,
      'darkMode': darkMode,
    };
  }
}