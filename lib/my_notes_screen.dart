import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/core_notes_pdf_service.dart';
import 'theme_selection_screen.dart';

class _SavedNote {
  final String key;
  final String subject;
  final int level;
  final String content;

  const _SavedNote({
    required this.key,
    required this.subject,
    required this.level,
    required this.content,
  });

  String get title => content.trim().split('\n').firstWhere(
        (line) => line.trim().isNotEmpty,
        orElse: () => 'Level $level notes',
      );
}

/// Lists the notes already stored by CoreSubjectLevelScreen. Existing
/// SharedPreferences keys are read directly, so no migration is required.
class MyNotesScreen extends StatefulWidget {
  final AppTheme theme;
  const MyNotesScreen({super.key, required this.theme});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  static const _subjects = <String>['All', 'OOPS', 'OS', 'DBMS', 'CN', 'ML'];
  final _searchController = TextEditingController();
  List<_SavedNote> _notes = [];
  String _selectedSubject = 'All';
  bool _loading = true;
  bool _exporting = false;

  Color get _accent {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF72D69A);
      case AppTheme.cyberpunk:
        return const Color(0xFFFF58D2);
      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }

  Color get _background {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF071B13);
      case AppTheme.cyberpunk:
        return const Color(0xFF10091F);
      case AppTheme.kingdom:
        return const Color(0xFF21150E);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _canonicalSubject(String subject) {
    switch (subject.trim().toUpperCase()) {
      case 'OPERATING SYSTEMS':
      case 'OPERATING_SYSTEMS':
        return 'OS';
      case 'COMPUTER NETWORKS':
      case 'COMPUTER_NETWORKS':
        return 'CN';
      case 'MACHINE LEARNING':
      case 'MACHINE_LEARNING':
        return 'ML';
      default:
        return subject.trim().toUpperCase();
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notes = <_SavedNote>[];
    // Supports the existing core_notes_<SUBJECT>_<LEVEL> storage format.
    final pattern = RegExp(r'^core_notes_(.+)_(\d+)$');
    for (final key in prefs.getKeys()) {
      final match = pattern.firstMatch(key);
      if (match == null) continue;
      final subject = _canonicalSubject(match.group(1)!);
      if (!_subjects.skip(1).contains(subject)) continue;
      final content = prefs.getString(key) ?? '';
      if (content.trim().isEmpty) continue;
      notes.add(_SavedNote(
        key: key,
        subject: subject,
        level: int.tryParse(match.group(2)!) ?? 0,
        content: content,
      ));
    }
    notes.sort((a, b) {
      final subjectCompare = a.subject.compareTo(b.subject);
      return subjectCompare != 0 ? subjectCompare : a.level.compareTo(b.level);
    });
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  List<_SavedNote> get _filteredNotes {
    final query = _searchController.text.trim().toLowerCase();
    return _notes.where((note) {
      final subjectMatches = _selectedSubject == 'All' ||
          note.subject == _selectedSubject;
      final queryMatches = query.isEmpty ||
          note.content.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          'level ${note.level}'.contains(query);
      return subjectMatches && queryMatches;
    }).toList();
  }

  Future<void> _editNote(_SavedNote note) async {
    final controller = TextEditingController(text: note.content);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171923),
        title: Text('Edit ${note.subject} • Level ${note.level}',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 560,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 6,
            maxLines: 12,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your notes here...',
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _accent.withValues(alpha: .5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _accent),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (result.trim().isEmpty) {
      await prefs.remove(note.key);
    } else {
      await prefs.setString(note.key, result);
    }
    await _loadNotes();
  }

  Future<void> _deleteNote(_SavedNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171923),
        title: const Text('Delete note?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete ${note.subject} • Level ${note.level} notes? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(note.key);
    await _loadNotes();
  }

  Future<void> _exportPdf() async {
    if (_notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no saved notes to export yet.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      await CoreNotesPdfService.exportNotes(_notes.map((note) => {
        'subject': note.subject,
        'level': note.level,
        'content': note.content,
      }).toList());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export PDF: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _openNote(_SavedNote note) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF171923),
        title: Text('${note.subject} • Level ${note.level}',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: SelectableText(note.content,
                style: const TextStyle(color: Colors.white70, height: 1.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _editNote(note);
            },
            child: const Text('EDIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotes = _filteredNotes;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Text('MY NOTES',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        actions: [
          IconButton(
            tooltip: 'Export all notes as PDF',
            onPressed: _exporting ? null : _exportPdf,
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search notes, subjects, or levels...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: .06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final selected = _selectedSubject == subject;
                  return ChoiceChip(
                    label: Text(subject),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSubject = subject),
                    selectedColor: _accent,
                    backgroundColor: Colors.white.withValues(alpha: .07),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    side: BorderSide(
                      color: selected ? _accent : Colors.white24,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              child: Row(
                children: [
                  Text('${visibleNotes.length} saved note${visibleNotes.length == 1 ? '' : 's'}',
                      style: TextStyle(color: _accent, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Stored on this device',
                      style: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: _accent))
                  : visibleNotes.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          color: _accent,
                          onRefresh: _loadNotes,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: visibleNotes.length,
                            itemBuilder: (context, index) {
                              final note = visibleNotes[index];
                              return Card(
                                color: Colors.white.withValues(alpha: .055),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: _accent.withValues(alpha: .22)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                                  leading: Container(
                                    width: 44,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _accent.withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.sticky_note_2_rounded, color: _accent),
                                  ),
                                  title: Text('${note.subject}  •  Level ${note.level}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(note.content.replaceAll('\n', ' '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white60, height: 1.3)),
                                  ),
                                  onTap: () => _openNote(note),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                                    onSelected: (value) {
                                      if (value == 'edit') _editNote(note);
                                      if (value == 'delete') _deleteNote(note);
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Edit note')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete note')),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 64, color: _accent.withValues(alpha: .8)),
            const SizedBox(height: 16),
            Text(_notes.isEmpty ? 'No saved notes yet' : 'No notes match your search',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Notes you save inside OOPS, OS, DBMS, CN, and ML levels will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
