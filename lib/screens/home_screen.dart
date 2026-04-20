import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'Student';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    Future.microtask(() =>
        context.read<TaskProvider>().resetAndListen());
  }

  Future<void> _loadUsername() async {
    final name = await ApiService.getUsername();
    final email = await ApiService.getEmail();
    if (mounted) {
      setState(() {
        if (name != null) _username = name;
        if (email != null) _email = email;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService.logout();
      if (!mounted) return;
      context.read<TaskProvider>().cancelStream();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleLogout();
        },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Manager'),
          automaticallyImplyLeading: false,
          actions: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, mode, __) => IconButton(
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
                icon: Icon(mode == ThemeMode.light
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded),
                tooltip: 'Toggle theme',
              ),
            ),
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _buildGreetingSection(),
                const SizedBox(height: 28),
                _buildStatsSection(),
                const SizedBox(height: 28),
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 16),
                _buildActionCards(context),
                const SizedBox(height: 28),
                _buildOverviewCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_username',
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.email_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              _email,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'What would you like to do today?',
          style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            _StatCard(
                label: 'Total',
                value: provider.totalTasks,
                color: const Color(0xFF4A90D9)),
            const SizedBox(width: 12),
            _StatCard(
                label: 'Done',
                value: provider.completedTasks,
                color: const Color(0xFF27AE60)),
            const SizedBox(width: 12),
            _StatCard(
                label: 'Pending',
                value: provider.pendingTasks,
                color: const Color(0xFFE67E22)),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.3));
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeActionCard(
            icon: Icons.add_task_rounded,
            label: 'Add Task',
            subtitle: 'Create a new task',
            color: const Color(0xFF4A90D9),
            onTap: () => Navigator.pushNamed(context, '/add-task'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HomeActionCard(
            icon: Icons.checklist_rounded,
            label: 'View Tasks',
            subtitle: 'See all your tasks',
            color: const Color(0xFF27AE60),
            onTap: () => Navigator.pushNamed(context, '/view-tasks'),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF6BB3F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stay Organized',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text(
                    'Manage your academic tasks efficiently with Firebase.',
                    style:
                    TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}