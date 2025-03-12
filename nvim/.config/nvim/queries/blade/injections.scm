;; injections.scm
;; Inject PHP inside Blade `@php ... @endphp` blocks
((php_statement) @injection.content
 (#set! injection.language "php"))

;; Inject PHP inside Blade Echo Tags `{{ }}` and `{!! !!}`
((php_only) @injection.content
 (#set! injection.language "php"))

;; Inject HTML inside Blade files
((text) @injection.content
 (#set! injection.language "html"))

;; Inject JavaScript inside `<script>` blocks
((text) @injection.content
 (#set! injection.language "javascript")
 (#has-ancestor? @injection.content "script"))
