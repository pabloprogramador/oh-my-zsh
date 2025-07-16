function my_git_prompt() {
  tester=$(git rev-parse --git-dir 2>/dev/null) || return

  INDEX=$(git status --porcelain 2>/dev/null)
  STATUS=""

  # is branch ahead?
  if $(echo "$(git log origin/$(git_current_branch)..HEAD 2>/dev/null)" | grep '^commit' &>/dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi

  # is branch behind?
  if $(echo "$(git log HEAD..origin/$(git_current_branch) 2>/dev/null)" | grep '^commit' &>/dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &>/dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi

  # is anything unstaged?
  if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &>/dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi

  # is anything untracked?
  if $(echo "$INDEX" | grep '^?? ' &>/dev/null); then
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi

  # is anything unmerged?
  if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &>/dev/null); then
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
  if typeset -f toolbox_prompt_info >/dev/null; then
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
    # print -P "\n%F{124}:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%f"
    print -Pn "\n"

    # Cores do arco-íris (R, Laranja, Amarelo, Verde, Azul, Anil, Violeta)
    # local colors=(196 202 226 46 33 57 201 207)
    local colors=(120 118 82 76 70 64 28 22)

    local total_length=80
    local segments=${#colors[@]}
    local per_segment=$((total_length / segments))
    print -P "               %F{120}|>_________________________________"
    print -P "(^_^) [########[]_________________________________>"
    print -P "               |>"
    print -P ""
    for color in "${colors[@]}"; do
      for ((i = 0; i < per_segment; i++)); do
        print -Pn "%F{$color}━"
      done
    done
    print -P "\n sizeOn/sizeOff"
    print -P "%f" # reset cor
    LAST_DIR="$PWD"
  fi
}

LAST_DIR=""
DIR_INFO_CACHE=""
DIR_INFO_TIMESTAMP=0
SHOW_DIR_INFO=false

function sizeinfo-on() {
  export SHOW_DIR_INFO=true
  echo "📁✅ SHOW SIZE FILES"
}

function sizeinfo-off() {
  export SHOW_DIR_INFO=false
  echo "📁🚫 HIDE SIZES FILES"
}

function dir_info() {
  local now=$(date +%s)
  if ((now - DIR_INFO_TIMESTAMP > 10)); then
    local files=$(find . -maxdepth 1 -type f | wc -l | tr -d ' ')
    local dirs=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

    DIR_INFO_CACHE="$dirs %{\e[38;5;24m%}folders%{$reset_color%}, $files %{\e[38;5;24m%}files%{$reset_color%}"

    if [[ "$SHOW_DIR_INFO" == true ]]; then
      local size=$(du -sh . 2>/dev/null | cut -f1)
      DIR_INFO_CACHE="$DIR_INFO_CACHE, $size"
    fi

    DIR_INFO_TIMESTAMP=$now
  fi
  echo "$DIR_INFO_CACHE"
}

# local ret_status="%(?:%{$fg_bold[green]%}✓:%{$fg_bold[red]%}❌)%?%{$reset_color%}"
local ret_status="%(?:%{$fg_bold[green]%}✓:%{$fg_bold[red]%}❌)%{$reset_color%}"

PROMPT=$'\n$(_toolbox_prompt_info)$(ssh_connection)$(my_git_prompt)\n%{\e[1;33m%} 📁 %~%{\e[0m%} $(dir_info)\n[${ret_status}] %# '

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

# fzf  --keep-right -m --style=full --ignore-case --header-border=rounded --footer-border=rounded --color=fg+:bright-green,hl+:bright-yellow,marker:bright-green,pointer:bright-red --ansi --preview-window=right:60% --marker=✔ --bind=ctrl-s:toggle-sort --preview "bat --style=numbers --color=always {}"
#!/bin/bash
fn() {
  case "$1" in
  -new)
    # Ordena do mais novo para mais velho
    find . -type f -exec stat -f "%m %z %N" {} + 2>/dev/null |
      sort -rn |
      awk 'BEGIN {
        BLUE = "\033[1;34m"
        GRAY = "\033[0;37m"
        RESET = "\033[0m"
      }
      {
        cmd = "date -r " $1 " +\"%Y-%m-%d %H:%M\""
        cmd | getline date_str
        close(cmd)

        size = $2
        file = substr($0, index($0,$3))

        hum=""
        if (size >= 1073741824) hum=sprintf("%.1fG", size/1073741824);
        else if (size >= 1048576) hum=sprintf("%.1fM", size/1048576);
        else if (size >= 1024) hum=sprintf("%.1fK", size/1024);
        else hum=size "B";

        printf "%s%s%s | %s%6s%s | %s\n", BLUE, date_str, RESET, GRAY, hum, RESET, file
      }' |
      fzf -m --ansi \
        --preview='bat --style=numbers --color=always "$(echo {} | cut -d"|" -f3- | xargs)" || head -n 30 "$(echo {} | cut -d"|" -f3- | xargs)" || echo "🔒 Sem permissão para visualizar"' \
        --color=fg+:white,bg+:black,hl+:bright-magenta,marker:yellow,pointer:white \
        --preview-window=right:40% \
        --bind=ctrl-s:toggle-sort \
        --marker="*" \
        --header="📂 Arquivos ordenados por data (mais novo → mais velho)" | pbcopy
    ;;

  -old)
    # Ordena do mais velho para o mais novo (inverte a ordem)
    fn -new | tac
    ;;

  -big)
    # Ordena por tamanho decrescente
    find . -type f -exec stat -f "%z %N" {} + 2>/dev/null |
      sort -rn |
      awk 'BEGIN {
        GRAY = "\033[0;37m"
        RESET = "\033[0m"
      }
      {
        size = $1
        file = substr($0, index($0,$2))

        hum=""
        if (size >= 1073741824) hum=sprintf("%.1fG", size/1073741824);
        else if (size >= 1048576) hum=sprintf("%.1fM", size/1048576);
        else if (size >= 1024) hum=sprintf("%.1fK", size/1024);
        else hum=size "B";

        printf "%s%6s%s | %s\n", GRAY, hum, RESET, file
      }' |
      fzf -m --ansi \
        --preview='bat --style=numbers --color=always "$(echo {} | cut -d"|" -f2- | xargs)" || head -n 30 "$(echo {} | cut -d"|" -f2- | xargs)" || echo "🔒 Sem permissão para visualizar"' \
        --color=fg+:white,bg+:black,hl+:bright-magenta,marker:yellow,pointer:white \
        --preview-window=right:40% \
        --bind=ctrl-s:toggle-sort \
        --marker="*" \
        --header="📊 Arquivos ordenados por tamanho (maior → menor)"
    ;;

  -small)
    fn -big | tac
    ;;

  -az)
    find . -type f | sort | fzf -m --ansi \
      --preview='bat --style=numbers --color=always {} || head -n 30 {} || echo "🔒 Sem permissão para visualizar"' \
      --color=fg+:white,bg+:black,hl+:bright-magenta,marker:yellow,pointer:white \
      --preview-window=right:40% \
      --bind=ctrl-s:toggle-sort \
      --marker="*" \
      --header="🔐 Arquivos em ordem alfabética A-Z" | pbcopy
    ;;

  -za)
    fn -az | tac
    ;;

  -commit)
    git log --oneline --decorate |
      fzf --ansi --preview='git show $(echo {} | cut -d" " -f1)' \
        --header="🔄 Commits - Enter para checkout" \
        --bind='enter:execute(git checkout $(echo {} | cut -d" " -f1))'
    ;;

  -branch)
    git branch | sed 's/^..//' |
      fzf --preview='git log -n 5 {}' \
        --header="🐝 Branches - Enter para checkout" \
        --bind='enter:execute(git checkout {})'
    ;;

  -del)
    fzf -m --header="🗑️ Selecione arquivos ou pastas - Enter para mover para a Lixeira" \
      --bind='enter:execute-silent(osascript -e "tell app \"Finder\" to delete POSIX file \"$(realpath {})\"" 2>/dev/null)+abort' \
      --color=fg+:white,bg+:black,hl+:bright-red,marker:red,pointer:white
    ;;

  -kill)
    ps -eo pid,comm |
      fzf --header="☠ Processos - Enter para matar" \
        --bind='enter:execute-silent(kill -9 {1})'
    ;;

  -zip)
    timestamp=$(date +"%m-%d-%Y-%H-%M-%S")
    zipname="file${timestamp}.zip"

    files=$(fzf -m --read0 --print0 \
      --header="🗜️ Selecione arquivos - Enter para compactar com 7z em '$zipname'" \
      --preview='ls -lh {} || stat {}')

    if [ -z "$files" ]; then
      echo "❌ Nenhum arquivo selecionado."
      return 1
    fi

    # Compacta usando xargs com -0 para lidar com espaços/linhas
    echo "$files" | xargs -0 7z a -tzip "$zipname"
    echo "✅ Arquivos compactados em $zipname"
    ;;

  -unzip)
    zipfile=$(find . -type f -name "*.zip" | fzf --header="📦 Selecione um arquivo .zip para descompactar" \
      --preview='7z l {}' \
      --color=fg+:white,bg+:black,hl+:bright-cyan,marker:cyan,pointer:white)

    if [ -z "$zipfile" ]; then
      echo "❌ Nenhum arquivo .zip selecionado."
      return 1
    fi

    # Nome da pasta sem a extensão
    foldername=$(basename "$zipfile" .zip)

    # Cria a pasta
    mkdir -p "$foldername"

    # Extrai o conteúdo para a pasta criada
    7z x "$zipfile" -o"$foldername"

    echo "✅ Arquivo '$zipfile' extraído para a pasta '$foldername'."

    # Abre a pasta no Finder
    open "$foldername"

    ;;

  -code)
    fzf --header="💻 Abrir com VS Code" --bind='enter:execute(code {})'
    ;;

  -cache)
    history | fzf --header="⏲ Comandos anteriores"
    ;;

  -help | *)
    echo -e "\n🔍  Comandos disponíveis no fn:\n"
    echo "  -new      Arquivos mais novos"
    echo "  -old      Arquivos mais antigos"
    echo "  -big      Arquivos maiores"
    echo "  -small    Arquivos menores"
    echo "  -az       Ordem alfabética A-Z"
    echo "  -za       Ordem alfabética Z-A"
    echo "  -commit   Ver e checkout em commits"
    echo "  -branch   Alternar branches Git"
    echo "  -kill     Matar processo via fzf"
    echo "  -del      Apaga arquivo ou pasta"
    echo "  -zip      Selecionar arquivos e zipar"
    echo "  -code     Buscar e abrir código no VS Code"
    echo "  -cache    Histórico de comandos"
    echo "  -help     Mostrar esta ajuda"
    ;;
  esac
}
