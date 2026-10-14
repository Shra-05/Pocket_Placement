Pocket Placement – Theme-Aware Core Learning UI

Updated file:
- lib/core_subject_level_screen.dart

What changed:
- Adds a subtle theme atmosphere to the learning screen.
- Uses forest, cyberpunk, and kingdom-specific icons/colors.
- Adds a character-companion panel beside the quiz on wide screens and a compact companion card on smaller screens.
- Adds a more luminous gradient to the level visualizer.
- Keeps question selection/submission, completion callbacks, previous/next navigation, notes, and stored progress logic in the existing screen.
- Does not intentionally modify the DSA screens.

Apply:
1. Back up your current project.
2. Replace lib/core_subject_level_screen.dart with this version.
3. Keep the rest of your existing lib folder and pubspec.yaml.
4. Run `flutter pub get`, `dart format lib/core_subject_level_screen.dart`, `flutter analyze`, and `flutter run`.

The full lib folder is included for reference, but the only intended UI change in this update is core_subject_level_screen.dart. Flutter analysis could not be run in this environment.
