#!/bin/sh
# Defaults first: if stdin is empty/malformed, jq emits nothing and the
# script degrades gracefully instead of tripping "[: Illegal number".
model=Unknown used_int=0 cost_usd=0 duration_ms=0 cwd= effort_level=

eval "$(jq -r '
  "model=" + (.model.display_name // "Unknown" | @sh),
  "used_int=" + ((.context_window.used_percentage // 0) | round | tostring),
  "cost_usd=" + ((.cost.total_cost_usd // 0) | tostring),
  "duration_ms=" + ((.cost.total_duration_ms // 0) | round | tostring),
  "cwd=" + (.workspace.current_dir // .cwd // "" | @sh),
  "effort_level=" + (.effort.level // "" | @sh)
' 2>/dev/null)"

bar=$(awk -v p="$used_int" 'BEGIN {
  f = int(p * 20 / 100)
  if (f > 20) f = 20; if (f < 0) f = 0
  for (i = 0; i < f;    i++) printf "█"
  for (i = 0; i < 20-f; i++) printf "░"
}')

# Real ESC byte so colours work in printf formats, %s args, and concatenation alike.
esc=$(printf '\033')
CYAN="${esc}[36m"
GREEN="${esc}[32m"
YELLOW="${esc}[33m"
RED="${esc}[31m"
MAGENTA="${esc}[35m"
BLUE="${esc}[34m"
WHITE="${esc}[37m"
RESET="${esc}[0m"

if [ "$used_int" -ge 90 ]; then
  bar_colour="$RED"
elif [ "$used_int" -ge 70 ]; then
  bar_colour="$YELLOW"
else
  bar_colour="$GREEN"
fi

# Actual session cost reported by Claude Code (cost.total_cost_usd).
cost=$(LC_ALL=C awk -v c="$cost_usd" 'BEGIN {
  if (c < 0.01) printf "$%.4f", c
  else printf "$%.2f", c
}')

elapsed_str=""
# Wall-clock session time reported by Claude Code (cost.total_duration_ms).
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
  elapsed_secs=$(( duration_ms / 1000 ))
  hours=$(( elapsed_secs / 3600 ))
  minutes=$(( (elapsed_secs % 3600) / 60 ))
  secs=$(( elapsed_secs % 60 ))
  if [ "$hours" -gt 0 ]; then
    elapsed_str=$(printf "%dh%02dm" "$hours" "$minutes")
  else
    elapsed_str=$(printf "%dm%02ds" "$minutes" "$secs")
  fi
fi

# Path from nearest .claude/ ancestor (project root). Ascend with parameter
# expansion (no dirname fork per level); stop after checking the filesystem root.
project_root=""
_dir="$cwd"
while true; do
  [ -d "${_dir}/.claude" ] && { project_root="$_dir"; break; }
  case $_dir in
    */?*) _dir=${_dir%/*}; [ -z "$_dir" ] && _dir=/ ;;
    *) break ;;
  esac
done

if [ -n "$project_root" ]; then
  rel=${cwd#"$project_root"}
  rel=${rel#/}
  short_cwd="${project_root##*/}${rel:+/$rel}"
else
  short_cwd="${cwd##*/}"
fi

# Git info: single awk pass emits branch, staged, modified on three lines.
# Read (not eval) so a hostile branch name can't inject shell commands.
git_line=""
if git_status=$(git -C "$cwd" -c core.hooksPath=/dev/null status --porcelain -b 2>/dev/null); then
  branch=""; staged=0; modified=0
  { IFS= read -r branch; IFS= read -r staged; IFS= read -r modified; } <<EOF
$(printf '%s' "$git_status" | awk '
  NR==1 {
    sub(/^## /, ""); sub(/^No commits yet on /, "")
    sub(/\.\.\..*/, ""); sub(/ \(.*\)$/, ""); b = $0; next
  }
  /^[^ ?!]/ { staged++ }
  /^.[^ ?!]/ { modified++ }
  END { print b; print staged+0; print modified+0 }
')
EOF
  git_line=" ${BLUE}[${RESET}${CYAN}${branch}${RESET}"
  [ "$staged" -gt 0 ]   && git_line="${git_line} ${GREEN}+${staged}${RESET}"
  [ "$modified" -gt 0 ] && git_line="${git_line} ${YELLOW}~${modified}${RESET}"
  git_line="${git_line}${BLUE}]${RESET}"
fi

printf "${CYAN}%s${RESET}  [${bar_colour}%s${RESET}] %d%%" "$model" "$bar" "$used_int"
[ -n "$effort_level" ] && printf " | ${WHITE}effort:%s${RESET}" "$effort_level"
printf " | 💰 ${MAGENTA}%s${RESET}" "$cost"
[ -n "$elapsed_str" ] && printf " | ⏱️ ${YELLOW}%s${RESET}" "$elapsed_str"
printf "\n${YELLOW}%s${RESET}%s" "$short_cwd" "$git_line"
