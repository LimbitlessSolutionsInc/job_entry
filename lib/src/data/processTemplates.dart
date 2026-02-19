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
      {
        'title': 'Quality Check',
        'order': 4,
      }
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
      {
        'title': 'Quality Check',
        'order': 4,
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
      {
        'title': 'Quality Check',
        'order': 5,
      },
    ],
    'Game Controller': [
      {
        'title': '3D Printing',
        'order': 0,
      },
      {
        'title': 'Sanding',
        'order': 1,
      },
      {
        'title': 'Painting',
        'order': 2,
      },
      {
        'title': 'Assembly',
        'order': 3,
      },
      {
        'title': 'Quality Check',
        'order': 4,
      },
    ],
    'Game Controller Electronics': [
    ],
    'Game Controller Box': [
      {
        'title': 'Purchase Order for Box',
        'order': 0,
      },
      {
        'title': 'Cutting Foam',
        'order': 1,
      },
      {
        'title': 'Assembly',
        'order': 2,
      },
      {
        'title': 'Quality Check',
        'order': 3,
      },
    ],
    'Arm Box': [
      {
        'title': 'Purchase Order for Box',
        'order': 0,
      },
      {
        'title': 'Cutting Foam',
        'order': 1,
      },
      {
        'title': 'Printing Booklets',
        'order': 2,
      },
      {
        'title': 'Purchase Order for Charging Cables',
        'order': 3,
      },
      {
        'title': 'Assembly',
        'order': 4,
      },
      {
        'title': 'Quality Check',
        'order': 5,
      },
    ],
    'Socket': [
      {
        'title': 'Patient Order',
        'order': 0,
      },
      {
        'title': 'Design',
        'order': 1,
      },
      {
        'title': '3D Printing',
        'order': 2,
      },
      {
        'title': 'Sanding',
        'order': 3,
      },
      {
        'title': 'Painting',
        'order': 4,
      },
      {
        'title': 'Cutting Foam',
        'order': 5,
      },
      {
        'title': 'Assembly',
        'order': 6,
      },
      {
        'title': 'Quality Check',
        'order': 7,
      },
    ],
    'Magnet EMG': [
      {
        'title': 'EMG Cable Assembly',
        'order': 0,
      },
      {
        'title': 'EMG Sensor',
        'order': 1,
      },
      {
        'title': 'Quality Check',
        'order': 2,
      },
    ],
    'Boa Assembly': [
      {
        'title': 'Purchase Order for Boa',
        'order': 0,
      },
      {
        'title': 'Purchase Order for Cables',
        'order': 1,
      },
      {
        'title': 'Assembly',
        'order': 2,
      },
      {
        'title': 'Quality Check',
        'order': 3,
      },
    ],
    'Finger Assembly': [
      {
        'title': 'Overmolding',
        'order': 0,
      },
      {
        'title': 'Assembly',
        'order': 1,
      },
      {
        'title': 'Quality Check',
        'order': 2,
      },
    ],
    'Hand Assembly': [
      {
        'title': 'Hand Core Assembly',
        'order': 0,
      },
      {
        'title': 'Add Fingers and Thumb',
        'order': 1,
      },
      {
        'title': 'Quality Stickers',
        'order': 2,
      },
      {
        'title': 'Palm Plate',
        'order': 3,
      },
      {
        'title': 'Quality Check',
        'order': 4,
      },
    ],
    'Board': [
      {
        'title': 'Purchase Orders for Components',
        'order': 0,
      },
      {
        'title': 'Programming the Board',
        'order': 1,
      },
      {
        'title': 'Quality Check',
        'order': 2,
      },
    ],
    'Battery Assembly': [
      {
        'title': 'Purchase Orders for Components',
        'order': 0,
      },
      {
        'title': 'Battery Assembly',
        'order': 1,
      },
      {
        'title': 'Quality Check',
        'order': 2,
      },
    ],
    'Battery Core Assembly': [
      {
        'title': 'Injection Molded Casing',
        'order': 0,
      },
      {
        'title': 'Battery Core Assembly',
        'order': 1,
      },
      {
        'title': 'Quality Check',
        'order': 2,
      },
    ],
    'Arm Assembly': [
      {
        'title': 'Final Assembly',
        'order': 0,
      },
      {
        'title': 'Quality Check',
        'order': 1,
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
