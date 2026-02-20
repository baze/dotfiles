# Global Agent Rules

## General

- Keep changes small and explicit; avoid broad refactors unless asked.
- Keep files ASCII unless the file already uses Unicode.

## Security

- Never commit secrets (`.env*` with real credentials, key files, credential files).
- Never use string interpolation in SQL — always use parameterized queries.
- Never expose internal error details (`stack`, SQL, passwords) in API responses.
- Never log sensitive values (passwords, tokens, PII) even at debug level.

## TypeScript / ESM

- Use `.js` extensions in relative imports when targeting NodeNext output.
- Prefer `import type { ... }` for type-only imports.
