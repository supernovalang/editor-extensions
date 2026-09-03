; Keywords
[
  "package"
  "import"
  "class"
  "struct"
  "enum"
  "interface"
  "func"
  "method"
  "let"
  "var"
  "const"
  "if"
  "else"
  "while"
  "for"
  "in"
  "match"
  "return"
  "break"
  "continue"
  "try"
  "catch"
  "throw"
  "defer"
  "async"
  "await"
  "pulsar"
  "this"
  "new"
  "as"
  "is"
] @keyword

; Visibility modifiers
[
  "public"
  "private"
  "protected"
  "override"
  "static"
] @keyword.modifier

; Booleans & Literals
[
  "true"
  "false"
] @boolean

; Primitive Types
[
  "int"
  "long"
  "double"
  "decimal"
  "string"
  "bool"
  "unit"
] @type.builtin

; Strings and Characters
(string_literal) @string
(escape_sequence) @string.escape
(char_literal) @character

; Numbers
(number_literal) @number

; Comments
(line_comment) @comment
(block_comment) @comment

; Functions and Methods
(func_decl name: (identifier) @function)
(method_decl name: (identifier) @function.method)
(call_expr callee: (identifier) @function.call)

; Types and Structs
(class_decl name: (identifier) @type)
(struct_decl name: (identifier) @type)
(enum_decl name: (identifier) @type)
(interface_decl name: (identifier) @type)

; Operators
[
  "+" "-" "*" "/" "%"
  "=" "==" "!=" "<" ">" "<=" ">="
  "&&" "||" "!"
  "->" "~>" "<~" "=>"
  "??" "?."
] @operator
