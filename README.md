# inQuesti · instalador

Primeiro passo de uma máquina da inQuesti. Copie **uma** linha, a do seu sistema, e cole no terminal certo.

Use o botão de copiar no canto do bloco. Não selecione com o mouse: num chat, a linha longa pode quebrar em duas.

## Mac

Abra o app **Terminal** e cole:

```bash
curl -fsSL https://inquesti-tech.github.io/inquesti-instalador/i.sh | bash
```

## Linux (Ubuntu, Debian, Fedora)

Abra o **Terminal** e cole a mesma linha do Mac:

```bash
curl -fsSL https://inquesti-tech.github.io/inquesti-instalador/i.sh | bash
```

Funciona em x86 e ARM. O instalador usa `sudo` e pode pedir a senha do seu usuário do Linux.

## Windows

Abra o **PowerShell** (menu Iniciar › digite PowerShell) e cole:

```powershell
irm https://inquesti-tech.github.io/inquesti-instalador/i.ps1 | iex
```

## Qual linha eu uso?

| Seu computador | Onde colar | Linha que começa com |
|---|---|---|
| Mac | Terminal | `curl` |
| Linux | Terminal | `curl` |
| Windows | PowerShell | `irm` |

- Colou a linha do `curl` no PowerShell e deu erro? É a linha errada. No Windows, use a do `irm`.
- Colou a linha do `irm` no Terminal do Mac? Ela não faz nada lá. Use a do `curl`.

## Já instalei antes

Rode a mesma linha de novo. Ela instala só o que falta e atualiza os plugins da inQuesti para a versão publicada.

## O que ela faz

1. Instala o GitHub CLI e faz o seu login no GitHub no navegador.
2. Baixa o instalador de verdade do repositório privado `inQuesti-tech/inquesti-plugins`.
3. Instala o resto: Claude Code, plugins da inQuesti, Azure CLI e os programas de apoio.

Faz algumas perguntas: seu nome, seu e-mail `@inquesti.com.br`, o seu usuário-agente do iOS e se pode instalar o driver ODBC 18 da Microsoft. A senha não aparece na tela.

Você precisa de uma conta do GitHub com acesso à organização `inQuesti-tech`. O guia completo fica no repositório privado: `docs/primeiro-dia.md`.

## Se o endereço curto não responder

As mesmas linhas, com o endereço longo:

Mac e Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.sh | bash
```

Windows:
```powershell
irm https://raw.githubusercontent.com/inQuesti-tech/inquesti-instalador/main/bootstrap.ps1 | iex
```

---

Este repositório é público e só tem o arranque. Não tem segredo nem regra da casa. A fonte destes arquivos é `instalador/` no `inquesti-plugins`: mude lá e publique com `instalador/publicar.sh`.
