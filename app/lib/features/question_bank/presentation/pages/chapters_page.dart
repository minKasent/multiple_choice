import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../subjects/data/models/subject_model.dart' as subj;
import '../../data/models/chapter_model.dart';
import '../bloc/question_bank_cubit.dart';
import '../bloc/question_bank_state.dart';

@RoutePage()
class ChaptersPage extends StatefulWidget {
  final subj.SubjectModel subject;

  const ChaptersPage({super.key, required this.subject});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  late final QuestionBankCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<QuestionBankCubit>();
    _loadChapters();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    await _cubit.loadChaptersBySubject(widget.subject.id);
  }

  void _showAddChapterDialog() {
    final chapterNumberController = TextEditingController();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final displayOrderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm chương mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: chapterNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số chương *',
                  border: OutlineInputBorder(),
                  hintText: 'Ví dụ: 1',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên chương *',
                  border: OutlineInputBorder(),
                  hintText: 'Ví dụ: Giới thiệu',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: displayOrderController,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự hiển thị *',
                  border: OutlineInputBorder(),
                  hintText: 'Ví dụ: 1',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (chapterNumberController.text.isEmpty) {
                context.showSnackBar('Vui lòng nhập số chương', isError: true);
                return;
              }
              if (titleController.text.isEmpty) {
                context.showSnackBar('Vui lòng nhập tên chương', isError: true);
                return;
              }
              if (displayOrderController.text.isEmpty) {
                context.showSnackBar(
                  'Vui lòng nhập thứ tự hiển thị',
                  isError: true,
                );
                return;
              }

              final chapterNumber = int.tryParse(chapterNumberController.text);
              final displayOrder = int.tryParse(displayOrderController.text);

              if (chapterNumber == null || chapterNumber < 1) {
                context.showSnackBar(
                  'Số chương phải là số nguyên dương',
                  isError: true,
                );
                return;
              }
              if (displayOrder == null || displayOrder < 1) {
                context.showSnackBar(
                  'Thứ tự hiển thị phải là số nguyên dương',
                  isError: true,
                );
                return;
              }

              _cubit.createChapter(widget.subject.id, {
                'chapterNumber': chapterNumber,
                'title': titleController.text,
                'description': descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                'displayOrder': displayOrder,
              });

              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditChapterDialog(ChapterModel chapter) {
    final chapterNumberController = TextEditingController(
      text: chapter.chapterNumber.toString(),
    );
    final titleController = TextEditingController(text: chapter.title);
    final descriptionController = TextEditingController(
      text: chapter.description,
    );
    final displayOrderController = TextEditingController(
      text: chapter.displayOrder.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa chương'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: chapterNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số chương *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên chương *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: displayOrderController,
                decoration: const InputDecoration(
                  labelText: 'Thứ tự hiển thị *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (chapterNumberController.text.isEmpty) {
                context.showSnackBar('Vui lòng nhập số chương', isError: true);
                return;
              }
              if (titleController.text.isEmpty) {
                context.showSnackBar('Vui lòng nhập tên chương', isError: true);
                return;
              }
              if (displayOrderController.text.isEmpty) {
                context.showSnackBar(
                  'Vui lòng nhập thứ tự hiển thị',
                  isError: true,
                );
                return;
              }

              final chapterNumber = int.tryParse(chapterNumberController.text);
              final displayOrder = int.tryParse(displayOrderController.text);

              if (chapterNumber == null || chapterNumber < 1) {
                context.showSnackBar(
                  'Số chương phải là số nguyên dương',
                  isError: true,
                );
                return;
              }
              if (displayOrder == null || displayOrder < 1) {
                context.showSnackBar(
                  'Thứ tự hiển thị phải là số nguyên dương',
                  isError: true,
                );
                return;
              }

              _cubit.updateChapter(chapter.id, {
                'chapterNumber': chapterNumber,
                'title': titleController.text,
                'description': descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                'displayOrder': displayOrder,
              });

              Navigator.pop(context);
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _deleteChapter(ChapterModel chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa chương "${chapter.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _cubit.deleteChapter(chapter.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text('Chương - ${widget.subject.name}')),
        body: BlocConsumer<QuestionBankCubit, QuestionBankState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) => context.showSnackBar(message, isError: true),
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: Text('Chưa có dữ liệu')),
              loading: () => const Center(child: CircularProgressIndicator()),
              chaptersLoaded: (chapters) {
                if (chapters.isEmpty) {
                  return EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: 'Chưa có chương',
                    message:
                        'Thêm chương đầu tiên cho môn ${widget.subject.name}',
                    actionText: 'Thêm chương',
                    onAction: _showAddChapterDialog,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadChapters,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${chapter.chapterNumber}'),
                          ),
                          title: Text(chapter.title),
                          subtitle: chapter.description != null
                              ? Text(
                                  chapter.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: PopupMenuButton(
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
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditChapterDialog(chapter);
                              } else if (value == 'delete') {
                                _deleteChapter(chapter);
                              }
                            },
                          ),
                          onTap: () {
                            context.router.push(
                              QuestionsListRoute(chapter: chapter),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              chapterCreated: (_) {
                _loadChapters();
                return const SizedBox.shrink();
              },
              chapterUpdated: (_) {
                _loadChapters();
                return const SizedBox.shrink();
              },
              chapterDeleted: () {
                _loadChapters();
                return const SizedBox.shrink();
              },
              passagesLoaded: (_) =>
                  const Center(child: Text('Passages loaded')),
              passageCreated: (_) => const SizedBox.shrink(),
              passageUpdated: (_) => const SizedBox.shrink(),
              passageDeleted: () => const SizedBox.shrink(),
              questionsLoaded: (_) =>
                  const Center(child: Text('Questions loaded')),
              questionCreated: (_) => const SizedBox.shrink(),
              questionUpdated: (_) => const SizedBox.shrink(),
              questionDeleted: () => const SizedBox.shrink(),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: $message'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadChapters,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddChapterDialog,
          icon: const Icon(Icons.add),
          label: const Text('Thêm chương'),
        ),
      ),
    );
  }
}
