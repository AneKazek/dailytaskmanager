import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateTaskScreen extends StatefulWidget { // Screen C
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Design', 'Meeting', 'Coding', 'BDE', 'Testing', 'Quick call'];
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first; // Default to 'Design'
    _nameController.addListener(_checkFormValidity);
    _dateController.addListener(_checkFormValidity);
    _startTimeController.addListener(_checkFormValidity);
    _endTimeController.addListener(_checkFormValidity);
    // Set initial hint text via InputDecoration, not controller's text for placeholders
  }

  void _checkFormValidity() {
    if (!mounted) return;
    final nameValid = _nameController.text.isNotEmpty;
    final dateValid = _dateController.text.isNotEmpty; // Basic check, real validation is more complex
    final startTimeValid = _startTimeController.text.isNotEmpty;
    final endTimeValid = _endTimeController.text.isNotEmpty;
    
    // Check if all required fields are filled
    final bool currentValidity = nameValid && dateValid && startTimeValid && endTimeValid;

    if (_isFormValid != currentValidity) {
      setState(() {
        _isFormValid = currentValidity;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      // Process task creation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task "${_nameController.text}" created!')),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close screen after creation
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const gradientStartColor = Color(0xFF8A2BE2); // Purple
    const gradientEndColor = Color(0xFF4B0082);   // Dark Blue

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStartColor, gradientEndColor], // Gradient purple background in app bar area
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create a Task', // White, 20 sp
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true, // Mockup title is centered
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), // Search icon from mockup
            onPressed: () {
              // TODO: Handle search action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // White rounded rectangle for form fields
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0), // Top-corner radius 24 dp
                  topRight: Radius.circular(24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, -2) // Shadow for the top edge of the white card
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0), // Overall padding for the form area
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(label: 'Name', controller: _nameController, hint: 'Design Changes', validator: (value) => value == null || value.isEmpty ? 'Name cannot be empty' : null),
                      const SizedBox(height: 16),
                      _buildReadOnlyTextField(label: 'Date', controller: _dateController, hint: 'Oct 4, 2020', onTap: _selectDate, validator: (value) => value == null || value.isEmpty ? 'Date cannot be empty' : null),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildReadOnlyTextField(label: 'Start Time', controller: _startTimeController, hint: '01:22 pm', onTap: () => _selectTime(context, _startTimeController), validator: (value) => value == null || value.isEmpty ? 'Start Time cannot be empty' : null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildReadOnlyTextField(label: 'End Time', controller: _endTimeController, hint: '03:20 pm', onTap: () => _selectTime(context, _endTimeController), validator: (value) => value == null || value.isEmpty ? 'End Time cannot be empty' : null)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Description', controller: _descriptionController, hint: 'Lorem ipsum dolor sit amet, er adipiscing elit, sed dianummy nibh euismod...', maxLines: 4),
                      const SizedBox(height: 24),
                      Text(
                        'Category',
                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryPills(theme, colorScheme),
                      const SizedBox(height: 32), // Space before the main button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0), // 16 dp margins globally
        child: ElevatedButton(
          onPressed: _isFormValid ? _createTask : null, // Disable button until form is valid
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding to allow gradient to fill
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // 16 dp radius
            ),
            elevation: 2, // Subtle Material elevation
            // backgroundColor will be handled by Ink's decoration or a solid color if disabled
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _isFormValid 
                ? const LinearGradient(
                    colors: [gradientStartColor, gradientEndColor], // purple->blue gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null, // No gradient when disabled
              color: !_isFormValid ? Colors.grey[300] : null, // Solid color when disabled
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 50, // Specify height for the button
              child: Text(
                'CREATE TASK', // White uppercase text
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isFormValid ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87), // Input text style
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(color: Colors.grey[500]), // Placeholder text style
            filled: true,
            fillColor: Colors.grey[100], // Light grey fill for text fields
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none, // No border by default
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), // Primary color border on focus
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjusted padding
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildReadOnlyTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87), // Input text style
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(color: Colors.grey[500]), // Placeholder text style
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjusted padding
            suffixIcon: (label == 'Date' || label.contains('Time')) 
                        ? Icon(label == 'Date' ? Icons.calendar_today_outlined : Icons.access_time_outlined, size: 20, color: Colors.grey[600]) 
                        : null,
          ),
          onTap: onTap,
          validator: validator,
        ),
      ],
    );
  }

  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty 
          ? (DateTime.tryParse(_dateController.text) ?? DateTime.now()) 
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) {
      // Using intl for formatting is recommended: DateFormat.yMMMd().format(picked)
      // For simplicity, using a basic format. Mockup shows "Oct 4, 2020"
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      _dateController.text = "${months[picked.month - 1]} ${picked.day}, ${picked.year}";
      _checkFormValidity();
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        if (parts[1].toLowerCase() == 'pm' && hour != 12) hour += 12;
        if (parts[1].toLowerCase() == 'am' && hour == 12) hour = 0; // Midnight case
        initialTime = TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        // Ignore parsing error, use current time
      }
    }

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
         return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white, 
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!)
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!)
              ),
              dayPeriodColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Theme.of(context).colorScheme.primary : Colors.grey[200]!),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Colors.white : Theme.of(context).colorScheme.primary),
              dialHandColor: Theme.of(context).colorScheme.primary,
              dialBackgroundColor: Colors.grey[200],
              entryModeIconColor: Theme.of(context).colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      controller.text = picked.format(context); // e.g., "1:22 PM"
      _checkFormValidity();
    }
  }

  Widget _buildCategoryPills(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8.0, // Horizontal spacing between pills
      runSpacing: 8.0, // Vertical spacing if pills wrap
      children: _categories.map((category) {
        bool isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(
            category,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: isSelected ? Colors.white : colorScheme.primary, // White text on selected, primary on unselected
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) { 
              setState(() {
                _selectedCategory = category;
              });
            }
          },
          backgroundColor: isSelected ? colorScheme.primary : Colors.white, // Primary fill for selected
          selectedColor: colorScheme.primary, // Primary fill for selected
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Pill shape
            side: BorderSide(
              color: isSelected ? colorScheme.primary : (Colors.grey[300] ?? Colors.grey), // Border for unselected
              width: 1.5,
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Padding inside the pill
          pressElevation: 0,
        );
      }).toList(),
    );
  }
}