// ✅ lib/presentation/page/user/widgets/user_search_dialog.dart
// Dialog de búsqueda de usuarios con filtro de roles

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_search_field.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/models/user_selection.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';
import 'package:consumo_combustible/presentation/page/user/widgets/user_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSearchDialog extends StatefulWidget {
  final String? roleFilter; // Ej: 'CONDUCTOR', 'ADMIN', null = todos
  final String title;

  const UserSearchDialog({
    super.key,
    this.roleFilter,
    this.title = 'Buscar Usuario',
  });

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchType = 'nombre'; // 'nombre' o 'dni'
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Cargar usuarios iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const GetUsers());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<UserBloc>().state;
    if (state is! UserLoaded) return;

    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!state.isLoadingMore && state.isLoadingMore) {
        _currentPage++;
        context.read<UserBloc>().add(GetUsers(page: _currentPage));
      }
    }
  }

  List<User> _filterUsersByRole(List<User> users) {
    if (widget.roleFilter == null) return users;

    return users.where((user) {
      if (!user.hasRoles) return false;
      
      // Verificar si el usuario tiene el rol especificado
      if (user.roles is List) {
        final roles = user.roles as List;
        return roles.any((role) {
          final roleName = role.nombre?.toString().toUpperCase() ?? '';
          return roleName == widget.roleFilter!.toUpperCase();
        });
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search section
            _buildSearchSection(),
            
            // User list
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading && _currentPage == 1) {
                    return _buildLoadingState();
                  }
                  
                  if (state is UserError) {
                    return _buildErrorState(state.message);
                  }
                  
                  if (state is UserLoaded) {
                    // Filtrar usuarios por rol si es necesario
                    final filteredUsers = _filterUsersByRole(state.displayUsers);
                    
                    if (filteredUsers.isEmpty) {
                      return _buildEmptyState(state.isSearching);
                    }
                    
                    return _buildUserList(filteredUsers, state.isLoadingMore);
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: AppColors.blue3,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_search_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.roleFilter != null)
                  Text(
                    'Rol: ${widget.roleFilter}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white,size: 20,),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo de búsqueda
          CustomSearchField(
            controller: _searchController,
            hintText: _searchType == 'nombre'
                ? 'Buscar por nombre...'
                : 'Buscar por DNI...',
            borderColor: AppColors.blue3,
            height: 35,
            onChanged: (query) {
              context.read<UserBloc>().add(
                FilterUsers(query, searchType: _searchType),
              );
            },
            onClear: () {
              context.read<UserBloc>().add(
                FilterUsers('', searchType: _searchType),
              );
            },
            debounceDelay: const Duration(milliseconds: 300),
          ),
          
          const SizedBox(height: 12),
          
          // Chips de filtro
          Row(
            children: [
              Text(
                'Buscar por:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip('nombre', 'Nombre'),
              const SizedBox(width: 8),
              _buildFilterChip('dni', 'DNI'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _searchType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _searchType = value);
        if (_searchController.text.isNotEmpty) {
          context.read<UserBloc>().add(
            FilterUsers(_searchController.text, searchType: value),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue3 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.blue3 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(List<User> users, bool isLoadingMore) {
    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        context.read<UserBloc>().add(const GetUsers());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: users.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = users[index];
          return UserListItem(
            user: user,
            showRoles: true,
            onTap: () {
              final selection = UserSelection.fromUser(user);
              Navigator.pop(context, selection);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando usuarios...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _currentPage = 1;
                context.read<UserBloc>().add(const GetUsers());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue3,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching 
                    ? Icons.search_off_rounded 
                    : Icons.people_outline_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'No se encontraron usuarios'
                  : widget.roleFilter != null
                      ? 'No hay usuarios con rol ${widget.roleFilter}'
                      : 'No hay usuarios registrados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Intenta con otro término de búsqueda'
                  : 'Aún no hay usuarios disponibles',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}