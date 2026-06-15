# Requirements Document

## Introduction

A simple browser-based weather application that allows users to look up the 5-day weather forecast for any city in the United States. The app is built with HTML and JavaScript, uses the National Weather Service (NWS) public API (api.weather.gov) as its data source, and is served locally via a PowerShell HTTP server on localhost:8080. Forecast results are presented in a table with weather condition icons for quick visual scanning.

## Glossary

- **App**: The weather application — the single HTML page served at localhost:8080.
- **User**: The person interacting with the App in a web browser.
- **City_Input**: The text field where the User types a US city name.
- **Search_Button**: The button the User activates to initiate a weather lookup.
- **NWS_API**: The National Weather Service public REST API at `https://api.weather.gov`, used as the authoritative data source.
- **Geocoder**: The US Census Bureau Geocoding API (`https://geocoding.geo.census.gov`) used to convert a city name to geographic coordinates.
- **Forecast_Table**: The tabular UI element that displays the 5-day forecast rows with icons, temperature, and other conditions.
- **Weather_Icon**: An SVG or emoji graphic that visually represents a weather condition (e.g., sunny, cloudy, rainy, snowy).
- **HTTP_Server**: The PowerShell script that serves the App on localhost:8080.
- **Error_Banner**: The visible UI element that displays error messages to the User.

---

## Requirements

### Requirement 1: City Name Input

**User Story:** As a User, I want to type a US city name into a text field and submit it, so that I can retrieve the weather forecast for that city.

#### Acceptance Criteria

1. THE App SHALL render a City_Input text field and a Search_Button on page load.
2. WHEN the User activates the Search_Button or presses Enter while the City_Input is focused, THE App SHALL initiate a weather lookup using the current City_Input value.
3. IF the City_Input is empty when the User activates the Search_Button, THEN THE App SHALL display an Error_Banner asking the User to enter a city name.
4. WHILE a weather lookup is in progress, THE App SHALL disable the Search_Button and City_Input to prevent duplicate submissions.

---

### Requirement 2: Weather Data Retrieval

**User Story:** As a User, I want the app to automatically resolve my city to coordinates, find the correct NWS grid point, and fetch the forecast, so that I see accurate weather data without manual steps.

#### Acceptance Criteria

1. WHEN a weather lookup is initiated, THE Geocoder SHALL be queried with the city name and "United States" as the country scope.
2. WHEN the Geocoder returns one or more results, THE App SHALL use the latitude and longitude of the first result to query the NWS_API at the `/points/{latitude},{longitude}` endpoint.
3. WHEN the NWS_API returns a valid points response, THE App SHALL use the `forecast` URL from the response to fetch the multi-day forecast periods.
4. IF the Geocoder returns zero results for the submitted city name, THEN THE App SHALL display an Error_Banner stating that the city was not found.
5. IF any NWS_API or Geocoder request fails with a network error or non-2xx response, THEN THE App SHALL display an Error_Banner describing which service is unavailable.

---

### Requirement 3: 5-Day Forecast Display

**User Story:** As a User, I want to see the 5-day forecast presented in a table with weather icons, so that I can quickly compare conditions across the coming days.

#### Acceptance Criteria

1. WHEN forecast data is successfully retrieved, THE Forecast_Table SHALL display one row per day for the next 5 days.
2. WHEN forecast data is successfully retrieved, THE Forecast_Table SHALL display for each day: date, a Weather_Icon representing the forecast condition, temperature in degrees Fahrenheit, short forecast description, wind speed, and wind direction.
3. THE App SHALL render a Weather_Icon for at least the following conditions: sunny/clear, partly cloudy, cloudy, rainy, and snowy.
4. WHEN a new weather lookup is initiated, THE Forecast_Table SHALL clear any previously displayed forecast data before showing new results.
5. WHEN a weather lookup completes (successfully or with an error), THE App SHALL re-enable the Search_Button and City_Input and remove any loading indicator.

---

### Requirement 4: Loading and Error Feedback

**User Story:** As a User, I want visual feedback while data is loading and clear error messages when something goes wrong, so that I always know the current state of the app.

#### Acceptance Criteria

1. WHEN a weather lookup is initiated, THE App SHALL display a visible loading indicator within 100ms.
2. WHEN an error condition occurs, THE App SHALL display the Error_Banner with a human-readable message describing the problem.
3. WHEN a new weather lookup is initiated, THE App SHALL hide any previously displayed Error_Banner.
4. THE Error_Banner SHALL remain visible until the User initiates a new search or dismisses it.

---

### Requirement 5: HTTP Server

**User Story:** As a developer, I want a PowerShell script that starts an HTTP server, so that I can serve the App locally on localhost:8080 without installing additional software.

#### Acceptance Criteria

1. THE HTTP_Server SHALL serve the App's HTML file at `http://localhost:8080`.
2. WHEN a browser requests `http://localhost:8080`, THE HTTP_Server SHALL respond with the correct HTML content and a `200 OK` status code.
3. THE HTTP_Server SHALL use only built-in PowerShell and .NET capabilities, with no third-party dependencies.
4. WHEN the HTTP_Server is started, THE HTTP_Server SHALL print the listening URL to the console so the User knows how to access the App.
5. WHEN the User presses Ctrl+C, THE HTTP_Server SHALL stop gracefully.
