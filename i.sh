#!/usr/bin/env bash
# Bootstrap do instalador inQuesti (macOS e Linux). É o ÚNICO arquivo público: não tem segredo nem regra da casa.
# O repo inquesti-plugins é privado, então este script só instala o gh (e o git), faz o SEU login no GitHub e baixa
# o instalador de verdade (instalador/instalar.sh) do repo privado com `gh api`, e o executa.
#
#   curl -fsSL https://inquesti-tech.github.io/inquesti-instalador/i.sh | bash
#   curl -fsSL https://inquesti-tech.github.io/inquesti-instalador/i.sh | bash -s -- --simular   (mostra o que faria)
#   (endereço longo, igual: https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.sh)
#
# No Windows a linha é outra (PowerShell):  irm https://inquesti-tech.github.io/inquesti-instalador/i.ps1 | iex
# Se este arquivo cair num `irm … | iex` do PowerShell, a linha abaixo esconde o bash num comentário de bloco do
# PowerShell: ele só mostra qual linha usar e não executa nada (o fim do arquivo é a parte do PowerShell).
#
# INQUESTI_REF=<branch ou tag> baixa o instalador de outra referência (padrão: main).
echo `# <#` >/dev/null
set -euo pipefail
REPO="inQuesti-tech/inquesti-plugins"
REF="${INQUESTI_REF:-main}"
SIMULAR=0; [ "${1:-}" = "--simular" ] && SIMULAR=1
tem(){ command -v "$1" >/dev/null 2>&1; }
faria(){ printf "  · faria: %s\n" "$1"; }
LINHA_WINDOWS="irm https://inquesti-tech.github.io/inquesti-instalador/i.ps1 | iex"

printf "\n\033[1;32minQuesti · preparando o instalador\033[0m%s\n" "$([ $SIMULAR = 1 ] && echo ' (simulação)')"
SO=""
case "$(uname)" in
  Darwin) SO=mac ;;
  Linux) SO=linux
    if grep -qsi microsoft /proc/version && [ "${INQUESTI_WSL:-}" != "1" ]; then
      echo "Isto é o WSL (Linux dentro do Windows). No Windows, abra o PowerShell e use:"
      echo "  $LINHA_WINDOWS"
      echo "(para instalar no WSL mesmo assim: INQUESTI_WSL=1)"; exit 2
    fi ;;
  *) echo "Este bootstrap é para macOS e Linux. No Windows, abra o PowerShell e use:"; echo "  $LINHA_WINDOWS"; exit 2 ;;
esac
SUDO=""; [ "$SO" = linux ] && [ "$(id -u)" != 0 ] && SUDO="sudo"

if [ "$SO" = mac ] && ! tem gh; then
  if ! tem brew; then
    if [ $SIMULAR = 1 ]; then faria "instalar o Homebrew"; else
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
      for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [ -x "$b" ] && eval "$("$b" shellenv)"; done
    fi
  fi
  if [ $SIMULAR = 1 ]; then faria "brew install gh"; else brew install gh; fi
fi

if [ "$SO" = linux ] && { ! tem gh || ! tem git; }; then
  # git antes do login: sem ele, o `gh auth login` sai com erro depois de autenticar (visto no Windows, 26/10/2026).
  # gh pelo repositório oficial do GitHub CLI (https://github.com/cli/cli/blob/trunk/docs/install_linux.md).
  if tem apt-get; then
    if [ $SIMULAR = 1 ]; then faria "sudo apt-get install git e gh (repositório oficial cli.github.com/packages)"; else
      tem gh || {
        $SUDO mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $SUDO tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
        $SUDO chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
          $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      }
      $SUDO apt-get update -qq
      $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git gh
    fi
  elif tem dnf; then
    if [ $SIMULAR = 1 ]; then faria "sudo dnf install git e gh (repositório oficial cli.github.com/packages)"; else
      tem gh || curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo | $SUDO tee /etc/yum.repos.d/gh-cli.repo >/dev/null
      $SUDO dnf install -y -q git gh
    fi
  else
    echo "  Este bootstrap cobre Linux com apt (Ubuntu, Debian) ou dnf (Fedora). Instale git e gh e rode de novo."; exit 2
  fi
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  if [ $SIMULAR = 1 ]; then faria "gh auth login --web (você entra com a sua conta do GitHub da inQuesti)"
  else
    echo "  Entre com a sua conta do GitHub (a que tem acesso à organização inQuesti-tech):"
    gh auth login --hostname github.com --git-protocol https --web </dev/tty || true
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
exit 0
#> > $null
# Daqui para baixo so o PowerShell le (o bash saiu acima). Sem acento: o PowerShell 5.1 le o download como Latin-1.
Write-Host ""
Write-Host "Esta e a linha do Mac e do Linux (bash). Nada foi instalado." -ForegroundColor Yellow
Write-Host "No Windows, no PowerShell, use esta:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  irm https://inquesti-tech.github.io/inquesti-instalador/i.ps1 | iex" -ForegroundColor Green
Write-Host ""
