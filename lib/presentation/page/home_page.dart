import 'package:consumo_combustible/core/custom_navigator_bar/curved_navigation_bar.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/logout/logout_button.dart';
import 'package:consumo_combustible/presentation/page/location/current_location_widget.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/create_ticket_page.dart';
import 'package:flutter/material.dart';

class HomePageAlternative extends StatefulWidget {
  const HomePageAlternative({super.key});

  @override
  State<HomePageAlternative> createState() => _HomePageAlternativeState();
}

class _HomePageAlternativeState extends State<HomePageAlternative>
    with TickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;

  // Lista de páginas que se mostrarán
  final List<Widget> _pages = [
    const HomePageContent(),
    const SearchPage(),
    const CreateTicketPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  // Lista de títulos para el AppBar
  final List<String> _titles = [
    'Inicio',
    'Buscar',
    'Crear_Ticket',
    'Notificaciones',
    'Perfil',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Iniciar la animación
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar.withUser(
        title: _titles[_currentIndex],
        logoPath: "assets/img/6.svg",
        showLogo: true,
        isLottieLogo: false,
      ),
      // ✅ MOSTRAR FAB solo si NO está en la página de ticket
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, 'location-selection');
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Ubicación'),
            )
          : null,
      body: Column(
        children: [
          // ✅ MOSTRAR CurrentLocationWidget solo si NO está en ticket
          if (_currentIndex != 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CurrentLocationWidget(),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_currentIndex),
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
          Icon(Icons.receipt_long, size: 30, color: Colors.white),
          Icon(Icons.notifications, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Colors.blue,
        buttonBackgroundColor: Colors.blue.shade700,
        backgroundColor: Colors.grey.shade100,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

// Las demás clases permanecen igual...
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¡Bienvenido a la página de inicio!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Esta es tu página principal',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          LogoutButton.profile(
            text: 'Cerrar Sesión',
            onLogoutSuccess: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                'login',
                (route) => false,
              );
            },
            // onLogoutSuccess: (){},
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Página de Búsqueda',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Aquí puedes buscar contenido',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Notificaciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Aquí verás tus notificaciones',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mi Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Gestiona tu cuenta y configuración',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configuración'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar a configuración
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Ayuda'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar a ayuda
                  },
                ),
                const Divider(height: 1),
                // LogoutButton.drawer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class MarketPage extends StatelessWidget {
//   const MarketPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircleAvatar(
//             radius: 50,
//             backgroundColor: Colors.blue,
//             child: Icon(Icons.shopping_cart_checkout, size: 60, color: Colors.white),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'Tiendas',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Conecta con tus tiendas favoritas',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           const SizedBox(height: 30),
//           Card(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.settings),
//                   title: const Text('Configuración'),
//                   trailing: const Icon(Icons.arrow_forward_ios),
//                   onTap: () {
//                     // Navegar a configuración
//                   },
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   leading: const Icon(Icons.help),
//                   title: const Text('Ayuda'),
//                   trailing: const Icon(Icons.arrow_forward_ios),
//                   onTap: () {
//                     // Navegar a ayuda
//                   },
//                 ),
//                 const Divider(height: 1),
//                 // LogoutButton.drawer(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
