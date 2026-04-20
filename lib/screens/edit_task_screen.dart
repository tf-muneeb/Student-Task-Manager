import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  bool _isLoading = false;
  bool _hasChanges = false;
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
    _titleController =
        TextEditingController(text: widget.task.taskTitle);
    _descriptionController =
        TextEditingController(text: widget.task.taskDescription);
    _selectedPriority = widget.task.priority;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final titleChanged =
        _titleController.text.trim() != widget.task.taskTitle.trim();
    final descChanged = _descriptionController.text.trim() !=
        widget.task.taskDescription.trim();
    final priorityChanged = _selectedPriority != widget.task.priority;
    final hasChanges = titleChanged || descChanged || priorityChanged;
    if (hasChanges != _hasChanges) setState(() => _hasChanges = hasChanges);
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
    if (value.trim().length > 100)
      return 'Title must not exceed 100 characters';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Task description is required';
    if (value.trim().length < 5)
      return 'Description must be at least 5 characters';
    if (value.trim().length > 500)
      return 'Description must not exceed 500 characters';
    return null;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Changes?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Keep Editing',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  Future<void> _handleUpdateTask() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      _showInfoSnackBar('No changes detected.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirestoreService.updateTask(
        taskId: widget.task.id,
        taskTitle: _titleController.text.trim(),
        taskDescription: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );
      if (!mounted) return;
      _showSuccessSnackBar('Task updated successfully!');
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to update task. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetToOriginal() {
    _titleController.text = widget.task.taskTitle;
    _descriptionController.text = widget.task.taskDescription;
    setState(() {
      _selectedPriority = widget.task.priority;
      _hasChanges = false;
    });
    _showInfoSnackBar('Reset to original values.');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red.shade600,
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
    ));
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.blueGrey.shade600,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldLeave = await _onWillPop();
          if (shouldLeave && mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Task'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              final shouldLeave = await _onWillPop();
              if (shouldLeave && mounted) Navigator.pop(context);
            },
          ),
          actions: [
            if (_hasChanges)
              IconButton(
                onPressed: _isLoading ? null : _resetToOriginal,
                icon: const Icon(Icons.restore_rounded),
                tooltip: 'Reset changes',
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
                  _buildOriginalPreviewCard(),
                  const SizedBox(height: 20),
                  _buildChangesIndicator(),
                  const SizedBox(height: 20),
                  _buildForm(),
                  const SizedBox(height: 28),
                  _buildUpdateButton(),
                  const SizedBox(height: 16),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOriginalPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.history_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text('Original Task',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          Text(widget.task.taskTitle,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(widget.task.taskDescription,
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildChangesIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _hasChanges
            ? const Color(0xFFFFF3CD)
            : const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _hasChanges
                ? const Color(0xFFFFECAA)
                : const Color(0xFFC3E6CB)),
      ),
      child: Row(children: [
        Icon(
            _hasChanges
                ? Icons.edit_note_rounded
                : Icons.check_circle_rounded,
            size: 18,
            color: _hasChanges
                ? const Color(0xFF856404)
                : const Color(0xFF155724)),
        const SizedBox(width: 10),
        Text(
            _hasChanges
                ? 'You have unsaved changes'
                : 'No changes made yet',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hasChanges
                    ? const Color(0xFF856404)
                    : const Color(0xFF155724))),
      ]),
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
              hintText: 'Enter updated task title',
              prefixIcon:
              Icon(Icons.title_rounded, color: Color(0xFF4A90D9)),
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
              hintText: 'Enter updated task description',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.description_rounded,
                    color: Color(0xFF4A90D9)),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Priority'),
          const SizedBox(height: 10),
          _buildPrioritySelector(),
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
            onTap: () {
              setState(() {
                _selectedPriority = priority;
                _hasChanges = true;
              });
            },
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

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
        if (isRequired)
          const Text(' *',
              style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleUpdateTask,
        icon: _isLoading
            ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Icon(Icons.save_rounded, size: 22),
        label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasChanges
              ? const Color(0xFF27AE60)
              : const Color(0xFF4A90D9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () async {
          final shouldLeave = await _onWillPop();
          if (shouldLeave && mounted) Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4A90D9)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
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