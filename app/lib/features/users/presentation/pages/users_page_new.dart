import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/user_model.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../bloc/users_cubit.dart';
import '../bloc/users_state.dart';
import '../widgets/user_item.dart';

@RoutePage()
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final UsersCubit _usersCubit;
  final _searchController = TextEditingController();
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _usersCubit = getIt<UsersCubit>();
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    await _usersCubit.loadUsers();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _usersCubit.loadUsers();
    } else {
      _usersCubit.searchUsers(query);
    }
  }

  List<UserModel> _getUsersByCurrentTab() {
    final index = _tabController.index;
    if (index == 0) return _allUsers; // ALL

    final roles = ['STUDENT', 'TEACHER', 'PROCTOR'];
    final role = roles[index - 1];

    return _allUsers.where((user) => user.role.name == role).toList();
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    String selectedRole = 'STUDENT';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm người dùng'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập *',
                  ),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Vui lòng nhập tên đăng nhập' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên *'),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Vui lòng nhập email';
                    if (!v!.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu *'),
                  obscureText: true,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Vui lòng nhập mật khẩu';
                    if (v!.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: const [
                    DropdownMenuItem(value: 'STUDENT', child: Text('Học sinh')),
                    DropdownMenuItem(
                      value: 'TEACHER',
                      child: Text('Giáo viên'),
                    ),
                    DropdownMenuItem(value: 'PROCTOR', child: Text('Giám thị')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _usersCubit.createUser({
                  'username': usernameController.text.trim(),
                  'fullName': fullNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'password': passwordController.text,
                  'role': selectedRole,
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa thông tin người dùng'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên *'),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Vui lòng nhập họ và tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Vui lòng nhập email';
                    if (!v!.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _usersCubit.updateUser(user.id, {
                  'fullName': fullNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa người dùng "${user.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _usersCubit.deleteUser(user.id);
              Navigator.pop(dialogContext);
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
      value: _usersCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý người dùng'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Học sinh'),
              Tab(text: 'Giáo viên'),
              Tab(text: 'Giám thị'),
            ],
            onTap: (_) => setState(() {}),
          ),
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
                  hintText: 'Tìm kiếm người dùng...',
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
              child: BlocConsumer<UsersCubit, UsersState>(
                listener: (context, state) {
                  state.when(
                    initial: () {},
                    loading: () {},
                    loaded: (users) {
                      setState(() {
                        _allUsers = users;
                      });
                    },
                    created: (user) {
                      context.showSnackBar(
                        'Đã thêm người dùng "${user.fullName}"',
                      );
                    },
                    updated: (user) {
                      context.showSnackBar(
                        'Đã cập nhật người dùng "${user.fullName}"',
                      );
                    },
                    deleted: () {
                      context.showSnackBar('Đã xóa người dùng');
                    },
                    statusToggled: () {
                      context.showSnackBar('Đã thay đổi trạng thái người dùng');
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

                  if (isLoading && _allUsers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final displayUsers = _getUsersByCurrentTab();

                  if (displayUsers.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline,
                      title: 'Chưa có người dùng',
                      message: 'Thêm người dùng đầu tiên',
                      actionText: 'Thêm người dùng',
                      onAction: _showAddUserDialog,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayUsers.length,
                      itemBuilder: (context, index) {
                        final user = displayUsers[index];
                        return UserItem(
                          fullName: user.fullName,
                          email: user.email,
                          role: user.role.name,
                          phone: user.phone,
                          isActive: true,
                          onTap: () {
                            context.showSnackBar('Chi tiết ${user.fullName}');
                          },
                          onEdit: () => _showEditUserDialog(user),
                          onDelete: () => _showDeleteConfirmation(user),
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
          onPressed: _showAddUserDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Thêm người dùng'),
        ),
      ),
    );
  }
}
