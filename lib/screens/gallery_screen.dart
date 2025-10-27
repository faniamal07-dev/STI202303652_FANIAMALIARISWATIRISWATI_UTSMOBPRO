import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_journal/models/note.dart';

class GalleryScreen extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onImageTap;

  const GalleryScreen(
      {super.key, required this.notes, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    // Filter catatan yang hanya memiliki gambar
    final imageNotes = notes.where((note) => note.imagePath != null).toList();

    if (imageNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Galeri Kosong',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              'Gambar dari catatan akan muncul di sini',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Tampilkan gambar dalam GridView
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 gambar per baris
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: imageNotes.length,
      itemBuilder: (context, index) {
        final note = imageNotes[index];
        return InkWell(
          onTap: () => onImageTap(note),
          child: Hero(
            // Tambahkan Hero untuk animasi transisi yang bagus
            tag: note.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(note.imagePath!),
                fit: BoxFit.cover,
                frameBuilder: (BuildContext context, Widget child, int? frame,
                    bool wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  if (frame == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
