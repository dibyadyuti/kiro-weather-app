# Implementation Plan: weather-app

## Overview

Build a single-page weather forecast app (`weather.html`) served by a zero-dependency PowerShell HTTP server (`server.ps1`). The app uses Nominatim for geocoding (CORS-safe) and the NWS API for forecast data, displaying a 5-day daytime forecast table with weather icons. All code lives in two files at the project root.

## Tasks

- [x] 1. Create `server.ps1` — PowerShell HttpListener file server
  - Implement `System.Net.HttpListener` listening on `http://localhost:8080/`
  - On each `GET /` request, read `weather.html` from the same directory and respond with its content and `Content-Type: text/html; charset=utf-8`
  - Print `"Weather app running at http://localhost:8080 — press Ctrl+C to stop."` on startup
  - Wrap the listener loop in a `try/finally` block that calls `$listener.Stop()` and `$listener.Close()` on exit so Ctrl+C stops gracefully
  - Also create `start.bat` as a fallback launcher that runs `powershell -ExecutionPolicy Bypass -File server.ps1`
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 2. Build `weather.html` — full app in a single file
  - Create `weather.html` with `<!DOCTYPE html>`, `<head>` (charset, viewport, title), and `<body>`
  - Embed a `<style>` block with basic layout: card container, input row, error banner (hidden by default via `.hidden` class), loading indicator (hidden by default), and forecast table styles
  - Add DOM elements: `#city-input` text field, `#search-btn` button, `#error-banner` div, `#loading` div, `#forecast-table` with `#forecast-tbody`
  - Wire `keydown` on `#city-input` so Enter triggers the same handler as `#search-btn`
  - Implement `geocode(city)`: call Nominatim (`https://nominatim.openstreetmap.org/search?q={city}&format=json&limit=1`), extract `lat` and `lon` from the first result; throw a descriptive error if no results returned
  - Implement `getNWSPoints(lat, lon)`: call `https://api.weather.gov/points/{lat},{lon}` with a `User-Agent` header, extract and return `properties.forecast` URL; throw on non-2xx
  - Implement `getForecast(forecastUrl)`: fetch the forecast URL with `User-Agent` header, return `properties.periods`; throw on non-2xx
  - Implement `filterDaytimePeriods(periods)`: filter `isDaytime === true`, slice first 5
  - Implement `getWeatherIcon(shortForecast)`: case-insensitive keyword matching — snow/blizzard/flurr → ❄️, rain/shower/drizzle/storm → 🌧️, partly cloudy/mostly cloudy/partly sunny → ⛅, cloudy/overcast/fog/haz → ☁️, sunny/clear → ☀️, default → 🌡️
  - Implement `renderTable(periods)`: clear `#forecast-tbody`, call `filterDaytimePeriods`, build one `<tr>` per period with columns: name, icon, temperature (°F), shortForecast, windSpeed + windDirection
  - Implement `setLoading(isLoading)`: disable/enable `#city-input` and `#search-btn`, show/hide `#loading`
  - Implement `showError(message)` / `hideError()`: set text and toggle `.hidden` on `#error-banner`
  - Implement `handleSearch()`: validate non-empty city input, call `geocode → getNWSPoints → getForecast → renderTable`, use `try/catch/finally` to always call `setLoading(false)`; hide error on start, show error on catch
  - City name from `#city-input` is passed directly to Nominatim — never hardcoded or stored
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4_

- [x] 3. Verify the app works end-to-end
  - Start the server: run `.\server.ps1` (or `start.bat` if execution policy blocks it)
  - Open `http://localhost:8080` in a browser
  - Test at least one real city lookup (e.g., "Austin, TX") and confirm the 5-day table populates
  - Test empty input — confirm error banner appears
  - Test an invalid city — confirm error banner appears with a helpful message

- [ ] 4. Write basic tests in `weather.test.html`
  - Create `weather.test.html` that loads fast-check from CDN and inlines the testable functions (`getWeatherIcon`, `filterDaytimePeriods`)
  - Test `getWeatherIcon` returns correct icons for a representative sample of keywords and the default fallback for an unrecognized string
  - Test `filterDaytimePeriods` returns exactly 5 items when given an array with mixed day/night periods
  - Keep tests minimal — open `weather.test.html` directly in the browser to run
  - _Requirements: 3.3_

## Notes

- Use Nominatim for geocoding (not Census Geocoder) — it is CORS-safe from the browser
- NWS API requires a `User-Agent` header on every request or it returns 403
- Nominatim response fields `lat` and `lon` are strings — parse to float before passing to NWS
- All production logic stays in `weather.html`; no separate `.js` files
- `setLoading(false)` must always be called in a `finally` block
