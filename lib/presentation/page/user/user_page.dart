import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  String _searchType = 'nombre'; // 'nombre' o 'dni'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const GetUsers());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<UserBloc>().state;
    if (state is! UserLoaded) return;

    // Don't paginate when searching or already loading
    if (state.isSearching || state.isLoadingMore) return;

    // Check if there are more pages
    if (!state.meta.hasNext) return;

    // Check if we're near the bottom (90% scrolled)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _currentPage++;
      context.read<UserBloc>().add(GetUsers(
        page: _currentPage,
        isLoadMore: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar(
        title: 'Usuarios',
        showUserInfo: true,
        logoPath: "assets/img/6.svg",
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Column(
            children: [
              // Barra de búsqueda siempre visible
              _buildSearchSection(context),
              
              // Contenido según el estado
              if (state is UserLoading && state.isFirstLoad)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is UserError)
                Expanded(child: _buildErrorState(state))
              else if (state is UserLoaded)
                Expanded(
                  child: Column(
                    children: [
                      _buildUserStats(state),
                      Expanded(
                        child: state.displayUsers.isEmpty
                            ? _buildEmptyState(state.isSearching)
                            : _buildUserList(state),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(
                  child: Center(child: Text('No hay usuarios')),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search type selector
          Row(
            children: [
              Expanded(
                child: _buildSearchTypeChip('nombre', 'Nombre'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSearchTypeChip('dni', 'DNI'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: _searchType == 'nombre' 
                  ? 'Buscar por nombre...' 
                  : 'Buscar por DNI...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                        context.read<UserBloc>().add(
                          FilterUsers('', searchType: _searchType),
                        );
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: const TextStyle(fontSize: 14),
            ),
            onChanged: (query) {
              setState(() {}); // Para actualizar el botón de limpiar
              context.read<UserBloc>().add(
                FilterUsers(query, searchType: _searchType),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeChip(String type, String label) {
    final isSelected = _searchType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _searchType = type;
        });
        // Aplicar filtro con el nuevo tipo
        context.read<UserBloc>().add(
          FilterUsers(_searchController.text, searchType: type),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'nombre' ? Icons.person : Icons.badge,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(UserLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.isSearching
                ? 'Resultados: ${state.displayUsers.length} de ${state.users.length}'
                : 'Total: ${state.meta.total} usuarios',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!state.isSearching)
            Text(
              'Página ${state.currentPage} de ${state.meta.totalPages}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _currentPage = 1;
              context.read<UserBloc>().add(const GetUsers());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'No se encontraron usuarios'
                : 'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserList(UserLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        context.read<UserBloc>().add(const GetUsers());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.displayUsers.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom when loading more
          if (index == state.displayUsers.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = state.displayUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  user.nombres.isNotEmpty ? user.nombres[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${user.nombres} ${user.apellidos}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.badge, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'DNI: ${user.dni}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  if (user.hasRoles) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: user.simpleRoles.map((role) {
                        return Chip(
                          label: Text(
                            role.nombre,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.blue[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              trailing: Icon(
                user.activo ? Icons.check_circle : Icons.cancel,
                color: user.activo ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}
