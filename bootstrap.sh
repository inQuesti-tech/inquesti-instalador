#!/usr/bin/env bash
# Bootstrap do instalador inQuesti (macOS). É o ÚNICO arquivo público: não tem segredo nem regra da casa.
# O repo inquesti-plugins é privado, então este script só instala o gh, faz o SEU login no GitHub e baixa
# o instalador de verdade (instalador/instalar.sh) do repo privado com `gh api`, e o executa.
#
#   curl -fsSL https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.sh | bash
#   curl -fsSL …/bootstrap.sh | bash -s -- --simular      (mostra o que faria)
#
# INQUESTI_REF=<branch ou tag> baixa o instalador de outra referência (padrão: main).
set -euo pipefail
REPO="inQuesti-tech/inquesti-plugins"
REF="${INQUESTI_REF:-main}"
SIMULAR=0; [ "${1:-}" = "--simular" ] && SIMULAR=1
tem(){ command -v "$1" >/dev/null 2>&1; }
faria(){ printf "  · faria: %s\n" "$1"; }

printf "\n\033[1;32minQuesti · preparando o instalador\033[0m%s\n" "$([ $SIMULAR = 1 ] && echo ' (simulação)')"
[ "$(uname)" = "Darwin" ] || { echo "Este bootstrap é para macOS. No Windows: bootstrap.ps1"; exit 2; }

if ! tem gh; then
  if ! tem brew; then
    if [ $SIMULAR = 1 ]; then faria "instalar o Homebrew"; else
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
      for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
    fi
  fi
  if [ $SIMULAR = 1 ]; then faria "brew install gh"; else brew install gh; fi
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  if [ $SIMULAR = 1 ]; then faria "gh auth login --web (você entra com a sua conta do GitHub da inQuesti)"
  else
    echo "  Entre com a sua conta do GitHub (a que tem acesso à organização inQuesti-tech):"
    gh auth login --hostname github.com --git-protocol https --web </dev/tty
  fi
fi

destino="$(mktemp -d)/instalar.sh"
if gh auth status --hostname github.com >/dev/null 2>&1; then
  gh api -H "Accept: application/vnd.github.raw" "repos/$REPO/contents/instalador/instalar.sh?ref=$REF" > "$destino" || {
    echo "  Não consegui baixar o instalador de $REPO: confira se a sua conta tem acesso à organização inQuesti-tech."; exit 1; }
elif [ $SIMULAR = 1 ] && [ -f "$(dirname "${BASH_SOURCE[0]:-$0}")/instalar.sh" ]; then
  faria "baixar instalador/instalar.sh de $REPO@$REF com gh api"
  cp "$(dirname "${BASH_SOURCE[0]:-$0}")/instalar.sh" "$destino"   # simulação de um clone: usa o vizinho
else
  [ $SIMULAR = 1 ] && { faria "baixar instalador/instalar.sh de $REPO@$REF com gh api e rodá-lo"; exit 0; }
  echo "  Sem login no GitHub não dá para baixar o instalador."; exit 1
fi
if (: </dev/tty) 2>/dev/null; then exec bash "$destino" "$@" </dev/tty; else exec bash "$destino" "$@"; fi
