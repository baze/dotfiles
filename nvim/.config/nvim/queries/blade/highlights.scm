;; highlights.scm
;; Blade Directives
(directive) @function
(directive_start) @function
(directive_end) @function

; ((parameter) @include (#set! "priority" 110))
; ((php_only) @include (#set! "priority" 110))
; ((bracket_start) @function (#set! "priority" 120))
; ((bracket_end) @function (#set! "priority" 120))

;; PHP Code inside Blade `@php ... @endphp`
(php_statement) @string.special
(php_only) @string.special

;; Blade Echo Tags `{{ }}` and `{!! !!}`
(bracket_start) @punctuation.bracket
(bracket_end) @punctuation.bracket

;; Blade Comments `{{-- comment --}}`
(comment) @comment

;; Blade Control Structures (`@if`, `@foreach`, etc.)
(loop_operator) @keyword.control
(conditional_keyword) @keyword.control

;; Section-related directives (`@section`, `@yield`, `@endsection`)
(section) @keyword
(inlineSection) @keyword

;; Attribute directives (`@class`, `@style`, `@checked`, etc.)
(attribute) @property

;; General Keywords
(keyword) @function
