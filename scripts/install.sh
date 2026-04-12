#!/usr/bin/env sh
set -eu

usage() {
  cat >&2 <<'EOF'
Usage:
  ./scripts/install.sh [all|codex|opencode|claude|cursor|windsurf|gemini|continue|aider] /path/to/project
  ./scripts/install.sh codex-global

Examples:
  ./scripts/install.sh all .
  ./scripts/install.sh claude /path/to/project
  ./scripts/install.sh cursor /path/to/project
  ./scripts/install.sh codex-global
EOF
  exit 1
}

[ "${1-}" ] || usage

TOOL="$1"
ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
ABS_TARGET=""

if [ "$TOOL" != "codex-global" ]; then
  [ "${2-}" ] || usage
  TARGET_DIR="$2"
  ABS_TARGET=$(CDPATH= cd -- "$TARGET_DIR" 2>/dev/null && pwd || true)

  if [ -z "$ABS_TARGET" ]; then
    echo "Target directory does not exist: $TARGET_DIR" >&2
    exit 1
  fi
fi

copy_dir_once() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ]; then
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
}

copy_file_once() {
  src="$1"
  dest="$2"

  if [ -e "$dest" ]; then
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

replace_dir_with_backup() {
  src="$1"
  dest="$2"
  backup_root="$3"

  mkdir -p "$(dirname "$dest")"
  mkdir -p "$backup_root"

  if [ -e "$dest" ]; then
    backup="$backup_root/$(basename "$dest").bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "Existing install moved to $backup"
  fi

  cp -R "$src" "$dest"
}

append_block_if_missing() {
  dest="$1"
  marker="$2"
  block="$3"

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] && grep -Fq "$marker" "$dest"; then
    return
  fi

  if [ -e "$dest" ]; then
    printf '\n\n%s\n' "$block" >> "$dest"
  else
    printf '%s\n' "$block" > "$dest"
  fi
}

install_canonical_dir() {
  copy_dir_once "$ROOT_DIR/agent-skills-system" "$ABS_TARGET/agent-skills-system"
}

install_generic_skill_dir() {
  copy_dir_once "$ROOT_DIR/agent-skills-system" "$ABS_TARGET/.agents/skills/agent-skills-system"
}

install_codex_global_skill() {
  codex_home="${CODEX_HOME:-$HOME/.codex}"
  replace_dir_with_backup \
    "$ROOT_DIR/agent-skills-system" \
    "$codex_home/skills/agent-skills-system" \
    "$codex_home/skill-backups"
}

install_agents_adapter() {
  block=$(cat <<'EOF'
<!-- agent-skills-system:start -->
## Agent Skills System

CRITICAL: For agent design, routing, mode selection, or skills work, read `agent-skills-system/SKILL.md` before proceeding.

- Keep one active mode per phase
- Treat the skill file as the source of truth
- If local project rules and the skill disagree, project-specific constraints win
<!-- agent-skills-system:end -->
EOF
)
  append_block_if_missing "$ABS_TARGET/AGENTS.md" "<!-- agent-skills-system:start -->" "$block"
}

install_claude_adapter() {
  block=$(cat <<'EOF'
<!-- agent-skills-system:start -->

@agent-skills-system/SKILL.md
<!-- agent-skills-system:end -->
EOF
)
  append_block_if_missing "$ABS_TARGET/CLAUDE.md" "<!-- agent-skills-system:start -->" "$block"
}

install_gemini_adapter() {
  block=$(cat <<'EOF'
<!-- agent-skills-system:start -->

@agent-skills-system/SKILL.md
<!-- agent-skills-system:end -->
EOF
)
  append_block_if_missing "$ABS_TARGET/GEMINI.md" "<!-- agent-skills-system:start -->" "$block"
}

install_continue_adapter() {
  copy_file_once "$ROOT_DIR/.continue/rules/agent-skills-system.md" "$ABS_TARGET/.continue/rules/agent-skills-system.md"
}

install_cursor_adapter() {
  copy_file_once "$ROOT_DIR/templates/cursor/agent-skills-system.mdc" "$ABS_TARGET/.cursor/rules/agent-skills-system.mdc"
}

install_windsurf_adapter() {
  copy_file_once "$ROOT_DIR/templates/windsurf/agent-skills-system.md" "$ABS_TARGET/.windsurf/rules/agent-skills-system.md"
}

install_aider_adapter() {
  copy_file_once "$ROOT_DIR/CONVENTIONS.md" "$ABS_TARGET/CONVENTIONS.md"

  if [ -e "$ABS_TARGET/.aider.conf.yml" ]; then
    echo "Existing .aider.conf.yml found. Add these read entries manually if needed:" >&2
    echo "read:" >&2
    echo "  - CONVENTIONS.md" >&2
    echo "  - agent-skills-system/SKILL.md" >&2
    return
  fi

  copy_file_once "$ROOT_DIR/.aider.conf.yml" "$ABS_TARGET/.aider.conf.yml"
}

install_shared_stack() {
  install_canonical_dir
  install_generic_skill_dir
  install_agents_adapter
  install_claude_adapter
  install_gemini_adapter
  install_continue_adapter
  install_aider_adapter
}

case "$TOOL" in
  all)
    install_shared_stack
    echo "Installed shared cross-tool adapters at $ABS_TARGET"
    echo "Covers Codex, OpenCode, Claude Code, Cursor, Windsurf, Gemini CLI, Continue, and Aider."
    echo "For native Cursor or Windsurf rule files, run:"
    echo "  ./scripts/install.sh cursor $ABS_TARGET"
    echo "  ./scripts/install.sh windsurf $ABS_TARGET"
    ;;
  codex)
    install_canonical_dir
    install_agents_adapter
    echo "Installed for Codex at $ABS_TARGET"
    ;;
  codex-global)
    install_codex_global_skill
    echo "Installed global Codex skill at ${CODEX_HOME:-$HOME/.codex}/skills/agent-skills-system"
    ;;
  opencode)
    install_canonical_dir
    install_generic_skill_dir
    install_agents_adapter
    echo "Installed for OpenCode at $ABS_TARGET"
    ;;
  claude)
    install_canonical_dir
    install_claude_adapter
    echo "Installed for Claude Code at $ABS_TARGET"
    ;;
  cursor)
    install_canonical_dir
    install_cursor_adapter
    echo "Installed native Cursor rule at $ABS_TARGET"
    ;;
  windsurf)
    install_canonical_dir
    install_windsurf_adapter
    echo "Installed native Windsurf rule at $ABS_TARGET"
    ;;
  gemini)
    install_canonical_dir
    install_generic_skill_dir
    install_gemini_adapter
    echo "Installed for Gemini CLI at $ABS_TARGET"
    ;;
  continue)
    install_canonical_dir
    install_continue_adapter
    echo "Installed for Continue at $ABS_TARGET"
    ;;
  aider)
    install_canonical_dir
    install_aider_adapter
    echo "Installed for Aider at $ABS_TARGET"
    ;;
  *)
    usage
    ;;
esac
