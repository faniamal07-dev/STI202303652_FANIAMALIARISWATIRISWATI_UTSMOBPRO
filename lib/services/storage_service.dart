import 'dart:convert';
import 'package:personal_journal/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _notesKey = 'personal_journal_notes';

  // Simpan semua catatan ke SharedPreferences
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    // Konversi List<Note> ke List<Map>
    final List<Map<String, dynamic>> notesJson =
        notes.map((note) => note.toJson()).toList();
    // Encode List<Map> ke string JSON
    final String notesString = jsonEncode(notesJson);
    await prefs.setString(_notesKey, notesString);
  }

  // Muat semua catatan dari SharedPreferences
  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString(_notesKey);

    if (notesString != null) {
      // Decode string JSON ke List<dynamic>
      final List<dynamic> notesJson = jsonDecode(notesString);
      // Konversi setiap item JSON kembali ke objek Note
      return notesJson.map((json) => Note.fromJson(json)).toList();
    }
    // Kembalikan list kosong jika tidak ada data
    return [];
  }
}
