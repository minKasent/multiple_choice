import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../subjects/presentation/bloc/subjects_cubit.dart';
import '../../../subjects/presentation/bloc/subjects_state.dart';

@RoutePage()
class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  late final SubjectsCubit _cubit;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SubjectsCubit>();
    _loadSubjects();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    await _cubit.loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ngân hàng câu hỏi')),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm môn học...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            const Divider(height: 1),

            // Subject list
            Expanded(
              child: BlocBuilder<SubjectsCubit, SubjectsState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    loaded: (subjects) {
                      final filteredSubjects = _searchQuery.isEmpty
                          ? subjects
                          : subjects
                                .where(
                                  (s) => s.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                                )
                                .toList();

                      if (filteredSubjects.isEmpty) {
                        return EmptyState(
                          icon: Icons.school_outlined,
                          title: _searchQuery.isEmpty
                              ? 'Chưa có môn học'
                              : 'Không tìm thấy môn học',
                          message: _searchQuery.isEmpty
                              ? 'Thêm môn học để quản lý câu hỏi'
                              : 'Thử tìm kiếm với từ khóa khác',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadSubjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = filteredSubjects[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(subject.code),
                                ),
                                title: Text(subject.name),
                                subtitle: subject.description != null
                                    ? Text(
                                        subject.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  context.router.push(
                                    ChaptersRoute(subject: subject),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                    error: (message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lỗi: $message'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSubjects,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                    orElse: () => const Center(child: Text('Chưa có dữ liệu')),
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
