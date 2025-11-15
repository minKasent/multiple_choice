import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../bloc/exam_rooms_cubit.dart';
import '../bloc/exam_rooms_state.dart';
import '../../data/models/exam_room_model.dart';

// TODO: Add to router when ready to integrate
class ExamRoomsListPage extends StatefulWidget {
  const ExamRoomsListPage({super.key});

  @override
  State<ExamRoomsListPage> createState() => _ExamRoomsListPageState();
}

class _ExamRoomsListPageState extends State<ExamRoomsListPage> {
  late final ExamRoomsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ExamRoomsCubit>();
    _cubit.loadExamRooms();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo phòng thi mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên phòng thi *',
                  hintText: 'VD: Phòng A1',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã phòng thi *',
                  hintText: 'VD: PA001',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Vị trí',
                  hintText: 'VD: Tầng 3, Nhà A',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Sức chứa',
                  hintText: 'VD: 50',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả phòng thi...',
                ),
                maxLines: 3,
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
              if (nameController.text.trim().isEmpty ||
                  codeController.text.trim().isEmpty) {
                context.showSnackBar('Vui lòng nhập đầy đủ thông tin bắt buộc',
                    isError: true);
                return;
              }

              final request = {
                'name': nameController.text.trim(),
                'code': codeController.text.trim(),
                if (locationController.text.trim().isNotEmpty)
                  'location': locationController.text.trim(),
                if (capacityController.text.trim().isNotEmpty)
                  'capacity': int.tryParse(capacityController.text.trim()),
                if (descriptionController.text.trim().isNotEmpty)
                  'description': descriptionController.text.trim(),
              };

              _cubit.createExamRoom(request);
              Navigator.pop(context);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ExamRoomModel examRoom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa phòng thi "${examRoom.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _cubit.deleteExamRoom(examRoom.id);
              Navigator.pop(context);
            },
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
        appBar: AppBar(
          title: const Text('Quản lý Phòng thi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadExamRooms(),
            ),
          ],
        ),
        body: BlocConsumer<ExamRoomsCubit, ExamRoomsState>(
          listener: (context, state) {
            state.when(
              initial: () {},
              loading: () {},
              examRoomsLoaded: (_) {},
              examRoomLoaded: (_) {},
              examRoomCreated: (_) {
                context.showSnackBar('Tạo phòng thi thành công');
                _cubit.loadExamRooms();
              },
              examRoomUpdated: (_) {
                context.showSnackBar('Cập nhật phòng thi thành công');
                _cubit.loadExamRooms();
              },
              examRoomDeleted: () {
                context.showSnackBar('Xóa phòng thi thành công');
                _cubit.loadExamRooms();
              },
              proctorsAssigned: (_) {
                context.showSnackBar('Gán cán bộ coi thi thành công');
                _cubit.loadExamRooms();
              },
              proctorRemoved: (_) {
                context.showSnackBar('Xóa cán bộ coi thi thành công');
                _cubit.loadExamRooms();
              },
              error: (message) {
                context.showSnackBar(message, isError: true);
              },
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: Text('Khởi tạo...')),
              loading: () => const Center(child: CircularProgressIndicator()),
              examRoomsLoaded: (examRooms) {
                if (examRooms.isEmpty) {
                  return const EmptyState(
                    icon: Icons.meeting_room_outlined,
                    title: 'Chưa có phòng thi nào',
                    message: 'Nhấn nút + để tạo phòng thi mới',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _cubit.loadExamRooms(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: examRooms.length,
                    itemBuilder: (context, index) {
                      final examRoom = examRooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            examRoom.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã: ${examRoom.code}'),
                              if (examRoom.location != null)
                                Text('Vị trí: ${examRoom.location}'),
                              if (examRoom.capacity != null)
                                Text('Sức chứa: ${examRoom.capacity} người'),
                              if (examRoom.proctors.isNotEmpty)
                                Text(
                                  'Cán bộ coi thi: ${examRoom.proctors.length} người',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Xóa'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteDialog(examRoom);
                              }
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
              examRoomLoaded: (_) => const SizedBox.shrink(),
              examRoomCreated: (_) => const SizedBox.shrink(),
              examRoomUpdated: (_) => const SizedBox.shrink(),
              examRoomDeleted: () => const SizedBox.shrink(),
              proctorsAssigned: (_) => const SizedBox.shrink(),
              proctorRemoved: (_) => const SizedBox.shrink(),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _cubit.loadExamRooms(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

