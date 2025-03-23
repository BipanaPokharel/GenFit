import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({super.key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  List<String> weekDays = [];
  List<dynamic> mealRecommendations = [];
  List<dynamic> savedMeals = [];
  bool isLoading = false;
  final TextEditingController _ingredientController = TextEditingController();
  List<String> selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
    _loadSavedMeals();
  }

  void _generateWeekDays() {
    DateTime startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    weekDays = List.generate(7, (index) {
      return DateFormat('d').format(startOfWeek.add(Duration(days: index)));
    });
    setState(() {});
  }

  Future<void> _loadMealRecommendations() async {
    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    setState(() => isLoading = true);
    final apiService = ApiService("http://localhost:3000/api");

    try {
      print('Sending request with ingredients: $selectedIngredients');
      final recommendations =
          await apiService.generateMealSuggestions(selectedIngredients);

      // Debugging: Log recommendations
      print('Fetched meal recommendations: $recommendations');

      setState(() {
        mealRecommendations = recommendations;
      });
    } catch (e) {
      print('Error fetching meal recommendations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSavedMeals() async {
    final apiService = ApiService("http://localhost:3000/api");
    try {
      final meals = await apiService.getSavedMeals(selectedDate);
      setState(() => savedMeals = meals);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading saved meals: ${e.toString()}')),
      );
    }
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
                'Selected Date: ${DateFormat('d MMM yyyy').format(selectedDate)}',
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
                    initialDate: selectedDate.isBefore(DateTime(2025))
                        ? selectedDate
                        : DateTime(2025, 1, 1), // Ensure initialDate is valid
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                      _generateWeekDays();
                      _loadSavedMeals();
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
                DateTime currentDay = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  int.parse(weekDays[index]),
                );
                bool isSelected = currentDay.day == selectedDate.day &&
                    currentDay.month == selectedDate.month &&
                    currentDay.year == selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        int.parse(weekDays[index]),
                      );
                      _loadSavedMeals();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            int.parse(weekDays[index]),
                          )),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
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
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ingredientController,
              decoration: const InputDecoration(
                hintText: 'Enter ingredient',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    selectedIngredients.add(value);
                    _ingredientController.clear();
                  });
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_ingredientController.text.isNotEmpty) {
                setState(() {
                  selectedIngredients.add(_ingredientController.text);
                  _ingredientController.clear();
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: _loadMealRecommendations,
            child: const Text('Get Suggestions'),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: selectedIngredients.map((ingredient) {
          return Chip(
            label: Text(ingredient),
            deleteIconColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            labelStyle: const TextStyle(color: Colors.white),
            onDeleted: () {
              setState(() {
                selectedIngredients.remove(ingredient);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealRecommendations() {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (mealRecommendations.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No meal suggestions available.'),
              const SizedBox(height: 16),
              if (selectedIngredients.isNotEmpty)
                ElevatedButton(
                  onPressed: _loadMealRecommendations,
                  child: const Text('Try Again'),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 400,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: mealRecommendations.length,
        itemBuilder: (context, index) {
          final meal = mealRecommendations[index];

          // Debug print to see what's in each meal
          print('Rendering meal: $meal');

          // Handle all possible response formats with null safety
          String mealName = 'Unknown Meal';
          List<dynamic> ingredients = [];
          String prepTime = 'N/A';
          String cookTime = 'N/A';
          String? url;

          // Handle different possible structures of the meal object
          if (meal is Map<String, dynamic>) {
            // Direct properties
            mealName =
                meal['meal'] ?? meal['name'] ?? meal['title'] ?? 'Unknown Meal';

            // Handle ingredients that could be in different formats
            if (meal['ingredients'] is List) {
              ingredients = meal['ingredients'];
            } else if (meal['ingredients'] is String) {
              ingredients = [meal['ingredients']];
            }

            // Handle details that could be in different formats
            if (meal['details'] is Map<String, dynamic>) {
              prepTime = meal['details']['prepTime'] ?? 'N/A';
              cookTime = meal['details']['cookTime'] ?? 'N/A';
              url = meal['details']['url'];
            } else {
              // Try direct properties
              prepTime = meal['prepTime'] ?? meal['prep_time'] ?? 'N/A';
              cookTime = meal['cookTime'] ?? meal['cook_time'] ?? 'N/A';
              url = meal['url'] ?? meal['recipe_url'];
            }
          }

          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            child: ExpansionTile(
              title: Text(
                mealName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('Prep Time: $prepTime | Cook Time: $cookTime'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      ingredients.isEmpty
                          ? const Text('No ingredients information available')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: ingredients.map<Widget>((ingredient) {
                                // Handle cases where the ingredient is a string
                                if (ingredient is String) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('• $ingredient'),
                                  );
                                }
                                // Handle cases where the ingredient is a map
                                else if (ingredient is Map<String, dynamic>) {
                                  String quantity =
                                      ingredient['quantity']?.toString() ?? '';
                                  String unit =
                                      ingredient['unit']?.toString() ?? '';
                                  String name =
                                      ingredient['name']?.toString() ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child:
                                        Text('• $quantity $unit $name'.trim()),
                                  );
                                }
                                return const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Text('• Unknown ingredient'),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (url != null && url.isNotEmpty)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('View Recipe'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                try {
                                  launchUrl(Uri.parse(url!));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Could not open URL: ${e.toString()}')),
                                  );
                                }
                              },
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Save to Plan'),
                            onPressed: () async {
                              try {
                                final apiService =
                                    ApiService("http://localhost:3000/api");
                                await apiService.saveMealToPlan(
                                    selectedDate, meal);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Meal added to plan')),
                                );
                                _loadSavedMeals();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error saving meal: ${e.toString()}')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedMeals() {
    if (savedMeals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No meals saved for this day.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0),
          child: Text(
            'Saved Meals:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedMeals.length,
          itemBuilder: (context, index) {
            final meal = savedMeals[index];
            return Card(
              margin: const EdgeInsets.all(8),
              elevation: 2,
              child: ListTile(
                title: Text(meal['meal'] ?? 'Unknown Meal'),
                subtitle: Text('Enjoy your meal!'),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            _buildIngredientInput(),
            _buildIngredientsList(),
            _buildMealRecommendations(),
            _buildSavedMeals(),
          ],
        ),
      ),
    );
  }
}
