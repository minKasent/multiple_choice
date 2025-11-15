import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/passage_model.dart';
import '../bloc/question_bank_cubit.dart';
import '../bloc/question_bank_state.dart';

@RoutePage()
class PassagesPage extends StatefulWidget {
  final ChapterModel chapter;

  const PassagesPage({super.key, required this.chapter});

  @override
  State<PassagesPage> createState() => _PassagesPageState();
}

class _PassagesPageState extends State<PassagesPage> {
  late final QuestionBankCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<QuestionBankCubit>();
    _cubit.loadPassagesByChapter(widget.chapter.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showCreatePassageDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo đoạn văn mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cubit.createPassage(widget.chapter.id, {
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
      });
    }
  }

  Future<void> _showEditPassageDialog(PassageModel passage) async {
    final titleController = TextEditingController(text: passage.title);
    final contentController = TextEditingController(text: passage.content);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa đoạn văn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cubit.updatePassage(passage.id, {
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
      });
    }
  }

  Future<void> _showDeleteConfirmDialog(PassageModel passage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đoạn văn "${passage.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.deletePassage(passage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chapter.title),
              Text(
                'Quản lý đoạn văn',
                style: TextStyle(fontSize: 12, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
        body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
          listener: (context, state) {
            state.maybeWhen(
              passageCreated: (_) {
                context.showSnackBar('Tạo đoạn văn thành công');
                _cubit.loadPassagesByChapter(widget.chapter.id);
              },
              passageUpdated: (_) {
                context.showSnackBar('Cập nhật đoạn văn thành công');
                _cubit.loadPassagesByChapter(widget.chapter.id);
              },
              passageDeleted: () {
                context.showSnackBar('Xóa đoạn văn thành công');
                _cubit.loadPassagesByChapter(widget.chapter.id);
              },
              error: (message) {
                context.showSnackBar(message, isError: true);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              passagesLoaded: (passages) {
                if (passages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có đoạn văn nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _cubit.loadPassagesByChapter(widget.chapter.id);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: passages.length,
                    itemBuilder: (context, index) {
                      final passage = passages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            context.router.push(
                              QuestionsListRoute(
                                chapter: widget.chapter,
                                passage: passage,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        passage.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Sửa'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditPassageDialog(passage);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmDialog(passage);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  passage.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreatePassageDialog,
          icon: const Icon(Icons.add),
          label: const Text('Tạo đoạn văn'),
        ),
      ),
    );
  }
}
