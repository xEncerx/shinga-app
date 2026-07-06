---
name: flutter-resolve-package-conflicts
description: Workflow for fixing package version conflicts in Flutter projects. Use this when `flutter pub get` fails due to incompatible package versions.
---
# Managing Flutter Dependencies

## Contents
- [Version Constraints](#version-constraints)
- [Workflow: Upgrading Dependencies](#workflow-upgrading-dependencies)
- [Workflow: Resolving Version Conflicts](#workflow-resolving-version-conflicts)

## Version Constraints

*   **Use Caret Syntax:** Use caret syntax (e.g., `^1.2.3`) for dependencies in `pubspec.yaml` to allow minor/patch updates without breaking changes.
*   **Workspaces:** If modifying `pubspec.yaml` in a workspace package (like `packages/ui_kit`), ensure you run `flutter pub get` from the root of the workspace.

## Workflow: Upgrading Dependencies

Run this workflow to upgrade dependencies securely.

**Task Progress:**
- [ ] Run `flutter pub outdated` to see what can be upgraded.
- [ ] Run `flutter pub upgrade` to update the lockfile to the latest compatible versions.
- [ ] Run `flutter pub upgrade --tighten` to automatically update the lower bounds in `pubspec.yaml` to match the newly resolved versions.
- [ ] Run `dart run build_runner build --delete-conflicting-outputs` if any codegen dependencies were updated.

## Workflow: Resolving Version Conflicts

When `pub` cannot find a set of concrete versions that satisfy all constraints.

**NEVER** delete the entire `pubspec.lock` file and run `flutter pub get`. This causes uncontrolled upgrades across the entire dependency graph.

**Task Progress:**
- [ ] Open `pubspec.lock`.
- [ ] Locate the specific YAML block for the conflicting package.
- [ ] Delete ONLY that package's entry from the lockfile.
- [ ] Run `flutter pub get`.
- [ ] If resolution fails, identify the transitive dependency causing the lock, update its constraint in `pubspec.yaml` (or add a temporary dependency override), and retry.