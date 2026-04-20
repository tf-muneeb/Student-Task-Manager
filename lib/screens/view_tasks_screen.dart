import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class ViewTasksScreen extends StatefulWidget {
  const ViewTasksScreen({super.key});

  @override
  State<ViewTasksScreen> createState() => _ViewTasksScreenState();
}

class _ViewTasksScreenState extends State<ViewTasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskProvider>().listenToTasks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            tooltip: 'Add Task',
            onPressed: () => Navigator.pushNamed(context, '/add-task'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-task'),
        backgroundColor: const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onChanged: (value) =>
            context.read<TaskProvider>().setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          suffixIcon: context.watch<TaskProvider>().searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded,
                color:
                Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () {
              _searchController.clear();
              context.read<TaskProvider>().setSearchQuery('');
            },
          )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF4A90D9), width: 1.5)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return _buildLoadingState();
        if (provider.tasks.isEmpty) return _buildEmptyState();
        final filtered = provider.filteredTasks;
        if (filtered.isEmpty) return _buildNoResultsState();
        return _buildTaskList(context, filtered, provider.tasks.length);
      },
    );
  }

  Widget _buildTaskList(
      BuildContext context, List tasks, int totalCount) {
    return Column(
      children: [
        _buildTaskCountHeader(tasks.length, totalCount),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.swipe_left_rounded,
                  size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Swipe left on a task to delete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                index: index,
                onEdit: () => Navigator.pushNamed(
                    context, '/edit-task',
                    arguments: task),
                onDelete: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCountHeader(int filtered, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Consumer<TaskProvider>(
            builder: (_, provider, __) => Text(
              provider.searchQuery.isEmpty
                  ? '$total task${total != 1 ? 's' : ''} total'
                  : '$filtered of $total task${total != 1 ? 's' : ''}',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4A90D9)),
          SizedBox(height: 16),
          Text('Loading tasks...',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt_rounded,
                  size: 64, color: Color(0xFF4A90D9)),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tasks Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              'Start by adding your first task.\nStay organized and productive!',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-task'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Your First Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No Results Found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'No tasks match "${provider.searchQuery}".',
                style: TextStyle(
                    fontSize: 14,
                    color:
                    Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}