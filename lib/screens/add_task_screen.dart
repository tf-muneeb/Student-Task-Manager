import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'Medium';
  bool _isCompleted = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final Map<String, Color> _priorityColors = {
    'High': Colors.red,
    'Medium': Colors.orange,
    'Low': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Task title is required';
    if (value.trim().length < 3) return 'Title must be at least 3 characters';
    if (value.trim().length > 100) return 'Title must not exceed 100 characters';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Task description is required';
    if (value.trim().length < 5) return 'Description must be at least 5 characters';
    if (value.trim().length > 500) return 'Description must not exceed 500 characters';
    return null;
  }

  Future<void> _handleAddTask() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirestoreService.addTask(
        taskTitle: _titleController.text.trim(),
        taskDescription: _descriptionController.text.trim(),
        priority: _selectedPriority,
        isCompleted: _isCompleted,
      );
      if (!mounted) return;
      _showSuccessSnackBar('Task added successfully!');
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to add task. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : () {
              _titleController.clear();
              _descriptionController.clear();
              setState(() {
                _selectedPriority = 'Medium';
                _isCompleted = false;
              });
              _formKey.currentState?.reset();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear form',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 28),
                _buildForm(),
                const SizedBox(height: 28),
                _buildAddButton(),
                const SizedBox(height: 16),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_task_rounded,
                color: Color(0xFF4A90D9), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create a Task',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('Fill in the details below to add a new task.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Task Title', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            validator: _validateTitle,
            enabled: !_isLoading,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'e.g. Complete Math Assignment',
              prefixIcon: Icon(Icons.title_rounded, color: Color(0xFF4A90D9)),
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Task Description', isRequired: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            textInputAction: TextInputAction.done,
            validator: _validateDescription,
            enabled: !_isLoading,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'e.g. Solve exercises from Chapter 5...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.description_rounded, color: Color(0xFF4A90D9)),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Priority'),
          const SizedBox(height: 10),
          _buildPrioritySelector(),
          const SizedBox(height: 20),
          _buildFieldLabel('Status'),
          const SizedBox(height: 10),
          _buildStatusSelector(),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: _priorities.map((priority) {
        final color = _priorityColors[priority]!;
        final isSelected = _selectedPriority == priority;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.3),
                    width: isSelected ? 2 : 1),
              ),
              child: Column(
                children: [
                  Icon(
                    priority == 'High'
                        ? Icons.keyboard_double_arrow_up_rounded
                        : priority == 'Medium'
                        ? Icons.drag_handle_rounded
                        : Icons.keyboard_double_arrow_down_rounded,
                    color: isSelected ? Colors.white : color,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(priority,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isCompleted = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isCompleted
                    ? Colors.orange
                    : Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: !_isCompleted
                      ? Colors.orange
                      : Colors.orange.withOpacity(0.3),
                  width: !_isCompleted ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.pending_actions_rounded,
                      color: !_isCompleted ? Colors.white : Colors.orange,
                      size: 20),
                  const SizedBox(height: 4),
                  Text('Pending',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: !_isCompleted ? Colors.white : Colors.orange)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isCompleted = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isCompleted
                    ? Colors.green
                    : Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isCompleted
                      ? Colors.green
                      : Colors.green.withOpacity(0.3),
                  width: _isCompleted ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: _isCompleted ? Colors.white : Colors.green,
                      size: 20),
                  const SizedBox(height: 4),
                  Text('Completed',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isCompleted ? Colors.white : Colors.green)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
        if (isRequired)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleAddTask,
        icon: _isLoading
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Icon(Icons.add_rounded, size: 22),
        label: Text(_isLoading ? 'Adding Task...' : 'Add Task'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90D9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4A90D9)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Cancel',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90D9))),
      ),
    );
  }
}