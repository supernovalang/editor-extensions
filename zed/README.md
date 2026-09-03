# Snovalang — Zed Editor Extension

Extensão oficial da linguagem Snovalang para o editor **Zed**.

## Funcionalidades
- Destaque sintático completo (`highlights.scm`)
- Suporte a emparelhamento de chaves, colchetes e parênteses (`brackets.scm`)
- Document outline e navegação de símbolos (`outline.scm`)
- Integração nativa com `snova-lsp` para diagnósticos, hover, definition e completion.

## Instalação no Zed
1. Certifique-se de que o executável `snova-lsp` está disponível no seu `PATH`.
2. Instale como dev extension no Zed apontando para este diretório.

Os grammars são carregados dos diretórios `tree-sitter-snovalang` e
`tree-sitter-snovalang-manifest` neste repositório, usando a revisão fixada em
`extension.toml`. Para atualizar uma revisão publicada, altere os SHAs no
manifesto após gerar e validar os parsers.
