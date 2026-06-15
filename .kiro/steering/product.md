# Product

A minimal, browser-based weather forecast app for US cities. Users type a city name and get a 5-day daytime forecast displayed in a table with weather condition icons.

## Key Details

- Single-page app served locally at `http://localhost:8080`
- No user accounts, no persistence, no backend logic — pure client-side data fetching
- US cities only (data source is NWS, which only covers the US)
- Data pipeline: city name → Census Geocoder (lat/lon) → NWS `/points` (grid) → NWS `/forecast` (periods)
