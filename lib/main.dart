import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoListPage(),
    );
  }
}

// 掃除タスク用のクラス
class CleaningTask {
  final String place;
  final String content;
  final String frequency;
  final String memo;

  CleaningTask({
    required this.place,
    required this.content,
    required this.frequency,
    required this.memo,
  });
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<CleaningTask> _todos = [];
  final List<CleaningTask> _completed = [];
  // final TextEditingController _controller = TextEditingController();

  // 入力用コントローラーたち
  String _selectedPlace = 'リビング';
  final _contentController = TextEditingController();
  String _selectedFrequency = '毎日';
  final _memoController = TextEditingController();

  final List<String> _places = ['リビング', 'キッチン', 'お風呂', 'トイレ', '玄関', '自分の部屋'];
  final List<String> _frequencies = ['毎日', '週1', '月1', '気が向いたら'];

  void _addTodo() {
    if (_contentController.text.isNotEmpty) {
      setState(() {
        _todos.add(CleaningTask(
          place: _selectedPlace,
          content: _contentController.text,
          frequency: _selectedFrequency,
          memo: _memoController.text,
        ));
        _contentController.clear();
        _memoController.clear();
        _selectedPlace = _places[0];
        _selectedFrequency = _frequencies[0];
      });
    }
  }

  void _completeTodo(int index) {
    setState(() {
      _completed.add(_todos[index]);
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('掃除ToDoリスト✨')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('場所: '),
                    DropdownButton<String>(
                      value: _selectedPlace,
                      items: _places
                          .map((place) => DropdownMenuItem(
                                value: place,
                                child: Text(place),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPlace = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text('頻度: '),
                    DropdownButton<String>(
                      value: _selectedFrequency,
                      items: _frequencies
                          .map((freq) => DropdownMenuItem(
                                value: freq,
                                child: Text(freq),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '内容（例: 床掃除、窓拭き など）',
                  ),
                ),
                TextField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    labelText: 'メモ（任意）',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('追加！'),
                    onPressed: _addTodo,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final task = _todos[index];
                return ListTile(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: false,
                      onChanged: (value) {
                        _completeTodo(index);
                      },
                    ),
                  ),
                  title: Text('${task.place}｜${task.content}'),
                  subtitle: Text('頻度: ${task.frequency}\n${task.memo}'),
                  isThreeLine: true,
                );
              },
            ),
          ),
          const Divider(),
          ExpansionTile(
            title: const Text(
              '完了済み',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true, // 最初から開いておきたいならtrue
            children: [
              /* Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                child: */
              _completed.isEmpty
                  ? const Center(child: Text('完了済みのタスクはありません'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _completed.length,
                      itemBuilder: (context, index) {
                        final task = _completed[index];
                        return ListTile(
                          leading: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: true,
                              onChanged: (value) {
                                setState(() {
                                  _todos.add(task);
                                  _completed.removeAt(index);
                                });
                              },
                            ),
                          ),
                          title: Text(
                            '${task.place}｜${task.content}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Text('頻度: ${task.frequency}\n${task.memo}'),
                          isThreeLine: true,
                        );
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
