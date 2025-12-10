import 'package:flutter/material.dart';

class Todo {
  final String id;
  String title;
  bool done;

  Todo({required this.id, required this.title, this.done = false});
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.insert(
        0,
        Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: text),
      );
      _controller.clear();
    });
  }

  void _toggleDone(String id, bool? value) {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    setState(() => _todos[idx].done = value ?? false);
  }

  void _removeTodo(String id) {
    setState(() => _todos.removeWhere((t) => t.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _todos.isEmpty
                ? const Center(child: Text('Tidak ada tugas. Tambahkan tugas baru.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Dismissible(
                        key: ValueKey(todo.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _removeTodo(todo.id),
                        child: CheckboxListTile(
                          value: todo.done,
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          onChanged: (v) => _toggleDone(todo.id, v),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tambahkan tugas',
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
