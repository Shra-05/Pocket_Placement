Pocket Placement Core CS update

Files updated:
- core_question_bank.dart: five subjects, 100 levels each, checkpoint tests.
- core_knowledge_test_screen.dart: theme-aware knowledge tests with scoring.
- core_subject_level_screen.dart: next-level callback and per-level notes saved with SharedPreferences.
- oops_core_level_screen.dart, os_core_level_screen.dart, dbms_core_level_screen.dart,
  cn_core_level_screen.dart, ml_core_level_screen.dart: 100-level progression and checkpoint routing.
- level_selection_screen.dart: Core CS map generates 100 nodes. DSA implementation was not changed.
- services/core_question_pdf_service.dart: subject question PDF generation.

Dependency note:
The original upload contained lib/ only, not pubspec.yaml. The PDF service requires these pubspec dependencies:
  pdf: ^3.11.3
  printing: ^5.14.2
The project already uses shared_preferences (the updated notes feature uses it).
After copying files, run:
  flutter pub add pdf printing
  flutter pub get
  flutter analyze

Important:
The generated levels reuse each subject's 20 core concepts across five progressively worded variants, so there are 100 level entries per subject. Checkpoint tests use concepts from the corresponding previous 20-level block. Review question wording and quiz logic before production release.
