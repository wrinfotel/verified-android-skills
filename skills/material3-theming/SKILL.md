---
name: material3-theming
description: >
  Material 3 theming discipline in Compose: read colors, typography and
  shapes through MaterialTheme (no hardcoded values in UI code), no
  Material 2 components or theme accessors in an M3 app, dynamic color
  with a custom fallback. Use when writing or reviewing Compose UI and
  theme files. Core rules have machine checks in checks/.
version: 0.1.0
---

# Material 3 Theming

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY Compose UI or theme edit, run the Verification step (bottom of
this file). This skill targets Material 3 apps.

## 1. Colors come from MaterialTheme.colorScheme

MUST read colors through `MaterialTheme.colorScheme` color roles: "You can
access Material theme colors in your app via MaterialTheme.colorScheme."
MUST NOT hardcode `Color(0x...)` literals, `colorResource(R.color...)`
lookups, or `R.color...` references in composable files — hardcoded pairs
break dark theme and dynamic color, and the docs call for accessible role
pairing: "Use on-primary on top of primary, and on-primary-container on
top of primary-container."

WRONG:
```kotlin
Text(
    text = name,
    color = Color(0xFF1B6EF3),                       // bypasses the theme
    modifier = Modifier.background(Color(0xFFEEEEEE)),
)
```

RIGHT:
```kotlin
Text(
    text = name,
    color = MaterialTheme.colorScheme.onSurface,
    modifier = Modifier.background(MaterialTheme.colorScheme.surface),
)
```

Palette definitions belong in the theme: `lightColorScheme(...)` /
`darkColorScheme(...)` values live in `Theme.kt` / `Color.kt`, which the
check excludes by filename.

## 2. Typography comes from MaterialTheme.typography

MUST style text with theme styles: "You can retrieve the typography
provided to the M3 MaterialTheme composable by using
MaterialTheme.typography." MUST NOT set `fontSize = ...` in composable
files — text sizes are customized in the `Typography(...)` passed to the
theme, not ad hoc per composable.

WRONG:
```kotlin
Text(text = "Hello", fontSize = 18.sp)
```

RIGHT:
```kotlin
Text(text = "Hello", style = MaterialTheme.typography.titleMedium)
```

## 3. No Material 2 in an M3 app

MUST NOT import `androidx.compose.material.*` (Material 2) components in a
Material 3 app — M2 components read the M2 theme, so the app's M3
colorScheme/typography silently does not apply to them (and two Button
implementations coexist in the app). Material icons
(`androidx.compose.material.icons`) are shared and are not flagged.

WRONG:
```kotlin
import androidx.compose.material.Button        // M2
```

RIGHT:
```kotlin
import androidx.compose.material3.Button
```

Related mixed-API bug: `MaterialTheme.colors` is the M2 accessor — the M3
accessor is `MaterialTheme.colorScheme`. A file importing material3 while
reading `MaterialTheme.colors` compiles (M2 is on the classpath) but reads
the wrong theme.

## 4. Dynamic color with a custom fallback

MUST support dynamic color on Android 12+ with a custom light/dark
fallback: "Dynamic color is available on Android 12 and above. If dynamic
color is available, you can set up a dynamic ColorScheme. If not, you
should fall back to using a custom light or dark ColorScheme." Dark theme
comes from `isSystemInDarkTheme()`.

RIGHT (canonical shape):
```kotlin
val dynamicColor = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
val colorScheme = when {
    dynamicColor && darkTheme -> dynamicDarkColorScheme(LocalContext.current)
    dynamicColor && !darkTheme -> dynamicLightColorScheme(LocalContext.current)
    darkTheme -> DarkColors
    else -> LightColors
}
```

This section is review-verified (no deterministic check): the checks
cannot see whether your Theme composable implements this shape.

## Verification

Run after every Compose UI/theme edit (from the project root):

```bash
bash <skill-dir>/checks/check_no_hardcoded_colors.sh    <compose-src-dir>
bash <skill-dir>/checks/check_no_hardcoded_font_size.sh <compose-src-dir>
bash <skill-dir>/checks/check_no_material2_imports.sh   <compose-src-dir>
bash <skill-dir>/checks/check_m2_theme_accessor.sh      <compose-src-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic heuristics — they catch the documented anti-patterns above,
not every theming bug. §4 is verified by review against
references/material3.md.
