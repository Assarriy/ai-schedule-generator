import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class ScheduleResultScreen extends StatelessWidget {
  final String scheduleResult;
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  // --- TEMA WARNA PREMIUM (Diselaraskan dengan Home Screen) ---
  final Color primaryGreen = const Color(0xFF059669); // Deep Emerald
  final Color neonGreen = const Color(0xFF10B981); // Bright Emerald
  final Color darkText = const Color(0xFF0F172A); // Slate 900
  final Color greyText = const Color(0xFF64748B); // Slate 500
  final Color cardColor = Colors.white;

  // --- FUNGSI PEMBERSIH MARKDOWN UNTUK KALENDER ---
  String _cleanMarkdownForCalendar(String markdown) {
    final lines = markdown.split('\n');
    final cleanedLines = <String>[];

    for (var line in lines) {
      var trimmed = line.trim();

      if (trimmed.startsWith('|') && trimmed.contains('---')) {
        continue;
      }

      if (trimmed.startsWith('|')) {
        if (trimmed.endsWith('|')) {
          trimmed = trimmed.substring(1, trimmed.length - 1);
        } else {
          trimmed = trimmed.substring(1);
        }
        final parts = trimmed.split('|').map((e) => e.trim()).toList();
        cleanedLines.add(parts.join('  •  '));
      } else {
        cleanedLines.add(line);
      }
    }
    return cleanedLines.join('\n');
  }

  // --- FUNGSI EXPORT KE GOOGLE CALENDAR ---
  Future<void> _exportToCalendar(BuildContext context) async {
    final String cleanText = _cleanMarkdownForCalendar(scheduleResult);
    final String encodedDetails = Uri.encodeComponent(cleanText);
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
          SnackBar(
            content: const Text(
              "Error: Tidak dapat membuka kalender",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Biar background tembus ke bawah appbar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkText), // Tombol back warna gelap
        centerTitle: true,
        title: Text(
          "Schedule Result",
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.copy_rounded, color: primaryGreen, size: 20),
              tooltip: "Salin Jadwal",
              onPressed: () {
                Clipboard.setData(ClipboardData(text: scheduleResult));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Jadwal berhasil disalin!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    backgroundColor: darkText,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradasi seragam dengan Home Screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFECFDF5), Color(0xFFF8FAFC)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // HEADER INFORMASI (Glassmorphism feel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: neonGreen.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Jadwal ini disusun otomatis oleh AI berdasarkan prioritasmu.",
                          style: TextStyle(
                            color: darkText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AREA HASIL (MARKDOWN)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64748B).withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Markdown(
                        data: scheduleResult,
                        selectable: true,
                        padding: const EdgeInsets.all(24),
                        extensionSet: md.ExtensionSet.gitHubFlavored,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: greyText,
                          ),
                          h1: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                            letterSpacing: -0.5,
                          ),
                          h2: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                          h3: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryGreen,
                          ),
                          // Styling Tabel Premium
                          tableBorder: TableBorder.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          tableHeadAlign: TextAlign.center,
                          tablePadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          tableCellsPadding: const EdgeInsets.all(14),
                          tableHead: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: darkText,
                            fontSize: 14,
                          ),
                          tableBody: TextStyle(
                            color: darkText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TOMBOL BUAT JADWAL BARU
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 2,
                      ), // Slate 300
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: darkText, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Buat Jadwal Baru",
                          style: TextStyle(
                            color: darkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ), // Ruang lega untuk Floating Action Button
              ],
            ),
          ),
        ),
      ),

      // TOMBOL EXPORT MELAYANG (Floating Action Button Custom)
      floatingActionButton: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [primaryGreen, const Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: neonGreen.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _exportToCalendar(context),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "EXPORT TO CALENDAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
