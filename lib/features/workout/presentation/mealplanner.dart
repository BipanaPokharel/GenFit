import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:intl/intl.dart';

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
    if (selectedIngredients.isEmpty) return;

    setState(() => isLoading = true);
    final apiService = ApiService("http://10.0.2.2:3000/api");

    try {
      final recommendations =
          await apiService.generateMealSuggestions(selectedIngredients);
      setState(() => mealRecommendations = recommendations);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadSavedMeals() async {
    final apiService = ApiService("http://10.0.2.2:3000/api");
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
                    initialDate: selectedDate,
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
                bool isSelected =
                    int.parse(weekDays[index]) == selectedDate.day;
                return GestureDetector(
                  onTap: () => setState(() {
                    selectedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      int.parse(weekDays[index]),
                    );
                    _loadSavedMeals();
                  }),
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
                          DateFormat('E').format(selectedDate),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ingredientController,
            decoration: InputDecoration(
              labelText: 'Enter ingredients (comma separated)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_ingredientController.text.isNotEmpty) {
                    setState(() {
                      selectedIngredients.addAll(
                        _ingredientController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                      );
                      _ingredientController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: selectedIngredients
                .map((ingredient) => Chip(
                      label: Text(ingredient),
                      onDeleted: () => setState(
                          () => selectedIngredients.remove(ingredient)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                selectedIngredients.isEmpty ? null : _loadMealRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Find Recipes'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic meal) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['meal'] ?? 'Unnamed Meal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingredients: ${(meal['ingredients'] as List).join(', ')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (meal['details'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Prep: ${meal['details']['prepTime'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          'Cook: ${meal['details']['cookTime'] ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    meal['details']?['url'] ?? 'https://placehold.co/150x150',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Text('Failed to load image');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add to Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    final apiService = ApiService("http://10.0.2.2:3000/api");
                    await apiService.saveMealToPlan(selectedDate, meal);
                    await _loadSavedMeals();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal added to plan!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedMeals() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Your Meal Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (savedMeals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No meals planned for this date'),
          )
        else
          ...savedMeals.map((meal) => _buildMealCard(meal)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateSelector(),
            _buildIngredientInput(),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (mealRecommendations.isNotEmpty)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Recommended Meals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...mealRecommendations
                      .map((meal) => _buildMealCard(meal))
                      .toList(),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No recommended meals available."),
              ),
            _buildSavedMeals(),
          ],
        ),
      ),
    );
  }
}
