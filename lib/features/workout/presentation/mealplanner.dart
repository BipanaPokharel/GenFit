import 'package:flutter/material.dart';
import 'package:fyp/utils/api_service.dart';
import 'package:intl/intl.dart';

class MealPlanner extends StatefulWidget {
  const MealPlanner({Key? key});

  @override
  State<MealPlanner> createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  DateTime selectedDate = DateTime.now();
  List<String> weekDays = [];
  Map<String, List<String>> userIngredients = {};
  List<dynamic> mealRecommendations = []; // Store meal recommendations

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
    _loadMealRecommendations(); // Load meal recommendations on init
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

  // Load meal recommendations from API
  Future<void> _loadMealRecommendations() async {
    final apiService = ApiService("http://localhost:3000/api");
    try {
      List<dynamic> recommendations =
          await apiService.generateMealSuggestions(["chicken", "rice"]);
      setState(() {
        mealRecommendations = recommendations;
      });
      print("Meal Recommendations: $recommendations");
    } catch (e) {
      print("Error fetching recommendations: $e");
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
                  ElevatedButton(
                    onPressed: () {
                      // Handle meal selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add to Plan'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
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
            // Display meal recommendations
            if (mealRecommendations.isNotEmpty)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Recommended Meals",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: mealRecommendations.length,
                    itemBuilder: (context, index) {
                      final meal = mealRecommendations[index];
                      return _buildMealCard(
                        meal['meal'],
                        '400-500', // Replace with actual calorie count if available
                        'https://placekitten.com/200/200?image=${index + 5}', // Replace with actual image URL if available
                      );
                    },
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Loading meal recommendations..."),
              ),
          ],
        ),
      ),
    );
  }
}
