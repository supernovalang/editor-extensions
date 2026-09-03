# Snovalang — VS Code Extension

Extensão oficial do Snovalang para Visual Studio Code com integração completa com `snova-lsp`.

## Funcionalidades
- **Syntax Highlighting**: Gramática TextMate completa com suporte a keywords, tipos, interpolação de strings `${...}`, números e decoradores.
- **Language Server Protocol (LSP)**: Autocomplete inteligente, diagnósticos de compilação em tempo real (`publishDiagnostics`), hover, go to definition e document symbols.
- **Snippets**: Atalhos de código para `func`, `method`, `class`, `struct`, `enum`, `match`, `for` e `pulsar`.

## Instalação e Uso
1. Certifique-se de que o executável `snova-lsp` está presente no seu `PATH` (ou configure em `snova.lsp.serverPath`).
2. Abra qualquer arquivo `.snova` ou `.sno` no VS Code.
