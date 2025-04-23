import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({Key? key}) : super(key: key);

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  List<String> weekDays = [];
  List<dynamic> mealRecommendations = [];
  List<dynamic> savedMeals = [];
  bool isLoading = false;
  final TextEditingController ingredientController = TextEditingController();
  List<String> selectedIngredients = [];
  final apiService = ApiService("http://localhost:3000/api");

  @override
  void initState() {
    super.initState();
    generateWeekDays();
    loadSavedMeals();
  }

  void generateWeekDays() {
    DateTime startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    weekDays = List.generate(
        7,
        (index) =>
            DateFormat('d').format(startOfWeek.add(Duration(days: index))));
    setState(() {});
  }

  Future<void> loadMealRecommendations() async {
    if (selectedIngredients.isEmpty) {
      showSnackBar('Please add at least one ingredient');
      return;
    }

    setState(() => isLoading = true);

    try {
      final recommendations =
          await apiService.generateMealSuggestions(selectedIngredients);
      setState(() => mealRecommendations = recommendations);
    } catch (e) {
      showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadSavedMeals() async {
    try {
      final meals = await apiService.getSavedMeals(selectedDate);
      setState(() => savedMeals = meals);
    } catch (e) {
      showSnackBar('Error loading saved meals: ${e.toString()}');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void addIngredient(String ingredient) {
    setState(() {
      selectedIngredients.add(ingredient);
      ingredientController.clear();
    });
  }

  Future<void> saveMeal(dynamic meal) async {
    try {
      if (meal == null) throw Exception("Meal data is null");

      await apiService.saveMealToPlan(selectedDate, meal);
      showSnackBar('Meal added to plan');
      loadSavedMeals();
    } catch (e) {
      showSnackBar('Error saving meal: ${e.toString()}');
    }
  }

  Widget buildDateSelector() {
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
                    color: Colors.deepPurple),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025, 12, 30),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                      generateWeekDays();
                      loadSavedMeals();
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
              children: List.generate(
                7,
                (index) {
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
                        loadSavedMeals();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.deepPurple : Colors.grey[200],
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
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIngredientInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ingredientController,
              decoration: const InputDecoration(
                hintText: 'Enter ingredient',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  addIngredient(value);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (ingredientController.text.isNotEmpty) {
                addIngredient(ingredientController.text);
              }
            },
          ),
          ElevatedButton(
            onPressed: loadMealRecommendations,
            child: const Text('Get Suggestions'),
          ),
        ],
      ),
    );
  }

  Widget buildIngredientsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: selectedIngredients.map((ingredient) {
          return Chip(
            label: Text(ingredient),
            deleteIcon: const Icon(Icons.cancel, color: Colors.white),
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

  Widget buildMealRecommendations() {
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
                  onPressed: loadMealRecommendations,
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

          String mealName = 'Unknown Meal';
          List<dynamic> ingredients = [];
          String prepTime = 'N/A';
          String cookTime = 'N/A';
          String? url;

          if (meal is Map<String, dynamic>) {
            mealName =
                meal['meal'] ?? meal['name'] ?? meal['title'] ?? 'Unknown Meal';

            if (meal['ingredients'] is List) {
              ingredients = meal['ingredients'];
            } else if (meal['ingredients'] is String) {
              ingredients = [meal['ingredients']];
            }

            if (meal['details'] is Map<String, dynamic>) {
              prepTime = meal['details']['prepTime'] ?? 'N/A';
              cookTime = meal['details']['cookTime'] ?? 'N/A';
              url = meal['details']['url'];
            } else {
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
                                if (ingredient is String) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('• $ingredient'),
                                  );
                                } else if (ingredient is Map<String, dynamic>) {
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
                                  showSnackBar(
                                      'Could not open URL: ${e.toString()}');
                                }
                              },
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Save to Plan'),
                            onPressed: () => saveMeal(meal),
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

  Widget buildSavedMeals() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Meals for this Date:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          savedMeals.isEmpty
              ? const Text('No meals saved for this date.')
              : Column(
                  children: savedMeals
                      .map((meal) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(meal['meal'] ??
                                  meal['name'] ??
                                  'Unknown Meal'),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: ListView(
        children: [
          buildDateSelector(),
          buildIngredientInput(),
          buildIngredientsList(),
          buildMealRecommendations(),
          buildSavedMeals(),
        ],
      ),
    );
  }
}
