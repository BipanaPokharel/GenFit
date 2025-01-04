import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> with SingleTickerProviderStateMixin {
  final List<String> equipment = [];
  final TextEditingController equipmentController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void addEquipment() {
    if (equipmentController.text.isNotEmpty) {
      setState(() {
        equipment.add(equipmentController.text);
        equipmentController.clear();
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void showWorkouts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Awesome Workouts!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets5.lottiefiles.com/packages/lf20_oz8GTO.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text('Workouts generated based on your cool equipment!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Equipment Tracker'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.deepPurple[100]!, Colors.deepPurple[300]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: equipmentController,
                decoration: InputDecoration(
                  labelText: 'Enter Equipment',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addEquipment,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: equipment.isEmpty
                    ? Center(
                        child: Lottie.network(
                          'https://assets9.lottiefiles.com/packages/lf20_lc46h4dr.json',
                          width: 200,
                          height: 200,
                        ),
                      )
                    : ListView.builder(
                        itemCount: equipment.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      equipment.removeAt(index);
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Lottie.network(
                                  'https://assets3.lottiefiles.com/packages/lf20_rdfe8tke.json',
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text(equipment[index]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: showWorkouts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: Lottie.network(
                  'https://assets6.lottiefiles.com/packages/lf20_bqij8rld.json',
                  width: 30,
                  height: 30,
                ),
                label: const Text('Generate Workouts'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEquipment,
        backgroundColor: Colors.deepPurple,
        child: Lottie.network(
          'https://assets3.lottiefiles.com/packages/lf20_wbx0gfib.json',
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
