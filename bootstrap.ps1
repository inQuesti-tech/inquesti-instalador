# Bootstrap do instalador inQuesti (Windows). E o UNICO arquivo publico: nao tem segredo nem regra da casa.
# O repo inquesti-plugins e privado, entao este script so instala o gh, faz o SEU login no GitHub e baixa
# o instalador de verdade (instalador/instalar.ps1) do repo privado com `gh api`, e o executa.
#
#   irm https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.ps1 | iex
#   $env:INQUESTI_SIMULAR = "1"; irm .../bootstrap.ps1 | iex        (mostra o que faria)
#
# $env:INQUESTI_REF = "<branch ou tag>" baixa o instalador de outra referencia (padrao: main).
# "Continue", nao "Stop": com "Stop", o aviso do gh no stderr ("You are not logged into any GitHub hosts")
# vira erro fatal no PowerShell e o bootstrap para antes do login (visto numa maquina limpa em 26/10/2026).
# Cada passo confere o $LASTEXITCODE.
$ErrorActionPreference = "Continue"
$Repo = "inQuesti-tech/inquesti-plugins"
$Ref = if ($env:INQUESTI_REF) { $env:INQUESTI_REF } else { "main" }
$Simular = ($env:INQUESTI_SIMULAR -eq "1")
function Tem($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
function Faria($m) { Write-Host "  - faria: $m" }

Write-Host "`ninQuesti - preparando o instalador$(if ($Simular) {' (simulacao)'})" -ForegroundColor Green
if (-not (Tem winget)) { Write-Host "Falta o winget (App Installer da Microsoft Store). Instale e rode de novo."; return }

# Git antes do login: o `gh auth login` configura o Git e, sem ele, sai com erro mesmo depois de logar
# (maquina limpa, 26/10/2026: "unable to find git executable in PATH").
function Recarregar-Path { $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") }
if (-not (Tem git)) {
  if ($Simular) { Faria "winget install --id Git.Git" } else {
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    Recarregar-Path } }

if (-not (Tem gh)) {
  if ($Simular) { Faria "winget install --id GitHub.cli" } else {
    winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") } }

$logado = $false
if (Tem gh) { gh auth status --hostname github.com 2>&1 | Out-Null; $logado = ($LASTEXITCODE -eq 0) }
if (-not $logado) {
  if ($Simular) { Faria "gh auth login --web (voce entra com a sua conta do GitHub da inQuesti)" } else {
    Write-Host "  Entre com a sua conta do GitHub (a que tem acesso a organizacao inQuesti-tech):"
    gh auth login --hostname github.com --git-protocol https --web
    # Vale o estado final, nao o codigo de saida do login (ele pode falhar num passo depois de autenticar).
    gh auth status --hostname github.com 2>&1 | Out-Null
    $logado = ($LASTEXITCODE -eq 0) } }

if (-not $logado) {
  if ($Simular) { Faria "baixar instalador/instalar.ps1 de $Repo@$Ref com gh api e roda-lo -Simular"; return }
  Write-Host "  Sem login no GitHub nao da para baixar o instalador."; return }

$destino = Join-Path ([IO.Path]::GetTempPath()) "inquesti-instalar.ps1"
gh api -H "Accept: application/vnd.github.raw" "repos/$Repo/contents/instalador/instalar.ps1?ref=$Ref" | Set-Content -Path $destino -Encoding UTF8
if ($LASTEXITCODE -ne 0) { Write-Host "  Nao consegui baixar o instalador de ${Repo}: confira se a sua conta tem acesso a organizacao inQuesti-tech."; return }
if ($Simular) { powershell -ExecutionPolicy Bypass -File $destino -Simular } else { powershell -ExecutionPolicy Bypass -File $destino }
