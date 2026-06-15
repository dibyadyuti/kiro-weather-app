# Tech Stack

## Languages & Runtime
- **HTML + vanilla JavaScript** — single `weather.html` file with embedded CSS and JS (no frameworks, no bundler)
- **PowerShell** — `server.ps1` uses `System.Net.HttpListener` (.NET built-in) to serve the app locally

## External APIs
- **US Census Bureau Geocoding API** (`https://geocoding.geo.census.gov`) — city name → lat/lon via `onelineaddress` endpoint
- **National Weather Service API** (`https://api.weather.gov`) — NWS requires a `User-Agent` header on every request or returns 403

## Testing
- **fast-check** (loaded from CDN, no install) — property-based testing in `weather.test.html`
- Tests run in-browser by opening `weather.test.html`; no test runner CLI

## Key Constraints
- No npm, no build tools, no third-party dependencies installed locally
- All client dependencies (fast-check) loaded from CDN in the test file only
- PowerShell server uses only built-in .NET — no additional modules

## Common Commands

### Start the local server
```powershell
.\server.ps1
```
Then open `http://localhost:8080` in a browser. Press `Ctrl+C` to stop.

### Run property-based tests
Open `weather.test.html` in a browser (either directly as a file or via the server).
