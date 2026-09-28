---
name: adair-code-audit
description: >
  anglers-log-specific additions to the root adair-code-audit skill (Flutter
  code review / pre-commit checklist). Same triggers as the root skill; always
  follow the root skill first, then apply these anglers-log rules.
---

# adair-code-audit — anglers-log additions

**This file is not a standalone skill.** Read and follow the root skill at
`/Users/cohen/Documents/flutter-projects/.claude/skills/adair-code-audit/SKILL.md`,
and apply the additions below wherever anglers-log is in scope.

## Step 1 — Scope

- The Flutter root is `anglers-log/mobile/`, not `anglers-log/`. Run every
  `flutter`/`dart` command from there.

## Step 10 — ARB locale rules

| Base | Requires full coverage | Skip (spelling variants only) |
|------|------------------------|-------------------------------|
| `mobile/lib/l10n/localizations_en.arb` (Canadian English) | `localizations_es.arb` | `localizations_en_US.arb`, `localizations_en_GB.arb` |

```bash
diff \
  <(jq -r 'keys[] | select(startswith("@") | not)' anglers-log/mobile/lib/l10n/localizations_en.arb | sort) \
  <(jq -r 'keys[] | select(startswith("@") | not)' anglers-log/mobile/lib/l10n/localizations_es.arb | sort)
```
