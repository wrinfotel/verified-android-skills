# Material 3 theming — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Material 3 in Compose** — "An M3 theme contains the following
   subsystems: color scheme, typography and shapes"; "You can access
   Material theme colors in your app via MaterialTheme.colorScheme";
   "You can retrieve the typography provided to the M3 MaterialTheme
   composable by using MaterialTheme.typography"; customization examples
   pull component colors from `MaterialTheme.colorScheme`; accessible role
   pairing: "Use on-primary on top of primary, and on-primary-container on
   top of primary-container".
   https://developer.android.com/develop/ui/compose/designsystems/material3

2. **Dynamic color** — "Dynamic color is available on Android 12 and
   above. If dynamic color is available, you can set up a dynamic
   ColorScheme. If not, you should fall back to using a custom light or
   dark ColorScheme"; dark/light via `isSystemInDarkTheme()`; canonical
   `dynamicDarkColorScheme` / `dynamicLightColorScheme` when block.
   https://developer.android.com/develop/ui/compose/designsystems/material3

3. **M2 → M3 migration** — M3 is "the next evolution of Material Design";
   the migration guide maps M2 `MaterialTheme.colors` → M3
   `MaterialTheme.colorScheme` and lists component-by-component
   replacements; M2 components in an M3 app do not consume the M3 theme.
   https://developer.android.com/develop/ui/compose/designsystems/material2-material3

4. **Design systems overview** — theming, components and consistency are
   the framework's stated goal; the checks below enforce the M3 theme as
   the only source of styling values in UI code (palette/typography
   definitions themselves live in the theme files).
   https://developer.android.com/develop/ui/compose/designsystems

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
