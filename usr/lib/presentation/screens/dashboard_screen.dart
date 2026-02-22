import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:couldai_user_app/core/services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Monitoreo'),
        actions: [
          Center(child: Text('Hola, ${user?.username ?? "Usuario"}  ')),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0056D2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text('Menú Principal', style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tablero General'),
              selected: true,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.edit_document),
              title: const Text('Nuevo Registro'),
              onTap: () {
                // Navegar a formulario
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Consultar Registros'),
              onTap: () {},
            ),
            const Divider(),
            if (authService.isAnalyst) ...[
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text('ADMINISTRACIÓN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Consolidar Maestro'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Gestión de Licencias'),
                onTap: () {},
              ),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjetas de Resumen
            Row(
              children: [
                _SummaryCard(
                  title: 'Registros Totales',
                  value: '1,245',
                  icon: Icons.folder_shared,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _SummaryCard(
                  title: 'Adherencia Promedio',
                  value: '84.2%',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _SummaryCard(
                  title: 'Alertas Críticas',
                  value: '12',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Gráficos
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Adherencia por Curso de Vida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  barGroups: [
                                    _makeGroupData(0, 85, '1ra Infancia'),
                                    _makeGroupData(1, 78, 'Infancia'),
                                    _makeGroupData(2, 65, 'Adolescencia'),
                                    _makeGroupData(3, 90, 'Juventud'),
                                    _makeGroupData(4, 82, 'Adultez'),
                                    _makeGroupData(5, 70, 'Vejez'),
                                  ],
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const titles = ['1ra Inf', 'Inf', 'Adol', 'Juv', 'Adult', 'Vejez'];
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cumplimiento Global', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(value: 75, color: Colors.green, title: 'Cumple', radius: 50),
                                    PieChartSectionData(value: 25, color: Colors.red, title: 'No Cumple', radius: 50),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 80 ? Colors.green : (y > 60 ? Colors.orange : Colors.red),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
