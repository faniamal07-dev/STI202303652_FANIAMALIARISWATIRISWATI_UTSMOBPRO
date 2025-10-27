import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:personal_journal/models/note.dart';

class AddNoteScreen extends StatefulWidget {
  // Callback ini diisi saat mode 'Tambah Baru'
  final Function(Note)? onAddNote;
  // Note ini diisi saat mode 'Edit'
  final Note? existingNote;

  const AddNoteScreen({super.key, this.onAddNote, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _existingImagePath; // Simpan path gambar lama saat edit

  final ImagePicker _picker = ImagePicker();
  bool get _isEditMode => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    // Jika ini mode edit, isi semua field
    if (_isEditMode) {
      final note = widget.existingNote!;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedDate = note.date;
      if (note.imagePath != null) {
        _existingImagePath = note.imagePath;
        _selectedImage = File(note.imagePath!);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _existingImagePath = null; // Gambar baru dipilih, hapus path lama
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitNote() {
    final String title = _titleController.text;
    final String content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan isi catatan tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isEditMode) {
      // --- MODE EDIT ---
      // Buat note baru dengan data yang diupdate, tapi ID LAMA
      final updatedNote = Note(
        id: widget.existingNote!.id, // PENTING: Gunakan ID lama
        title: title,
        content: content,
        date: _selectedDate,
        // Tentukan path gambar:
        // 1. Jika _selectedImage ada & path-nya beda dgn yg lama -> path baru
        // 2. Jika _existingImagePath ada -> path lama
        // 3. Jika tidak keduanya -> null
        imagePath: _selectedImage?.path != widget.existingNote?.imagePath
            ? _selectedImage?.path
            : _existingImagePath,
      );
      // Kirim note yang sudah di-update kembali ke layar detail
      Navigator.pop(context, updatedNote);
    } else {
      // --- MODE TAMBAH BARU ---
      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        date: _selectedDate,
        imagePath: _selectedImage?.path,
      );
      // Panggil callback untuk dikirim ke main_scaffold
      widget.onAddNote!(newNote);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika mode edit, gunakan Scaffold agar ada tombol back
    if (_isEditMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Catatan'),
        ),
        body: _buildForm(),
      );
    }
    // Jika mode tambah, tidak perlu AppBar (karena bagian dari IndexedStack)
    return _buildForm();
  }

  // Pisahkan form ke widget sendiri
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul Catatan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Isi Catatan',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.article),
            ),
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal & Waktu:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd MMMM yyyy, HH:mm')
                          .format(_selectedDate)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: Colors.teal),
                    onPressed: () => _pickDate(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Tampilkan preview gambar
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_selectedImage != null) const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(_selectedImage == null
                        ? Icons.add_photo_alternate_rounded
                        : Icons.change_circle_rounded),
                    label: Text(_selectedImage == null
                        ? 'Pilih Gambar dari Galeri'
                        : 'Ganti Gambar'),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            label: Text(_isEditMode ? 'Update Catatan' : 'Simpan Catatan',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: _submitNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
