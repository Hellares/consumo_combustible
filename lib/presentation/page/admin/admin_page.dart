import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/presentation/page/licencias/licencias_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget _currentPage = const AdminDashboard();
  String _currentTitle = 'Panel de Administración';

  void _navigateToPage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
    Navigator.pop(context); // Cierra el drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTitle(_currentTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<String>(_currentTitle),
          child: _currentPage,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 240,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                AppTitle('Administración', color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  'Gestión del Sistema',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Panel Principal',
            onTap: () => _navigateToPage(
              const AdminDashboard(),
              'Panel de Administración',
            ),
          ),
          const Divider(),
          _buildDrawerSection('Gestión de Recursos'),
          _buildDrawerItem(
            icon: Icons.local_shipping,
            title: 'Unidades',
            subtitle: 'Registrar y gestionar vehículos',
            onTap: () => _navigateToPage(
              const UnidadesManagementPage(),
              'Gestión de Unidades',
            ),
          ),
          _buildDrawerItem(
          icon: Icons.badge, // Icono de licencia
          title: 'Licencias de Conducir',
          subtitle: 'Gestionar licencias de conductores',
          onTap: () {
            Navigator.pop(context); // Cierra el drawer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LicenciasPage(),
              ),
            );
          },
        ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Usuarios',
            subtitle: 'Gestionar usuarios del sistema',
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushNamed(context, 'users');
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Conductores',
            subtitle: 'Registrar y gestionar conductores',
            onTap: () => _navigateToPage(
              const ConductoresManagementPage(),
              'Gestión de Conductores',
            ),
          ),
          _buildDrawerItem(
            icon: Icons.local_gas_station,
            title: 'Grifos',
            subtitle: 'Registrar y gestionar grifos',
            onTap: () => _navigateToPage(
              const GrifosManagementPage(),
              'Gestión de Grifos',
            ),
          ),
          const Divider(),
          _buildDrawerSection('Configuración'),
          _buildDrawerItem(
            icon: Icons.location_city,
            title: 'Zonas y Sedes',
            subtitle: 'Gestionar ubicaciones',
            onTap: () => _navigateToPage(
              const ZonasSedesManagementPage(),
              'Zonas y Sedes',
            ),
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Ajustes del sistema',
            onTap: () => _navigateToPage(
              const ConfiguracionPage(),
              'Configuración',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700, size: 20,),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: onTap,
    );
  }
}

// ============================================
// DASHBOARD PRINCIPAL
// ============================================
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSubtitle('Resumen del Sistema'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  icon: Icons.local_shipping,
                  title: 'Unidades',
                  count: '24',
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  icon: Icons.person,
                  title: 'Conductores',
                  count: '18',
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  icon: Icons.local_gas_station,
                  title: 'Grifos',
                  count: '8',
                  color: Colors.orange,
                ),
                _buildDashboardCard(
                  icon: Icons.location_city,
                  title: 'Zonas',
                  count: '5',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PÁGINAS PLACEHOLDER (Para implementar después)
// ============================================
class UnidadesManagementPage extends StatelessWidget {
  const UnidadesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(
      icon: Icons.local_shipping,
      title: 'Gestión de Unidades',
      description: 'Aquí podrás registrar y gestionar las unidades vehiculares',
    );
  }
}

class ConductoresManagementPage extends StatelessWidget {
  const ConductoresManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(
      icon: Icons.person,
      title: 'Gestión de Conductores',
      description: 'Aquí podrás registrar y gestionar los conductores',
    );
  }
}

class GrifosManagementPage extends StatelessWidget {
  const GrifosManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(
      icon: Icons.local_gas_station,
      title: 'Gestión de Grifos',
      description: 'Aquí podrás registrar y gestionar los grifos',
    );
  }
}

class ZonasSedesManagementPage extends StatelessWidget {
  const ZonasSedesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(
      icon: Icons.location_city,
      title: 'Gestión de Zonas y Sedes',
      description: 'Aquí podrás gestionar las zonas y sedes',
    );
  }
}

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(
      icon: Icons.settings,
      title: 'Configuración del Sistema',
      description: 'Aquí podrás ajustar la configuración del sistema',
    );
  }
}

Widget _buildPlaceholder({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Agregar Nuevo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}