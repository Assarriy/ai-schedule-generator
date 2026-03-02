import 'package:flutter/material.dart';
import 'package:ai_schedule_generator/services/gemini_service.dart';
import 'schedule_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? priority;
  bool isLoading = false;

  // --- DEFINISI TEMA WARNA MODERN HINGGA ---
  final Color primaryGreen = const Color(0xFF10B981); // Emerald Green
  final Color darkGreen = const Color(0xFF047857);
  final Color softBackground = const Color(
    0xFFF4F9F4,
  ); // Putih kehijauan sangat soft
  final Color cardColor = Colors.white;
  final Color textDark = const Color(0xFF1F2937);

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        priority != null) {
      setState(() {
        tasks.add({
          "name": taskController.text,
          "priority": priority!,
          "duration": int.tryParse(durationController.text) ?? 30,
        });
      });
      taskController.clear();
      durationController.clear();
      setState(() => priority = null);
      FocusScope.of(context).unfocus();
    }
  }

  void _generateSchedule() async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠ Tambahkan tugas dulu, Bro!"),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      String schedule = await GeminiService.generateSchedule(tasks);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleResultScreen(scheduleResult: schedule),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              color: primaryGreen,
              size: 28,
            ), // Icon daun yang fresh
            const SizedBox(width: 8),
            Text(
              "AI Schedule",
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              "Daftar Tugas Kamu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildGenerateButton(),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.08), // Shadow kehijauan
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: taskController,
            decoration: _inputStyle("Nama Tugas", Icons.assignment_outlined),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: _inputStyle("Durasi (Min)", Icons.timer_outlined),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: priority,
                  decoration: _inputStyle("Prioritas", Icons.flag_outlined),
                  items: ["Tinggi", "Sedang", "Rendah"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => priority = val),
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen, // Warna tombol hijau
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Tambah ke Antrean",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (tasks.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: primaryGreen.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Belum ada tugas.\nSiap jadi produktif hari ini?",
                textAlign: TextAlign.center,
                style: TextStyle(color: textDark, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: _buildSwipeAction(),
          onDismissed: (_) => setState(() => tasks.removeAt(index)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColor(task['priority']).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt, color: _getColor(task['priority'])),
              ),
              title: Text(
                task['name'],
                style: TextStyle(fontWeight: FontWeight.w700, color: textDark),
              ),
              subtitle: Text(
                "${task['duration']} Menit • ${task['priority']}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Icon(Icons.drag_indicator, color: Colors.grey.shade400),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: isLoading ? null : _generateSchedule,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "GENERATE AI SCHEDULE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeAction() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444), // Red 500
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, size: 22, color: primaryGreen),
      filled: true,
      fillColor: const Color(0xFFF9FAFB), // Sangat light grey/white
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Color _getColor(String priority) {
    if (priority == "Tinggi") return const Color(0xFFEF4444); // Merah modern
    if (priority == "Sedang")
      return const Color(0xFFF59E0B); // Amber/Orange modern
    return primaryGreen; // Hijau
  }
}
