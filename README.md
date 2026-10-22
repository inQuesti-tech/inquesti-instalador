# inQuesti · instalador

Primeiro passo de uma máquina nova da inQuesti. Este repositório é público e só tem o arranque: ele instala o GitHub CLI, faz o seu login no GitHub e baixa o instalador de verdade do repositório privado `inQuesti-tech/inquesti-plugins`. Não tem segredo nem regra da casa.

**macOS** (no Terminal):
```
curl -fsSL https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.sh | bash
```

**Windows** (no PowerShell):
```
irm https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.ps1 | iex
```

Você precisa de uma conta do GitHub com acesso à organização `inQuesti-tech`. O guia completo fica no repositório privado: `docs/primeiro-dia.md`.

A fonte destes arquivos é `instalador/` no `inquesti-plugins`. Mude lá e copie para cá.
