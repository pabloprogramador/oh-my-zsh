LAST_DIR=""

function my_git_prompt() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return

  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""

  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi

  # is branch behind?
  if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi

  if [[ -n $STATUS ]]; then
    STATUS=" $STATUS"
  fi

  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(my_current_branch)$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function my_current_branch() {
  echo $(git_current_branch || echo "(no branch)")
}

function ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[red]%}(ssh) "
  fi
}

function _toolbox_prompt_info() {
  if typeset -f toolbox_prompt_info > /dev/null; then
    toolbox_prompt_info
  fi
}

function preexec() {
  echo ""
}

# Variável para lembrar o último diretório mostrado
LAST_DIR=""

function precmd() {
  # Função chamada antes do prompt aparecer
# for i in {240..255}; do print -P "%F{$i}Color $i%f"; done
  # Se a pasta mudou desde a última vez...
  if [[ "$PWD" != "$LAST_DIR" ]]; then
    echo -e "\n─────────────────────────────"  # Linha separadora
    LAST_DIR="$PWD"                          # Atualiza o último diretório
  fi
}

function dir_info() {
  local files=$(find . -maxdepth 1 -type f | wc -l | tr -d ' ')
  local dirs=$(find . -maxdepth 1 -type d | tail -n +2 | wc -l | tr -d ' ')
  local size=$(du -sh . 2>/dev/null | cut -f1)

  echo "($files arquivos, $dirs pastas, $size)"
}


# local ret_status="%(?:%{$fg_bold[green]%}✓:%{$fg_bold[red]%}❌)%?%{$reset_color%}"
local ret_status="%(?:%{$fg_bold[green]%}✓:%{$fg_bold[red]%}❌)%{$reset_color%}"


PROMPT=$'\n$(_toolbox_prompt_info)$(ssh_connection)$(my_git_prompt)\n%{\e[1;33m%}📁 %~%{\e[0m%}\n[${ret_status}] %# '


# ✅❌


ZSH_THEME_PROMPT_RETURNCODE_PREFIX="%{$fg_bold[red]%}"
# ZSH_THEME_GIT_PROMPT_PREFIX=" $fg[white]‹ %{$fg_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[green]%}↓"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[aquamarine]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}●"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[yellow]%}●"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}✕"
#ZSH_THEME_GIT_PROMPT_SUFFIX=" $fg_bold[white]›%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX=" $fg[white]‹ %{\e[38;5;240m%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=" $fg_bold[white]›%{$reset_color%}"
