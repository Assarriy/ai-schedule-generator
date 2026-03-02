import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// CLASS TableBuilder SUDAH DIHAPUS KARENA TIDAK DIPERLUKAN

class ScheduleResultScreen extends StatelessWidget {
  final String scheduleResult;
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  final Color primaryGreen = const Color(0xFF10B981);
  final Color darkGreen = const Color(0xFF047857);
  final Color softBackground = const Color(0xFFF4F9F4);
  final Color textDark = const Color(0xFF1F2937);

  Future<void> _exportToCalendar(BuildContext context) async {
    final String encodedDetails = Uri.encodeComponent(scheduleResult);
    final String encodedTitle = Uri.encodeComponent("Jadwal AI Generator");

    final Uri url = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$encodedTitle&details=$encodedDetails',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Gagal membuka $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Tidak dapat membuka kalender")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      appBar: AppBar(
        title: const Text(
          "Hasil Jadwal Optimal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: "Salin Jadwal",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: scheduleResult));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Jadwal berhasil disalin!"),
                  backgroundColor: darkGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: darkGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Jadwal ini disusun otomatis oleh AI berdasarkan prioritas Anda.",
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // WIDGET MARKDOWN SUDAH DIPERBAIKI
                    child: Markdown(
                      data: scheduleResult,
                      selectable: true,
                      padding: const EdgeInsets.all(20),
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: textDark,
                        ),
                        h1: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                        h2: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                        h3: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                        tableBorder: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        tableHeadAlign: TextAlign.center,
                        tablePadding: const EdgeInsets.all(12),
                        tableCellsPadding: const EdgeInsets.all(12),
                      ),
                      // HAPUS builders: {'table': TableBuilder()} di sini
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.refresh, color: primaryGreen),
                  label: Text(
                    "Buat Jadwal Baru",
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryGreen, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportToCalendar(context),
        icon: const Icon(Icons.edit_calendar),
        label: const Text(
          "Export ke Calendar",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}