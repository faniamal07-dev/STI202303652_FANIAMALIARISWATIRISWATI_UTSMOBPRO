import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_journal/models/note.dart';
import 'package:personal_journal/screens/add_note_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Note _currentNote; // Simpan note saat ini

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  // Menampilkan dialog konfirmasi sebelum menghapus
  Future<bool> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Hapus
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    // Jika result null (dialog ditutup), anggap false
    return result ?? false;
  }

  // Menangani navigasi ke layar edit
  void _handleEdit() async {
    // Navigasi ke AddNoteScreen dalam mode EDIT
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          // Kirim catatan yang ada untuk di-edit
          existingNote: _currentNote,
        ),
      ),
    );

    // Jika layar edit mengembalikan catatan yang sudah diupdate
    if (updatedNote != null && updatedNote is Note) {
      // Perbarui UI di layar detail ini
      setState(() {
        _currentNote = updatedNote;
      });
      // Kita juga perlu memberi tahu layar utama (home)
      // Tapi kita akan pop dengan data baru saat pengguna kembali
    }
  }

  // Menangani aksi hapus
  void _handleDelete() async {
    final confirm = await _showDeleteConfirmation();
    if (confirm) {
      // Kirim 'delete' kembali ke main_scaffold
      if (mounted) {
        Navigator.pop(context, 'delete');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol Elipsis (Menu)
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _handleEdit();
              } else if (value == 'delete') {
                _handleDelete();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.black87),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Saat kembali, kirim _currentNote (yg mungkin terupdate)
      body: WillPopScope(
        onWillPop: () {
          // Kirim note terbaru saat menekan tombol back
          Navigator.pop(context, _currentNote);
          return Future.value(false);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan gambar jika ada
              if (_currentNote.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    File(_currentNote.imagePath!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              if (_currentNote.imagePath != null) const SizedBox(height: 16),

              // Judul
              Text(
                _currentNote.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // Tanggal
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(_currentNote.date),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Konten
              Text(
                _currentNote.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.5, // Jarak antar baris
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
