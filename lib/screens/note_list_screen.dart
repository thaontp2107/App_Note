import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_storage.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteStorage _storage = NoteStorage();
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _storage.loadNotes();
    setState(() {
      _notes = notes;
      _sortNotes();
      _loading = false;
    });
  }

  void _sortNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _persist() => _storage.saveNotes(_notes);

  Future<void> _openEditor([Note? note]) async {
    final result = await Navigator.of(context).push<NoteEditResult>(
      MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)),
    );
    if (result == null) return;

    setState(() {
      if (result.deleted) {
        _notes.removeWhere((n) => n.id == result.note.id);
      } else {
        final index = _notes.indexWhere((n) => n.id == result.note.id);
        if (index >= 0) {
          _notes[index] = result.note;
        } else {
          _notes.add(result.note);
        }
        _sortNotes();
      }
    });
    await _persist();

    if (result.deleted && mounted) {
      _showUndoDelete(result.note);
    }
  }

  Future<void> _deleteNote(Note note) async {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    await _persist();
    if (mounted) _showUndoDelete(note);
  }

  void _showUndoDelete(Note note) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Đã xóa ghi chú'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              setState(() {
                _notes.add(note);
                _sortNotes();
              });
              await _persist();
            },
          ),
        ),
      );
  }

  Future<bool> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ghi chú?'),
        content: Text(
          'Bạn có chắc muốn xóa "${note.title.isEmpty ? 'Không có tiêu đề' : note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú của tôi'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm ghi chú'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có ghi chú nào.\nNhấn "Thêm ghi chú" để bắt đầu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          key: ValueKey(note.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(note),
          onDismissed: (_) => _deleteNote(note),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: Text(
                note.title.isEmpty ? 'Không có tiêu đề' : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(note.updatedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Xóa',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await _confirmDelete(note)) _deleteNote(note);
                },
              ),
              onTap: () => _openEditor(note),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
