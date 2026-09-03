; Base TOML
;-----------

(bare_key) @property
(quoted_key) @property
(boolean) @constant
(comment) @comment
(integer) @number
(float) @number
(string) @string
(escape_sequence) @string.escape
(offset_date_time) @string.special
(local_date_time) @string.special
(local_date) @string.special
(local_time) @string.special

[
  "."
  ","
] @punctuation.delimiter

"=" @operator

[
  "["
  "]"
  "[["
  "]]"
  "{"
  "}"
] @punctuation.bracket

; Snovalang manifest sections
;------------------------------

(table
  (bare_key) @keyword)

(table
  (dotted_key
    (bare_key) @keyword))

(table_array_element
  (bare_key) @keyword)

(table_array_element
  (dotted_key
    (bare_key) @keyword))

; Dependency keys and stdlib package stems
;-----------------------------------------

(pair
  (dotted_key
    (bare_key) @type
    (#match? @type "^(stdlib|snovalang|properties)$")))

(pair
  (bare_key) @type
  (#match? @type "^stdlib\\.snovalang"))

(array
  (string) @string.special)

