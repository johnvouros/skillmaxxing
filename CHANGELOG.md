# Changelog

All notable changes to this project will be documented in this file.

This repo does not require tagged releases to use the changelog. Until versioning is formalized, changes can accumulate under `Unreleased`.

## [Unreleased]

### Added

- Added `CHANGELOG.md` so users have a conventional place to track repository changes.
- Added operational loops to the canonical skill for alignment, durable context, feedback/TDD, diagnosis, work packaging, and architecture deepening, adapted from useful patterns in `mattpocock/skills`.

### Changed

- Tightened the canonical mode packs in `agent-skills-system/SKILL.md` so each mode now defines a first move, required artifacts before leaving the mode, a switch signal, and hard no's.
- Updated the skill contract in `agent-skills-system/SKILL.md` to require routed tasks to state the current bottleneck, the mode's first move, the required artifact before switching, and the switch signal.
- Updated the skill contract in `agent-skills-system/SKILL.md` to include the chosen operational loop when one is relevant.
- Updated `README.md` to describe mode packs as execution contracts and to reflect the stronger routing expectations.
