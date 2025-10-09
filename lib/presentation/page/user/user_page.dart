// import 'package:consumo_combustible/core/theme/app_colors.dart';
// import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
// import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_search_field.dart';
// import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
// import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
// import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class UserPage extends StatefulWidget {
//   const UserPage({super.key});

//   @override
//   State<UserPage> createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   int _currentPage = 1;
//   String _searchType = 'nombre';

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<UserBloc>().add(const GetUsers());
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     final state = context.read<UserBloc>().state;
//     if (state is! UserLoaded) return;

//     if (state.isSearching || state.isLoadingMore) return;
//     if (!state.meta.hasNext) return;

//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent * 0.9) {
//       _currentPage++;
//       context.read<UserBloc>().add(GetUsers(
//         page: _currentPage,
//         isLoadMore: true,
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: SmartAppBar(
//         title: 'Usuarios',
//         showUserInfo: true,
//         logoPath: "assets/img/6.svg",
//       ),
//       body: BlocBuilder<UserBloc, UserState>(
//         builder: (context, state) {
//           return Column(
//             children: [
//               _buildModernSearchSection(context),
              
//               if (state is UserLoading && state.isFirstLoad)
//                 const Expanded(
//                   child: Center(child: CircularProgressIndicator()),
//                 )
//               else if (state is UserError)
//                 Expanded(child: _buildErrorState(state))
//               else if (state is UserLoaded)
//                 Expanded(
//                   child: Column(
//                     children: [
//                       _buildUserStats(state),
//                       Expanded(
//                         child: state.displayUsers.isEmpty
//                             ? _buildEmptyState(state.isSearching)
//                             : _buildUserList(state),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 const Expanded(
//                   child: Center(child: Text('No hay usuarios')),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildModernSearchSection(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // CustomSearchField con todas las características
//                 CustomSearchField(                  
//                   controller: _searchController,
//                   hintText: _searchType == 'nombre' 
//                       ? 'Buscar por nombre...' 
//                       : 'Buscar por DNI...',
//                   borderColor: AppColors.blue3,
//                   height: 35,
//                   onChanged: (query) {
//                     context.read<UserBloc>().add(
//                       FilterUsers(query, searchType: _searchType),
//                     );
//                   },
//                   onClear: () {
//                     context.read<UserBloc>().add(
//                       FilterUsers('', searchType: _searchType),
//                     );
//                   },
//                   debounceDelay: const Duration(milliseconds: 300),
                  
//                 ),
                
//                 const SizedBox(height: 10),
                
//                 // Chips de filtro modernos
//                 Row(
//                   children: [
//                     Text(
//                       'Buscar por:',
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700],
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             _buildModernFilterChip(
//                               type: 'nombre',
//                               label: 'Nombre',
//                               icon: Icons.person_outline_rounded,
//                             ),
//                             const SizedBox(width: 8),
//                             _buildModernFilterChip(
//                               type: 'dni',
//                               label: 'DNI',
//                               icon: Icons.badge_outlined,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernFilterChip({
//     required String type,
//     required String label,
//     required IconData icon,
//   }) {
//     final isSelected = _searchType == type;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeInOut,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             setState(() {
//               _searchType = type;
//             });
//             context.read<UserBloc>().add(
//               FilterUsers(_searchController.text, searchType: type),
//             );
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 5,
//             ),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? LinearGradient(
//                       colors: [
//                         Colors.blue[600]!,
//                         Colors.blue[700]!,
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                   : null,
//               color: isSelected ? null : Colors.grey[100],
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(
//                 color: isSelected 
//                     ? Colors.blue[700]! 
//                     : Colors.grey[300]!,
//                 width: isSelected ? 0 : 1,
//               ),
//               boxShadow: isSelected
//                   ? [
//                       BoxShadow(
//                         color: Colors.blue.withValues(alpha: 0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   icon,
//                   size: 14,
//                   color: isSelected ? Colors.white : Colors.grey[700],
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                     color: isSelected ? Colors.white : Colors.grey[700],
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//                 if (isSelected) ...[
//                   const SizedBox(width: 4),
//                   Icon(
//                     Icons.check_circle_rounded,
//                     size: 10,
//                     color: Colors.white,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserStats(UserLoaded state) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.blue[50]?.withValues(alpha: 0.3),
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey[200]!,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 state.isSearching ? Icons.search_rounded : Icons.people_rounded,
//                 size: 16,
//                 color: Colors.blue[700],
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 state.isSearching
//                     ? 'Resultados: ${state.displayUsers.length}'
//                     : 'Total: ${state.meta.total} usuarios',
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.grey[800],
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           if (!state.isSearching)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.blue[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 'Pág. ${state.currentPage}/${state.meta.totalPages}',
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.blue[900],
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(UserError state) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.error_outline_rounded,
//                 size: 56,
//                 color: Colors.red[400],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Oops! Algo salió mal',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               state.message,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 _currentPage = 1;
//                 context.read<UserBloc>().add(const GetUsers());
//               },
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Reintentar'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(bool isSearching) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               isSearching
//                   ? 'No se encontraron usuarios'
//                   : 'No hay usuarios registrados',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isSearching
//                   ? 'Intenta con otro término de búsqueda'
//                   : 'Aún no hay usuarios en el sistema',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildUserList(UserLoaded state) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         _currentPage = 1;
//         context.read<UserBloc>().add(const GetUsers());
//       },
//       child: ListView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.all(14),
//         itemCount: state.displayUsers.length + (state.isLoadingMore ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index == state.displayUsers.length) {
//             return Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//                 ),
//               ),
//             );
//           }

//           final user = state.displayUsers[index];
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color: Colors.grey[200]!,
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.04),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ListTile(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 3,
//               ),
//               leading: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[400]!, Colors.blue[600]!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.blue.withValues(alpha: 0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Text(
//                     user.nombres.isNotEmpty ? user.nombres[0].toUpperCase() : '?',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//               title: Text(
//                 '${user.nombres} ${user.apellidos}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 11,
//                 ),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       Icon(Icons.phone_android_sharp, size: 14, color: Colors.grey[600]),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           user.telefono,
//                           style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.badge_outlined, size: 14, color: Colors.grey[600]),
//                       const SizedBox(width: 6),
//                       Text(
//                         'DNI: ${user.dni}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                   if (user.hasRoles) ...[
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 6,
//                       runSpacing: 4,
//                       children: user.simpleRoles.map((role) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [Colors.blue[50]!, Colors.blue[100]!],
//                             ),
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(
//                               color: Colors.blue[200]!,
//                               width: 1,
//                             ),
//                           ),
//                           child: Text(
//                             role.nombre,
//                             style: TextStyle(
//                               fontSize: 8,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blue[800],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ],
//               ),
//               trailing: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: user.activo 
//                       ? Colors.green[50] 
//                       : Colors.red[50],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   user.activo 
//                       ? Icons.check_circle_rounded 
//                       : Icons.cancel_rounded,
//                   color: user.activo ? Colors.green[600] : Colors.red[600],
//                   size: 18,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_search_field.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';
import 'package:consumo_combustible/presentation/page/user/widgets/register_user_dialog.dart';
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
  String _searchType = 'nombre';

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

    if (state.isSearching || state.isLoadingMore) return;
    if (!state.meta.hasNext) return;

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
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Usuarios',
        showUserInfo: true,
        logoPath: "assets/img/6.svg",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterDialog(context),
        backgroundColor: Colors.blue[600],
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserRegisterSuccess) {
            SnackBarHelper.showSuccess(
              context,
              '✓ Usuario registrado exitosamente',
              // Icons.check_circle,
              // Colors.green,
            );
          } else if (state is UserRegisterError) {
            SnackBarHelper.showError(
              context,
              state.message,
              // Icons.error_outline,
              // Colors.red,
            );
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildModernSearchSection(context),
                
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
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RegisterUserDialog(
        onRegister: (request) async {
          // Cerrar el diálogo
          Navigator.pop(dialogContext);

          // Mostrar mensaje de cargando
          SnackBarHelper.showSuccess(
            context,
            'Registrando usuario...',
            // Icons.hourglass_empty,
            // Colors.blue,
          );

          // Llamar al evento de registro
          context.read<UserBloc>().add(RegisterUser(request));
        },
      ),
    );
  }

  Widget _buildModernSearchSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CustomSearchField con todas las características
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
                
                const SizedBox(height: 10),
                
                // Chips de filtro modernos
                Row(
                  children: [
                    Text(
                      'Buscar por:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildModernFilterChip(
                              type: 'nombre',
                              label: 'Nombre',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildModernFilterChip(
                              type: 'dni',
                              label: 'DNI',
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _searchType == type;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _searchType = type;
            });
            context.read<UserBloc>().add(
              FilterUsers(_searchController.text, searchType: type),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[700]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected 
                    ? Colors.blue[700]! 
                    : Colors.grey[300]!,
                width: isSelected ? 0 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    letterSpacing: 0.2,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(UserLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                state.isSearching ? Icons.search_rounded : Icons.people_rounded,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                state.isSearching
                    ? 'Resultados: ${state.displayUsers.length}'
                    : 'Total: ${state.meta.total} usuarios',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!state.isSearching)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Pág. ${state.currentPage}/${state.meta.totalPages}',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.people_outline_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? 'No se encontraron usuarios'
                  : 'No hay usuarios registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Intenta con otro término de búsqueda'
                  : 'Aún no hay usuarios en el sistema',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(14),
        itemCount: state.displayUsers.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.displayUsers.length) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
            );
          }

          final user = state.displayUsers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 3,
              ),
              leading: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.nombres.isNotEmpty ? user.nombres[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              title: Text(
                '${user.nombres} ${user.apellidos}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone_android_sharp, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.telefono,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        'DNI: ${user.dni}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (user.hasRoles) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: user.simpleRoles.map((role) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.blue[100]!],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            role.nombre,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: user.activo 
                      ? Colors.green[50] 
                      : Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  user.activo 
                      ? Icons.check_circle_rounded 
                      : Icons.cancel_rounded,
                  color: user.activo ? Colors.green[600] : Colors.red[600],
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}