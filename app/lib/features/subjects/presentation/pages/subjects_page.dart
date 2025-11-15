import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../data/models/subject_model.dart';
import '../bloc/subjects_cubit.dart';
import '../bloc/subjects_state.dart';
import '../widgets/subject_card.dart';

@RoutePage()
class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  late final SubjectsCubit _subjectsCubit;
  late final AuthCubit _authCubit;
  final _searchController = TextEditingController();
  List<SubjectModel> _allSubjects = [];

  @override
  void initState() {
    super.initState();
    _authCubit = getIt<AuthCubit>();
    _subjectsCubit = getIt<SubjectsCubit>();
    _checkAuthAndLoadSubjects();
  }

  Future<void> _checkAuthAndLoadSubjects() async {
    final isLoggedIn = await _authCubit.isLoggedIn();
    if (!isLoggedIn && mounted) {
      context.router.replaceNamed('/login');
      context.showSnackBar('Vui lòng đăng nhập để tiếp tục');
      return;
    }
    _loadSubjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    await _subjectsCubit.loadSubjects();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _subjectsCubit.loadSubjects();
    } else {
      _subjectsCubit.searchSubjects(query);
    }
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm môn học mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã môn học *',
                  hintText: 'VD: MATH101',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học *',
                  hintText: 'VD: Toán học',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả môn học',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isEmpty || nameController.text.isEmpty) {
                context.showSnackBar('Vui lòng điền đầy đủ thông tin',
                    isError: true);
                return;
              }

              _subjectsCubit.createSubject({
                'code': codeController.text.trim().toUpperCase(),
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditSubjectDialog(SubjectModel subject) {
    final nameController = TextEditingController(text: subject.name);
    final codeController = TextEditingController(text: subject.code);
    final descController = TextEditingController(text: subject.description);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa môn học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã môn học *',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học *',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isEmpty || nameController.text.isEmpty) {
                context.showSnackBar('Vui lòng điền đầy đủ thông tin',
                    isError: true);
                return;
              }

              _subjectsCubit.updateSubject(subject.id, {
                'code': codeController.text.trim().toUpperCase(),
                'name': nameController.text.trim(),
                'description': descController.text.trim(),
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _subjectsCubit.deleteSubject(subject.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _subjectsCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý môn học'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSubjects,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm môn học...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Content
            Expanded(
              child: BlocConsumer<SubjectsCubit, SubjectsState>(
                listener: (context, state) {
                  state.when(
                    initial: () {},
                    loading: () {},
                    loaded: (subjects) {
                      setState(() {
                        _allSubjects = subjects;
                      });
                    },
                    created: (subject) {
                      context.showSnackBar('Đã thêm môn học "${subject.name}"');
                    },
                    updated: (subject) {
                      context.showSnackBar('Đã cập nhật môn học "${subject.name}"');
                    },
                    deleted: () {
                      context.showSnackBar('Đã xóa môn học');
                    },
                    error: (message) {
                      context.showSnackBar(message, isError: true);
                    },
                  );
                },
                builder: (context, state) {
                  final isLoading = state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  );

                  if (isLoading && _allSubjects.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_allSubjects.isEmpty) {
                    return EmptyState(
                      icon: Icons.book_outlined,
                      title: _searchController.text.isEmpty
                          ? 'Chưa có môn học'
                          : 'Không tìm thấy môn học',
                      message: _searchController.text.isEmpty
                          ? 'Thêm môn học đầu tiên để bắt đầu'
                          : 'Thử tìm kiếm với từ khóa khác',
                      actionText:
                          _searchController.text.isEmpty ? 'Thêm môn học' : null,
                      onAction: _searchController.text.isEmpty
                          ? _showAddSubjectDialog
                          : null,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadSubjects,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _allSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = _allSubjects[index];
                        return SubjectCard(
                          code: subject.code,
                          name: subject.name,
                          description: subject.description,
                          chapterCount: 0, // TODO: Get from API
                          questionCount: 0, // TODO: Get from API
                          onTap: () {
                            // TODO: Navigate to subject detail/chapters
                            context.showSnackBar('Chi tiết ${subject.name}');
                          },
                          onEdit: () => _showEditSubjectDialog(subject),
                          onDelete: () => _showDeleteConfirmation(subject),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddSubjectDialog,
          icon: const Icon(Icons.add),
          label: const Text('Thêm môn học'),
        ),
      ),
    );
  }
}
