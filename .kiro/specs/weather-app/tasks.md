# Implementation Plan: weather-app

## Overview

Build a single-page weather forecast app (`weather.html`) served by a zero-dependency PowerShell HTTP server (`server.ps1`). The app calls the US Census Geocoder and the NWS API to display a 5-day daytime forecast table with weather icons. Tasks are ordered so the app is end-to-end functional by task 4, at which point the prototype is launched in the browser for user testing before polish and property-based tests are added.

## Tasks

- [ ] 1. Create `server.ps1` — PowerShell HttpListener file server
  - Implement `System.Net.HttpListener` listening on `http://localhost:8080/`
  - On each `GET /` request, read `weather.html` from the same directory and respond with its content and `Content-Type: text/html; charset=utf-8`
  - Print `"Weather app running at http://localhost:8080 — press Ctrl+C to stop."` on startup
  - Wrap the listener loop in a `try/finally` block that calls `$listener.Stop()` and `$listener.Close()` on exit so Ctrl+C stops gracefully
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 2. Build `weather.html` skeleton and city input UI
  - Create `weather.html` with `<!DOCTYPE html>`, `<head>` (charset, viewport, title), and `<body>`
  - Embed a `<style>` block with basic layout, a card container, input row, error banner (hidden by default via `.hidden` class), loading indicator (hidden by default), and forecast table styles
  - Add DOM elements: `#city-input` text field, `#search-btn` button, `#error-banner` div, `#loading` div, `#forecast-table` with `#forecast-tbody`
  - Wire a `keydown` listener on `#city-input` so pressing Enter triggers the same handler as `#search-btn`
  - Leave `handleSearch()` as a stub (`async function handleSearch() {}`) — it will be implemented in task 3
  - _Requirements: 1.1, 1.2, 3.4_

- [ ] 3. Implement data retrieval pipeline
  - Implement `geocode(city)`: call the Census Geocoder `onelineaddress` endpoint with `benchmark=Public_AR_Current&format=json`, extract `addressMatches[0].coordinates` (`y` → lat, `x` → lon), throw a descriptive error if `addressMatches` is empty or the request fails
  - Implement `getNWSPoints(lat, lon)`: call `https://api.weather.gov/points/{lat},{lon}` with the required `User-Agent` header, extract and return `properties.forecast` URL, throw on non-2xx
  - Implement `getForecast(forecastUrl)`: fetch the forecast URL with `User-Agent` header, return `properties.periods`, throw on non-2xx
  - Implement `handleSearch()` orchestration: validate non-empty city, call `geocode → getNWSPoints → getForecast`, pass result to `renderTable()` (stub for now), use `try/finally` to always call `setLoading(false)`
  - _Requirements: 1.3, 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 4. Implement forecast table rendering and weather icons
  - Implement `filterDaytimePeriods(periods)`: filter `isDaytime === true`, slice first 5
  - Implement `getWeatherIcon(shortForecast)`: case-insensitive keyword matching in priority order — snow/blizzard/flurr → ❄️, rain/shower/drizzle/storm → 🌧️, partly cloudy/mostly cloudy/partly sunny → ⛅, cloudy/overcast/fog/haz → ☁️, sunny/clear → ☀️, default → 🌡️
  - Implement `renderTable(periods)`: clear `#forecast-tbody`, call `filterDaytimePeriods`, build one `<tr>` per period with columns: name, icon, temperature (°F), shortForecast, windSpeed + windDirection; append to `#forecast-tbody`
  - Implement `setLoading(isLoading)`, `showError(message)`, and `hideError()` so the full flow is functional end-to-end
  - Update `handleSearch()` to call `hideError()` at the start, pass filtered periods to `renderTable()`, and call `setLoading(true/false)` correctly
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 1.4, 4.1, 4.2, 4.3_

  - [ ] 4.1 Launch prototype in browser for user testing
    - Start the server: run `.\server.ps1` in a terminal
    - Open `http://localhost:8080` in a browser
    - Verify the city input, search button, and forecast table render correctly
    - Test at least one real city lookup (e.g., "Austin, TX") and confirm the 5-day table populates
    - Report any issues before proceeding to tasks 5 and 6

- [ ] 5. Wire up loading and error feedback
  - Ensure `setLoading(true)` disables `#city-input` and `#search-btn` and shows `#loading` synchronously within the same event loop tick that `handleSearch()` is called
  - Ensure `setLoading(false)` re-enables controls and hides `#loading` — always called in `finally`
  - Verify `showError(message)` sets `#error-banner` text content and removes the `.hidden` class; `hideError()` adds it back
  - Add error messages matching the design for each error path: empty input, city not found, geocoder failure, NWS `/points` failure, NWS `/forecast` failure, NWS outside US coverage (404)
  - _Requirements: 1.3, 1.4, 2.4, 2.5, 3.5, 4.1, 4.2, 4.3, 4.4_

- [ ] 6. Write property-based tests in `weather.test.html`
  - Create `weather.test.html` that loads fast-check from CDN (`https://cdn.jsdelivr.net/npm/fast-check/lib/bundle/fast-check.js`) and imports or inlines the testable functions from `weather.html`
  - Run `numRuns: 100` for all property tests

  - [ ]* 6.1 Write property test for Property 1: empty/whitespace input rejected
    - Arbitrary: `fc.string()` filtered to whitespace-only strings; assert no fetch call is made and `#error-banner` is visible
    - **Property 1: Empty and whitespace city input is rejected**
    - **Validates: Requirements 1.3**

  - [ ]* 6.2 Write property test for Property 2: valid city passed verbatim to geocoder
    - Arbitrary: `fc.string({ minLength: 1 })` filtered non-whitespace; mock fetch, assert constructed URL contains city as `address` param (URL-encoded)
    - **Property 2: Valid city input is passed verbatim to the geocoder**
    - **Validates: Requirements 1.2, 2.1**

  - [ ]* 6.3 Write property test for Property 3: geocoder first result always used
    - Arbitrary: `fc.array(fc.record({ coordinates: fc.record({ x: fc.float(), y: fc.float() }) }), { minLength: 1 })`; assert `geocode()` returns `y` as lat and `x` as lon from index 0
    - **Property 3: Geocoder first result is always used for coordinates**
    - **Validates: Requirements 2.2**

  - [ ]* 6.4 Write property test for Property 4: NWS forecast URL extracted from points response
    - Arbitrary: `fc.record({ properties: fc.record({ forecast: fc.webUrl() }) })`; assert `getNWSPoints()` returns the exact `properties.forecast` value
    - **Property 4: NWS forecast URL is extracted from the points response**
    - **Validates: Requirements 2.3**

  - [ ]* 6.5 Write property test for Property 5: any error produces visible non-empty banner
    - Arbitrary: error scenarios (zero matches, HTTP 4xx/5xx); assert `#error-banner` is visible with non-empty text
    - **Property 5: Any error condition produces a visible, non-empty error message**
    - **Validates: Requirements 2.4, 2.5, 4.2**

  - [ ]* 6.6 Write property test for Property 6: forecast table always shows exactly 5 daytime rows
    - Arbitrary: `fc.array(daytimePeriod, { minLength: 5 })`; call `renderTable()`, assert `#forecast-tbody` has exactly 5 `<tr>` elements
    - **Property 6: Forecast table always shows exactly 5 daytime rows**
    - **Validates: Requirements 3.1**

  - [ ]* 6.7 Write property test for Property 7: every rendered row contains all required fields
    - Arbitrary: `fc.record(periodArbitrary)` with non-empty string fields; render; assert all 5 columns (name, icon, temp, shortForecast, wind) are non-empty
    - **Property 7: Every rendered forecast row contains all required fields**
    - **Validates: Requirements 3.2**

  - [ ]* 6.8 Write property test for Property 8: recognized keywords return non-default icon
    - Arbitrary: `fc.constantFrom(...recognizedKeywords)` embedded in `fc.string()` prefix/suffix; assert `getWeatherIcon()` result !== 🌡️ and matches expected category
    - **Property 8: Icon mapper returns a non-default icon for all recognized weather keywords**
    - **Validates: Requirements 3.3**

  - [ ] 6.9 Final checkpoint — ensure all property tests pass
    - Open `weather.test.html` in the browser (via `http://localhost:8080/test` or directly as a file)
    - All 8 property tests must pass with 100 iterations each; ask the user if any failures arise

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Task 4.1 is the prototype browser launch checkpoint — complete tasks 1–4 fully before this step
- Each task references specific requirements for traceability
- Property tests use fast-check loaded from CDN — no npm or build tools needed
- All code lives in two files: `weather.html` and `server.ps1`
