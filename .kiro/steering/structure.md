# Project Structure

The project is intentionally minimal — two production files at the root.

```
/
├── weather.html          # Single-page app: HTML + embedded CSS + embedded JS
├── weather.test.html     # Property-based tests (fast-check via CDN, open in browser)
├── server.ps1            # PowerShell HTTP server (serves weather.html on :8080)
└── .kiro/
    ├── specs/
    │   └── weather-app/  # Spec documents (requirements, design, tasks)
    ├── steering/         # AI steering rules (this file and siblings)
    └── hooks/            # Kiro automation hooks
```

## Conventions

- All production logic lives in `weather.html` — no separate `.js` files
- JS functions in `weather.html` are module-level (not classes); named with camelCase
- DOM element IDs use kebab-case: `#city-input`, `#search-btn`, `#error-banner`, `#loading`, `#forecast-table`, `#forecast-tbody`
- Error display always goes through `showError(message)` / `hideError()`
- Loading state always goes through `setLoading(isLoading)` — called in a `finally` block
- Test functions mirror the production functions they test; tagged with comments referencing the property number (e.g., `// Property 3: ...`)
