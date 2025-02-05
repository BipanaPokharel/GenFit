import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  List<String> weekDays = [];
  Map<String, List<String>> userIngredients = {};

  // Meal types with their details
  final List<Map<String, dynamic>> mealTypes = [
    {
      'type': 'Breakfast',
      'calories': '300-400',
      'image': 'https://placekitten.com/200/200?image=1',
    },
    {
      'type': 'Lunch',
      'calories': '500-600',
      'image': 'https://placekitten.com/200/200?image=2',
    },
    {
      'type': 'Snack',
      'calories': '150-200',
      'image': 'https://placekitten.com/200/200?image=3',
    },
    {
      'type': 'Dinner',
      'calories': '400-500',
      'image': 'https://placekitten.com/200/200?image=4',
    },
  ];

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
    setState(() {});
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
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/user/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommendedMeals =
            jsonDecode(response.body)['recommendations'];

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Recommendations for $mealType'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Based on your ingredients: ${ingredients.join(", ")}'),
                  const SizedBox(height: 16),
                  const Text('Recommended meals:'),
                  const SizedBox(height: 8),
                  ...recommendedMeals.map((meal) => Card(
                        child: ListTile(
                          title: Text(meal['meal']),
                          subtitle: meal['prepTime'] != null
                              ? Text('Preparation time: ${meal['prepTime']}')
                              : null,
                          trailing: const Icon(Icons.restaurant_menu),
                        ),
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$mealType added to your plan'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Add to Plan'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch recommendations'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          ...mealTypes.map((meal) => _buildMealCard(
                meal['type'],
                meal['calories'],
                meal['image'],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create custom meal plan (Coming soon)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
