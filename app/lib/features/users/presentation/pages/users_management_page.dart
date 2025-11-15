import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../bloc/users_cubit.dart';
import '../bloc/users_state.dart';
import '../widgets/user_card.dart';

@RoutePage()
class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  late final UsersCubit _cubit;
  String _selectedRole = 'ALL';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UsersCubit>();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (_selectedRole == 'ALL') {
      await _cubit.loadUsers();
    } else {
      await _cubit.loadUsersByRole(_selectedRole);
    }
  }

  void _onRoleChanged(String? role) {
    if (role != null && role != _selectedRole) {
      setState(() {
        _selectedRole = role;
        _searchQuery = '';
        _searchController.clear();
      });
      _loadUsers();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      _loadUsers();
    } else {
      _cubit.searchUsers(query);
    }
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateUserDialog(
        onUserCreated: () {
          context.showSnackBar('Tạo người dùng thành công');
          _loadUsers();
        },
      ),
    );
  }

  void _showEditUserDialog(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(
        user: user,
        onUserUpdated: () {
          context.showSnackBar('Cập nhật người dùng thành công');
          _loadUsers();
        },
      ),
    );
  }

  void _showDeleteConfirmation(dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng "${user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.deleteUser(user.id);
              context.showSnackBar('Đã xóa người dùng');
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
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Người dùng'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _onSearch,
                  ),
                  const SizedBox(height: 12),

                  // Role filter
                  Row(
                    children: [
                      const Text(
                        'Vai trò:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildRoleChip('ALL', 'Tất cả'),
                              const SizedBox(width: 8),
                              _buildRoleChip('STUDENT', 'Sinh viên'),
                              const SizedBox(width: 8),
                              _buildRoleChip('TEACHER', 'Giảng viên'),
                              const SizedBox(width: 8),
                              _buildRoleChip('PROCTOR', 'Giám thị'),
                              const SizedBox(width: 8),
                              _buildRoleChip('ADMIN', 'Quản trị'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Users list
            Expanded(
              child: BlocConsumer<UsersCubit, UsersState>(
                listener: (context, state) {
                  state.maybeWhen(
                    created: (_) {
                      Navigator.of(context).pop();
                      context.showSnackBar('Tạo người dùng thành công');
                    },
                    updated: (_) {
                      Navigator.of(context).pop();
                      context.showSnackBar('Cập nhật người dùng thành công');
                    },
                    deleted: () {
                      context.showSnackBar('Đã xóa người dùng');
                    },
                    error: (message) {
                      context.showSnackBar(message, isError: true);
                    },
                    orElse: () {},
                  );
                },
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(child: Text('Chưa có dữ liệu')),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    loaded: (users) {
                      if (users.isEmpty) {
                        return EmptyState(
                          icon: Icons.people_outlined,
                          title: _searchQuery.isEmpty
                              ? 'Chưa có người dùng'
                              : 'Không tìm thấy người dùng',
                          message: _searchQuery.isEmpty
                              ? 'Thêm người dùng mới'
                              : 'Thử tìm kiếm với từ khóa khác',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return UserCard(
                              id: user.id,
                              username: user.username,
                              fullName: user.fullName,
                              email: user.email,
                              phone: user.phone,
                              role: user.role.name,
                              isActive: user.isActive,
                              avatar: user.avatar,
                              onTap: () => _showEditUserDialog(user),
                              onEdit: () => _showEditUserDialog(user),
                              onDelete: () => _showDeleteConfirmation(user),
                              onToggleStatus: () => _cubit.toggleUserStatus(user.id),
                            );
                          },
                        ),
                      );
                    },
                    created: (_) => const SizedBox(),
                    updated: (_) => const SizedBox(),
                    deleted: () => const SizedBox(),
                    statusToggled: () => const SizedBox(),
                    error: (message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lỗi: $message'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUsers,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateUserDialog,
          icon: const Icon(Icons.add),
          label: const Text('Thêm người dùng'),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String value, String label) {
    final isSelected = _selectedRole == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onRoleChanged(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}

// Create User Dialog
class _CreateUserDialog extends StatefulWidget {
  final VoidCallback onUserCreated;

  const _CreateUserDialog({required this.onUserCreated});

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'STUDENT';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'roleIds': [_getRoleId(_selectedRole)],
      };

      context.read<UsersCubit>().createUser(data);
    }
  }

  int _getRoleId(String roleName) {
    switch (roleName) {
      case 'ADMIN':
        return 1;
      case 'TEACHER':
        return 2;
      case 'PROCTOR':
        return 3;
      case 'STUDENT':
        return 4;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo người dùng mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'STUDENT', child: Text('Sinh viên')),
                  DropdownMenuItem(value: 'TEACHER', child: Text('Giảng viên')),
                  DropdownMenuItem(value: 'PROCTOR', child: Text('Giám thị')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}

// Edit User Dialog
class _EditUserDialog extends StatefulWidget {
  final dynamic user;
  final VoidCallback onUserUpdated;

  const _EditUserDialog({
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      context.read<UsersCubit>().updateUser(widget.user.id, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật thông tin'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
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
          onPressed: _submit,
          child: const Text('Cập nhật'),
        ),
      ],
    );
  }
}

