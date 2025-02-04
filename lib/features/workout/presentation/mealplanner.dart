import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  List<String> weekDays = [];
  Map<String, List<String>> userIngredients = {};

  // Sample dataset of recipes
  final Map<String, List<String>> recipes = {
    'Chicken Salad': ['chicken', 'lettuce', 'tomato', 'cucumber'],
    'Vegetable Stir Fry': ['broccoli', 'carrot', 'bell pepper', 'soy sauce'],
    'Spaghetti Bolognese': [
      'spaghetti',
      'ground beef',
      'tomato sauce',
      'onion'
    ],
    'Fruit Smoothie': ['banana', 'strawberry', 'yogurt', 'honey'],
  };

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    DateTime startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    weekDays = List.generate(7, (index) {
      DateTime date = startOfWeek.add(Duration(days: index));
      return DateFormat('d').format(date);
    });
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today, ${DateFormat('d MMM yyyy').format(selectedDate)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                      _generateWeekDays();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                bool isSelected = int.parse(weekDays[index]) ==
                    int.parse(DateFormat('d').format(selectedDate));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          int.parse(weekDays[index]),
                        );
                      });
                    },
                    child: Container(
                      width: 45,
                      height: 65,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: isSelected ? Colors.deepPurple : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(
                              DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                int.parse(weekDays[index]),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekDays[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType, String calories, String imageUrl) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended $calories Cal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddMealDialog(mealType);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMealDialog(String mealType) async {
    List<String> ingredients = [];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $mealType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                hintText: 'e.g., chicken, rice, vegetables',
              ),
              onChanged: (value) {
                ingredients = value.split(',').map((e) => e.trim()).toList();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userIngredients[mealType] = ingredients;
                // Here you would typically call your AI service
                // to get meal recommendations based on ingredients
              });
              Navigator.pop(context);
              _showRecommendationDialog(mealType, ingredients);
            },
            child: const Text('Get Recommendations'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecommendationDialog(
      String mealType, List<String> ingredients) async {
    // Get recommended meals based on ingredients
    List<String> recommendedMeals = _getRecommendedMeals(ingredients);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Recommendation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Based on your ingredients: ${ingredients.join(", ")}'),
            const SizedBox(height: 16),
            const Text('Recommended meals:'),
            const SizedBox(height: 8),
            ...recommendedMeals.map((meal) => Card(
                  child: ListTile(
                    title: Text(meal),
                    subtitle:
                        const Text('Estimated preparation time: 25 minutes'),
                    trailing: const Icon(Icons.restaurant_menu),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you would typically save the selected meal
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$mealType added to your plan')),
              );
            },
            child: const Text('Add to Plan'),
          ),
        ],
      ),
    );
  }

  List<String> _getRecommendedMeals(List<String> ingredients) {
    List<String> recommendedMeals = [];

    recipes.forEach((meal, recipeIngredients) {
      if (ingredients
          .any((ingredient) => recipeIngredients.contains(ingredient))) {
        recommendedMeals.add(meal);
      }
    });

    return recommendedMeals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildDateSelector(),
          _buildMealCard(
            'Breakfast',
            '830-1170',
            'https://via.placeholder.com/100',
          ),
          _buildMealCard(
            'Lunch',
            '255-370',
            'https://via.placeholder.com/100',
          ),
          _buildMealCard(
            'Snack',
            '830-1170',
            'https://via.placeholder.com/100',
          ),
          _buildMealCard(
            'Dinner',
            '255-370',
            'https://via.placeholder.com/100',
          ),
        ],
      ),
    );
  }
}
