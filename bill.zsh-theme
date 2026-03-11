// PARA COMPILAR: source ~/.zshrc
// copiar para ls ~/.oh-my-zsh/custom/themes
// ZSH_THEME="mortalscumbag"

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
FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS_2

  if [ -z "$1" ]; then
  find . -maxdepth 1 | while read -r file; do
  echo "$(basename $file):$file"
  done |
  fzf --with-nth=1 --delimiter=":" --keep-right -m --style=full --ignore-case --header-border=rounded --footer-border=rounded --color=$FZF_DEFAULT_OPTS --ansi --preview-window=right:70% --marker=✔ --bind=ctrl-s:toggle-sort \
  --bind='ctrl-s:execute(code $(awk -F ":" "{print \$2}" <<< {}) | echo $(awk -F ":" "{print \$2}" <<< {}) | pbcopy | echo $(awk -F ":" "{print \$2}" <<< {})),enter:execute(open -R $(awk -F ":" "{print \$2}" <<< {}) | echo $(awk -F ":" "{print \$2}" <<< {}) | pbcopy | echo $(awk -F ":" "{print \$2}" <<< {})),ctrl-d:execute(osascript -e "tell app \"Finder\" to delete POSIX file \"$(realpath $(awk -F ":" "{print \$2}" <<< {}) )\"" 2>/dev/null)' \
   --header="ENTER CTR+S CTRL+D" \
  --preview='
    filename=$(awk -F ":" "{print \$1}" <<< {})
    filepath=$(awk -F ":" "{print \$2}" <<< {})
    
    echo "📁 : $filename"
    echo "📁 : $filepath"
    echo "───────────────────────────────────"
    bat --wrap=character --paging=never --style=numbers --color=always "$filepath"
  '
  return
fi
  case "$1" in
  -all)
  find . | while read -r file; do
  echo "$(basename $file):$file"
  done |
  fzf --with-nth=1 --delimiter=":" --keep-right -m --style=full --ignore-case --header-border=rounded --footer-border=rounded --color=$FZF_DEFAULT_OPTS --ansi --preview-window=right:70% --marker=✔ --bind=ctrl-s:toggle-sort \
  --bind='ctrl-s:execute(code $(awk -F ":" "{print \$2}" <<< {}) | echo $(awk -F ":" "{print \$2}" <<< {}) | pbcopy | echo $(awk -F ":" "{print \$2}" <<< {})),enter:execute(open -R $(awk -F ":" "{print \$2}" <<< {}) | echo $(awk -F ":" "{print \$2}" <<< {}) | pbcopy | echo $(awk -F ":" "{print \$2}" <<< {})),ctrl-d:execute(osascript -e "tell app \"Finder\" to delete POSIX file \"$(realpath $(awk -F ":" "{print \$2}" <<< {}) )\"" 2>/dev/null)' \
   --header="ENTER CTR+S CTRL+D" \
  --preview='
    filename=$(awk -F ":" "{print \$1}" <<< {})
    filepath=$(awk -F ":" "{print \$2}" <<< {})
    
    echo "📁 : $filename"
    echo "📁 : $filepath"
    echo "───────────────────────────────────"
    bat --wrap=character --paging=never --style=numbers --color=always "$filepath"
  '
  return
  ;;
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
        --color=$FZF_DEFAULT_OPTS_1 \
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
      fzf --no-sort -m --ansi \
        --preview='bat --style=numbers --color=always "$(echo {} | cut -d"|" -f2- | xargs)" || head -n 30 "$(echo {} | cut -d"|" -f2- | xargs)" || echo "🔒 Sem permissão para visualizar"' \
        --color=$FZF_DEFAULT_OPTS_1 \
        --preview-window=right:40% \
        --bind=ctrl-s:toggle-sort \
        --marker="*" \
        --header="📊 Arquivos ordenados por tamanho (maior → menor)"
    ;;

  -small)
    fn -big | tac
    ;;

  -merge)
    file=$(grep -rl '<<<<<<< HEAD' . 2>/dev/null | fzf \
      --header="🧨 <ENTER> OPEN :|: <TAB> VS Code :|: <ESC> EXIT" \
      --preview='bat --style=numbers --color=always {} || head -n 20 {}' \
      --bind='tab:execute(code {} | echo {} | pbcopy | echo {}),enter:execute(open -R {} | echo {} | pbcopy | echo {})' \
      --color=$FZF_DEFAULT_OPTS_1)

    ;;

  -commit)
    git log --oneline --decorate |
      fzf --ansi --preview='git show $(echo {} | cut -d" " -f1)' \
        --header="🔄 Commits - Enter para checkout" \
        --color=$FZF_DEFAULT_OPTS_1 \
        --bind='enter:execute(git checkout $(echo {} | cut -d" " -f1))'
    ;;

  -branch)
    git fetch --all
    git branch -a| sed 's/^..//' |
      fzf --preview='git log -n 5 {}' \
      --color=$FZF_DEFAULT_OPTS_1 \
        --header="🐝 Branches - Enter para checkout" \
        --bind='enter:execute(git checkout {})'
    ;;

  -kill)
    ps -eo pid,comm |
      fzf --header="☠ Processos - Enter para matar" \
      --color=$FZF_DEFAULT_OPTS_3 \
      --bind='enter:execute-silent(kill -9 {1})'
    ;;

  -nav)
    nav_dir="."  # Começa no diretório atual
while true; do
  cd "$nav_dir" || break  # Vai até a pasta, se falhar sai do loop

  selected=$(find . -maxdepth 1 -type d ! -name '.' \
    | sed 's|^\./||' \
    | sort \
    | fzf --print-query --header="📁 ⏎: Entrar | .. Voltar | quit Sair"  \
          --prompt="$PWD > " \
          --color="$FZF_DEFAULT_OPTS_2")

  key=$(printf '%s\n' "$selected" | head -n 1)
  result=$(printf '%s\n' "$selected" | tail -n +2)
echo $key
echo $result
  if [[ "$key" = ".." ]]; then
    # Se não digitou nada, sobe uma pasta
    nav_dir=$(dirname "$PWD")
  elif [[ "$key" = "quit" ]]; then
    echo "GAME OVER"
    break
  else
    # Entra na pasta selecionada
    nav_dir="$PWD/$result"
  fi
done
;;

-teste2)
selected=$(fzf --print-query --header="Selecione múltiplos arquivos")
key=$(printf '%s\n' "$selected" | head -n 1)
result=$(printf '%s\n' "$selected" | tail -n +2)

echo "Query: $key"
echo "Selecionados:"
echo "$result"
;;

  -zip)
    timestamp=$(date +"%m-%d-%Y-%H-%M-%S")
    zipname="file${timestamp}.zip"

    files=$(fzf -m --read0 --print0 \
      --header="🗜️ Selecione arquivos - Enter para compactar com 7z em '$zipname'" \
      --color=$FZF_DEFAULT_OPTS_2 \
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
      --color=$FZF_DEFAULT_OPTS_2)

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

    # Prompt para abrir no Finder
    echo -n "📂 Deseja abrir a pasta no Finder? [s/N] ➤ "
    read -r resposta

    if [[ "$resposta" =~ ^[sS]$ ]]; then
      open "$foldername"
      echo "📁 Finder aberto em '$foldername'."
    else
      echo "🛑 Pasta não aberta."
    fi
    ;;

  
  # echo "📦 Tamanho: $(stat -f%z {} | awk '\''{ hum=$1; if(hum>=1073741824) hum=sprintf(\"%.1fG\",hum/1073741824); else if(hum>=1048576) hum=sprintf(\"%.1fM\",hum/1048576); else if(hum>=1024) hum=sprintf(\"%.1fK\",hum/1024); else hum=hum\"B\"; print hum }'\')"
  #echo "🕒 Modificado: $(stat -f"%Sm" -t "%Y-%m-%d %H:%M:%S" {})"

  -teste)
 # temp = 'bat --style=numbers --color=always {} "$(awk -F '\'':::'\'' '\''{print \$2}'\'' <<<)" || head -n 30 {}';
 find . -maxdepth 1 | while read -r file; do
  echo "$(basename $file):$file"
  done |
  fzf --with-nth=1 --delimiter=":" --keep-right -m --style=full --ignore-case --header-border=rounded --footer-border=rounded --color=$FZF_DEFAULT_OPTS --ansi --preview-window=right:70% --marker=✔ --bind=ctrl-s:toggle-sort \
  --preview='
    filename=$(awk -F ":" "{print \$1}" <<< {})
    filepath=$(awk -F ":" "{print \$2}" <<< {})
    
    echo "📁 : $filename"
    echo "📁 : $filepath"
    echo "───────────────────────────────────"
    bat --wrap=character --paging=never --style=numbers --color=always "$filepath"
  '
  ;;

  -cache)
    history | cut -c 8- | awk '!seen[$0]++' | fzf --header="⏲ Comandos anteriores" \
    --color=$FZF_DEFAULT_OPTS_2 \
    --bind="enter:execute(echo {} | pbcopy | echo {})+abort"
    ;;

  -help | *)
    echo -e "\n🔍  Comandos disponíveis no fn:\n"
    echo "  -nav      Arquivos mais novos"
    echo "  -new      Arquivos mais novos"
    echo "  -old      Arquivos mais antigos"
    echo "  -big      Arquivos maiores"
    echo "  -small    Arquivos menores"
    echo "  -commit   Ver e checkout em commits"
    echo "  -branch   Alternar branches Git"
    echo "  -merge    Mostra os arquivos com conflitos"
    echo "  -kill     Matar processo via fzf"
    echo "  -zip      Selecionar arquivos e zipar"
    echo "  -unzip    Descompactar"
    echo "  -cache    Histórico de comandos"
    echo "  -help     Mostrar esta ajuda"
    ;;
  esac
}

# 1. Dark — Visual Studio Code (Dark+ Style)
FZF_DEFAULT_OPTS_1='
fg:252,bg:235,
fg+:15,bg+:237,
hl:39,hl+:81,
prompt:81,pointer:204,
marker:110,spinner:39,
info:250,header:60,
border:238,query:81,gutter:235'

# 2. High Contrast — Matrix Style (Green on Black)
FZF_DEFAULT_OPTS_2='
fg:46,bg:0,
fg+:0,bg+:22,
hl:201,hl+:231,
prompt:bright-yellow,pointer:46,
marker:196,spinner:231,
info:118,header:28,
border:22,query:118,gutter:0'

# 3. Danger — Red & Yellow Warning Theme
FZF_DEFAULT_OPTS_3='
fg:white,bg:1,
fg+:bright-red,bg+:bright-yellow,
hl:208,hl+:black,
prompt:bright-white,pointer:bright-white,
marker:bright-red,spinner:white,
border:196,query:226,gutter:1'

# 4. Deep Blue — Navy Theme
FZF_DEFAULT_OPTS_4='
fg:153,bg:17,
fg+:255,bg+:18,
hl:81,hl+:117,
prompt:39,pointer:123,
marker:Yellow,spinner:87,
info:189,header:24,
border:Yellow,query:81,gutter:17'

# 5. Soft Light — Pastel Yellow Theme
FZF_DEFAULT_OPTS_5='
fg:221,bg:235,
fg+:234,bg+:187,
hl:136,hl+:130,
prompt:136,pointer:94,
marker:130,spinner:180,
info:172,header:229,
border:180,query:130,gutter:254'
