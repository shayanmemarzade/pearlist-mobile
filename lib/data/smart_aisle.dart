import 'models.dart';

/// Keyword lists keyed by a word that appears in the matching aisle's name
/// ("dairy" matches "Dairy & eggs").
const Map<String, List<String>> _keywords = {
  'produce': [
    'apple', 'apricot', 'banana', 'berr', 'grape', 'lemon', 'lime',
    'orange', 'pear', 'peach', 'plum', 'mango', 'melon', 'avocado',
    'tomato', 'potato', 'onion', 'garlic', 'carrot', 'lettuce', 'spinach',
    'kale', 'cucumber', 'pepper', 'broccoli', 'zucchini', 'herb', 'fruit',
  ],
  'dairy': ['milk', 'egg', 'yogurt', 'yoghurt', 'cheese', 'butter', 'cream'],
  'meat': [
    'chicken', 'beef', 'pork', 'lamb', 'turkey', 'bacon', 'sausage',
    'fish', 'salmon', 'tuna', 'shrimp', 'prawn', 'steak', 'mince',
  ],
  'bakery': [
    'bread', 'bagel', 'bun', 'roll', 'croissant', 'muffin', 'tortilla',
    'pita', 'cake', 'baguette',
  ],
  'frozen': ['frozen', 'ice cream', 'pizza'],
  'pantry': [
    'rice', 'pasta', 'flour', 'sugar', 'oil', 'vinegar', 'cereal', 'oat',
    'bean', 'lentil', 'sauce', 'salt', 'spice', 'coffee', 'tea', 'honey',
    'jam', 'nut',
  ],
};

/// Picks the aisle an item most likely belongs to ("Smart Aisle").
/// Falls back to [kOtherAisle].
String guessAisle(String itemName, List<String> aisles) {
  final name = itemName.toLowerCase();
  for (final entry in _keywords.entries) {
    if (!entry.value.any(name.contains)) continue;
    for (final aisle in aisles) {
      if (aisle.toLowerCase().contains(entry.key)) return aisle;
    }
  }
  return kOtherAisle;
}
