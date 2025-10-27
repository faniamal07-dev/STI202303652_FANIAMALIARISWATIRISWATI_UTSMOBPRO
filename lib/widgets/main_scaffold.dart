// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_journal/models/note.dart';
import 'package:personal_journal/screens/about_screen.dart';
import 'package:personal_journal/screens/add_note_screen.dart';
import 'package:personal_journal/screens/gallery_screen.dart';
import 'package:personal_journal/screens/home_screen.dart';
import 'package:personal_journal/services/storage_service.dart';
import 'package:personal_journal/widgets/custom_app_bar.dart';
// --- IMPORT BARU UNTUK LAYAR DETAIL ---
import 'package:personal_journal/screens/note_detail_screen.dart';
// --- AKHIR IMPORT BARU ---

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  String _appBarTitle = 'Home';
  IconData _appBarIcon = Icons.home_rounded;

  List<Note> _notes = []; // List master untuk semua catatan
  late List<Widget> _screens; // List widget untuk setiap menu

  // --- UNTUK SEARCH ---
  final TextEditingController _searchController = TextEditingController();
  List<Note> _filteredNotes = []; // List yang akan ditampilkan di Home
  // --- AKHIR SEARCH ---

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Muat catatan saat aplikasi dimulai
    _updateScreens(); // Inisialisasi daftar layar
    _searchController.addListener(_filterNotes); // Tambah listener untuk search
  }

  @override
  void dispose() {
    _searchController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  // --- FUNGSI SIMPAN & MUAT DATA ---
  Future<void> _loadNotes() async {
    final loadedNotes = await StorageService.loadNotes();
    setState(() {
      _notes = loadedNotes;
    });
    _filterNotes(); // Panggil filter setelah data dimuat
  }

  Future<void> _saveNotes() async {
    await StorageService.saveNotes(_notes);
  }

  // --- FUNGSI UNTUK FILTER ---
  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Jika search kosong, tampilkan semua catatan
        _filteredNotes = List.from(_notes);
      } else {
        // Jika ada, filter berdasarkan judul
        _filteredNotes = _notes
            .where((note) => note.title.toLowerCase().contains(query))
            .toList();
      }
      _updateScreens(); // Perbarui widget screen dengan data baru
    });
  }

  // --- FUNGSI NAVIGASI & STATE ---
  void _addNote(Note note) {
    setState(() {
      _notes.insert(0, note); // Tambah di awal list master
      _filterNotes(); // Panggil filter agar list terupdate
    });
    _saveNotes(); // Simpan ke storage
    _onItemTapped(0); // Pindah ke Home setelah menambah
  }

  // --- FUNGSI UNTUK NAVIGASI KE DETAIL (EDIT/HAPUS) ---
  void _navigateToNoteDetail(Note note) async {
    // Ganti showDialog dengan Navigator.push ke layar detail baru
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );

    // Tangani hasil balikan dari NoteDetailScreen
    if (result == 'delete') {
      // --- Logika Hapus ---
      setState(() {
        _notes.removeWhere((n) => n.id == note.id);
      });
      await _saveNotes();
      _filterNotes(); // Perbarui UI
    } else if (result != null && result is Note) {
      // --- Logika Edit ---
      // 'result' adalah note yang sudah di-update
      final updatedNote = result;
      setState(() {
        final index = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
      });
      await _saveNotes();
      _filterNotes(); // Perbarui UI
    }
  }
  // --- AKHIR FUNGSI NAVIGASI DETAIL ---

  void _updateScreens() {
    _screens = [
      // HomeScreen sekarang menggunakan _filteredNotes
      HomeScreen(
          notes: _filteredNotes, onNoteTap: _navigateToNoteDetail), // Menu 0
      AddNoteScreen(onAddNote: _addNote), // Menu 1
      // Galeri tetap pakai _notes (menampilkan semua gambar)
      GalleryScreen(notes: _notes, onImageTap: _navigateToNoteDetail), // Menu 2
      const AboutScreen(), // Menu 3
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _appBarTitle = 'Home';
          _appBarIcon = Icons.home_rounded;
          break;
        case 1:
          _appBarTitle = 'Tambah Catatan';
          _appBarIcon = Icons.add_circle_rounded;
          break;
        case 2:
          _appBarTitle = 'Galeri';
          _appBarIcon = Icons.image_rounded;
          break;
        case 3:
          _appBarTitle = 'Tentang Aplikasi';
          _appBarIcon = Icons.info_rounded;
          break;
      }
    });
  }

  // --- WIDGET UNTUK SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan judul...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _appBarTitle,
        icon: _appBarIcon,
      ),
      // --- PERUBAHAN UTAMA PADA BODY ---
      body: Column(
        children: [
          // Tampilkan search bar HANYA jika tab Home (index 0) aktif
          if (_selectedIndex == 0) _buildSearchBar(),
          // Bungkus IndexedStack dengan Expanded agar mengisi sisa ruang
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      // --- AKHIR PERUBAHAN BODY ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(1);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            activeIcon: Icon(Icons.image_rounded),
            label: 'Galeri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline_rounded),
            activeIcon: Icon(Icons.info_rounded),
            label: 'Tentang',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
