# Snovalang — Zed Editor Extension

Extensão oficial da linguagem Snovalang para o editor **Zed**.

## Funcionalidades
- Destaque sintático completo (`highlights.scm`)
- Suporte a emparelhamento de chaves, colchetes e parênteses (`brackets.scm`)
- Document outline e navegação de símbolos (`outline.scm`)
- Integração nativa com `snova-lsp` para diagnósticos, hover, definition e completion.

## Instalação no Zed
1. Compile o servidor com `make` no repositório `snova-lsp`; no Windows o
   executável será criado em `tools/bin/snova-lsp.exe`.
2. Execute o instalador da extensão. O servidor será copiado para
   `%LOCALAPPDATA%\Zed\tools\bin` no Windows e `~/.config/zed/tools/bin` no
   macOS/Linux, e esse diretório será adicionado ao PATH persistente.
3. Instale/recarregue a extensão no Zed.

Os grammars são carregados dos diretórios `tree-sitter-snovalang` e
`tree-sitter-snovalang-manifest` neste repositório, usando a revisão fixada em
`extension.toml`. Para atualizar uma revisão publicada, altere os SHAs no
manifesto após gerar e validar os parsers.
