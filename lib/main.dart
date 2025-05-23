import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final DateTime date;
  bool isCompleted;

  CleaningTask({
    required this.place,
    required this.content,
    required this.frequency,
    required this.memo,
    required this.date,
    this.isCompleted = false,
  });
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final Map<DateTime, List<CleaningTask>> _tasksByDate = {};
  DateTime _selectedDay = DateTime.now();

  final List<CleaningTask> _completed = [];

  // 入力用コントローラーたち
  String _selectedPlace = 'リビング';
  final _contentController = TextEditingController();
  String _selectedFrequency = '毎日';
  final _memoController = TextEditingController();

  final List<String> _places = ['リビング', 'キッチン', 'お風呂', 'トイレ', '玄関', '自分の部屋'];
  final List<String> _frequencies = ['毎日', '週1', '月1', '気が向いたら'];

  bool _isCalendarOpen = true; // カレンダーの表示状態
  bool _completedTileExpanded = false; // 完了済みタスクの表示状態

  void _addTodo() {
    if (_contentController.text.isNotEmpty) {
      setState(() {
        final Map<String, String> placeTips = {
          'リビング': 'ホコリは高いところから下に落とすと効率UP！',
          'キッチン': 'シンクは使ったらすぐ拭くと水垢防止になるよ！',
          'お風呂': '換気をしっかりするとカビ予防になるよ！',
          'トイレ': '床も壁もサッと拭くと清潔感キープ！',
          '玄関': '靴は揃えておくと運気もUP！？',
          '自分の部屋': 'ベッド下も忘れずにチェックしよ！',
        };

        String tip = placeTips[_selectedPlace] ?? '';
        String userMemo = _memoController.text.trim();
        String combinedMemo = userMemo.isEmpty ? tip : '$userMemo\n$tip';

        DateTime startDay = _selectedDay;
        DateTime endDay = startDay.add(const Duration(days: 365)); // 1年分追加する想定

        Duration step;
        int maxCount;

        if (_selectedFrequency == '毎日') {
          step = const Duration(days: 1);
          maxCount = 365;
        } else if (_selectedFrequency == '週1') {
          step = const Duration(days: 7);
          maxCount = 52;
        } else if (_selectedFrequency == '月1') {
          step = const Duration(days: 30); // 月末調整はざっくり
          maxCount = 12;
        } else {
          // 「気が向いたら」などは1回だけ
          step = const Duration(days: 0);
          maxCount = 1;
        }

        DateTime current = startDay;
        int count = 0;
        while (current.isBefore(endDay) && count < maxCount) {
          final task = CleaningTask(
            place: _selectedPlace,
            content: _contentController.text,
            frequency: _selectedFrequency,
            memo: combinedMemo,
            date: current,
          );
          if (_tasksByDate[current] == null) {
            _tasksByDate[current] = [];
          }
          _tasksByDate[current]!.add(task);

          // 月1だけはちゃんと月を進める
          if (_selectedFrequency == '月1') {
            current = DateTime(current.year, current.month + 1, current.day);
          } else if (step.inDays > 0) {
            current = current.add(step);
          } else {
            break;
          }
          count++;
        }

        _contentController.clear();
        _memoController.clear();
        _selectedPlace = _places[0];
        _selectedFrequency = _frequencies[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasksByDate[_selectedDay] ?? [];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Cleaning Todo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              icon:
                  Icon(_isCalendarOpen ? Icons.expand_less : Icons.expand_more),
              label: Text(_isCalendarOpen ? 'カレンダーを閉じる' : 'カレンダーを開く'),
              onPressed: () {
                setState(() {
                  _isCalendarOpen = !_isCalendarOpen;
                });
              },
            ),
          ),
          if (_isCalendarOpen)
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              eventLoader: (day) => _tasksByDate[day] ?? [],
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return ListTile(
                          leading: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                setState(() {
                                  task.isCompleted = value!;
                                  if (task.isCompleted) {
                                    tasks.removeAt(index);
                                    _completed.add(task);
                                  }
                                });
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
                  // const Divider(),
                  AnimatedSlide(
                    offset: _completedTileExpanded
                        ? const Offset(0, -0.5)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: ExpansionTile(
                      title: const Text(
                        '完了済み',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: false, // 最初から開いておきたいならtrue
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _completedTileExpanded = expanded;
                        });
                      },
                      children: [
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
                                            task.isCompleted = value!;
                                            if (!task.isCompleted) {
                                              _completed.removeAt(index);
                                              if (_tasksByDate[task.date] ==
                                                  null) {
                                                _tasksByDate[task.date] = [];
                                              }
                                              _tasksByDate[task.date]!
                                                  .add(task);
                                            }
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
                                    subtitle: Text(
                                        '頻度: ${task.frequency}\n${task.memo}'),
                                    isThreeLine: true,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
