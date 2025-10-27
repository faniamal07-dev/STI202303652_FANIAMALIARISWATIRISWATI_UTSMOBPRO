class Note {
  String id;
  String title;
  String content;
  DateTime date;
  String? imagePath; // Path ke gambar di penyimpanan lokal

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath,
  });

  // Konversi dari Map (JSON) ke objek Note
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      imagePath: json['imagePath'],
    );
  }

  // Konversi dari objek Note ke Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(), // Simpan sebagai string ISO
      'imagePath': imagePath,
    };
  }
}
