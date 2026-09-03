# Snovalang Editor Extensions

Official editor extensions for **VS Code** and **Zed** providing complete editing and LSP support for Snovalang.

## Extensions

### 1. VS Code ([`vscode/`](vscode/))
- TextMate grammar highlighting (`.snova`, `.sno`)
- Code snippets (`func`, `method`, `class`, `struct`, `enum`, `match`, `for`, `pulsar`)
- Language configuration (bracket matching, auto-closing pairs)
- LSP Client connecting to `snova-lsp` via stdio

### 2. Zed Editor ([`zed/`](zed/))
- Tree-sitter query mappings (`highlights.scm`, `brackets.scm`, `outline.scm`)
- Language server integration for `snova-lsp`
