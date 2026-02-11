/// Process templates defining default jobs for each process type
class ProcessTemplates {
  /// Template jobs for each process
  /// Each template contains job definitions with title, order, and description
  static Map<String, List<Map<String, dynamic>>> templates = {
    'Core Parts': [
      {
        'title': 'Injection Molding',
        'order': 0,
      },
      {
        'title': 'Drilling',
        'order': 1,
      },
      {
        'title': 'Sanding',
        'order': 2,
      },
      {
        'title': 'Painting',
        'order': 3,
      },
    ],
    'Cosmetic Sleeves': [
      {
        'title': 'Patient Order',
        'order': 0,
      },
      {
        'title': 'Thermoforming',
        'order': 1,
      },
      {
        'title': 'Sanding',
        'order': 2,
      },
      {
        'title': 'Painting',
        'order': 3,
      },
    ],
    'Magnets/Magnet Holders': [
      {
        'title': 'Design',
        'order': 0,
      },
      {
        'title': '3D Printing',
        'order': 1,
      },
      {
        'title': 'Gluing Holder to Sleeve',
        'order': 2,
      },
      {
        'title': 'Purchase Order for Magnets',
        'order': 3,
      },
      {
        'title': 'Gluing Magnets to Holder',
        'order': 4,
      },
    ],
  };

  /// Get template jobs for a specific process
  /// Returns empty list if process has no template
  static List<Map<String, dynamic>> getTemplate(String processId) {
    return templates[processId] ?? [];
  }

  /// Check if a process has a template defined
  static bool hasTemplate(String processId) {
    return templates.containsKey(processId) && templates[processId]!.isNotEmpty;
  }
}
