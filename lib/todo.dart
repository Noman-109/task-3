import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(tasks));
  }

  // Add a new task
  void _addTask(String task) {
    setState(() {
      tasks.add({'task': task, 'completed': false});
    });
    _saveTasks();
    taskController.clear();
  }

  // Toggle task completion status
  void _toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
    _saveTasks();
  }

  // Delete a task
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'New Task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addTask(value);
                }
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(
                      task['task'],
                      style: TextStyle(
                        decoration: task['completed']
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: task['completed'],
                      onChanged: (value) {
                        _toggleTask(index);
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
