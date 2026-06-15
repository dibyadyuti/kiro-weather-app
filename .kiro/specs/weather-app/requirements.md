# Requirements Document

## Introduction

A simple browser-based weather application that allows users to look up current weather conditions for any city in the United States. The app is built with HTML and JavaScript, uses the National Weather Service (NWS) public API (api.weather.gov) as its data source, and is served locally via a PowerShell HTTP server on localhost:8080.

## Glossary

- **App**: The weather application — the single HTML page served at localhost:8080.
- **User**: The person interacting with the App in a web browser.
- **City_Input**: The text field where the User types a US city name.
- **Search_Button**: The button the User activates to initiate a weather lookup.
- **NWS_API**: The National Weather Service public REST API at `https://api.weather.gov`, used as the authoritative data source.
- **Geocoder**: The US Census Bureau Geocoding API (`https://geocoding.geo.census.gov`) used to convert a city name to geographic coordinates.
- **Weather_Display**: The section of the page that renders current weather conditions.
- **HTTP_Server**: The PowerShell script that serves the App on localhost:8080.
- **Error_Banner**: The visible UI element that displays error messages to the User.

---

## Requirements

### Requirement 1: City Name Input

**User Story:** As a User, I want to type a US city name into a text field and submit it, so that I can retrieve weather conditions for that city.

#### Acceptance Criteria

1. THE App SHALL render a City_Input text field on page load.
2. THE App SHALL render a Search_Button on page load.
3. WHEN the User activates the Search_Button, THE App SHALL read the current value of the City_Input and initiate a weather lookup.
4. WHEN the User presses the Enter key while the City_Input is focused, THE App SHALL initiate a weather lookup equivalent to activating the Search_Button.
5. WHILE a weather lookup is in progress, THE App SHALL disable the Search_Button and City_Input to prevent duplicate submissions.

---

### Requirement 2: City Geocoding

**User Story:** As a User, I want the app to resolve my city name to geographic coordinates, so that the correct NWS grid point can be determined.

#### Acceptance Criteria

1. WHEN a weather lookup is initiated, THE Geocoder SHALL be queried with the city name and "United States" as the country scope.
2. WHEN the Geocoder returns one or more results, THE App SHALL use the latitude and longitude of the first result to proceed with the NWS lookup.
3. IF the Geocoder returns zero results for the submitted city name, THEN THE App SHALL display an Error_Banner stating that the city was not found.
4. IF the Geocoder request fails with a network error, THEN THE App SHALL display an Error_Banner stating that the location service is unavailable.

---

### Requirement 3: NWS Grid Point Resolution

**User Story:** As a User, I want the app to map geographic coordinates to the correct NWS forecast office and grid, so that accurate forecast data is retrieved.

#### Acceptance Criteria

1. WHEN valid coordinates are obtained from the Geocoder, THE NWS_API SHALL be queried at the `/points/{latitude},{longitude}` endpoint.
2. WHEN the NWS_API returns a valid points response, THE App SHALL extract the `forecastHourly` URL from the response for use in fetching current conditions.
3. IF the NWS_API returns a non-2xx response for the points request, THEN THE App SHALL display an Error_Banner stating that weather data is unavailable for the given location.
4. IF the NWS_API points request fails with a network error, THEN THE App SHALL display an Error_Banner stating that the weather service is unavailable.

---

### Requirement 4: Current Weather Retrieval

**User Story:** As a User, I want the app to fetch the current weather conditions from the NWS, so that I see up-to-date information.

#### Acceptance Criteria

1. WHEN the `forecastHourly` URL is available, THE NWS_API SHALL be queried to retrieve the hourly forecast periods.
2. WHEN the hourly forecast response is received, THE App SHALL treat the first forecast period as the current conditions.
3. IF the NWS_API hourly forecast request returns a non-2xx response, THEN THE App SHALL display an Error_Banner stating that current conditions could not be retrieved.
4. IF the NWS_API hourly forecast request fails with a network error, THEN THE App SHALL display an Error_Banner stating that the weather service is unavailable.

---

### Requirement 5: Weather Display

**User Story:** As a User, I want to see the current weather conditions clearly presented, so that I can quickly understand the weather in the city I searched.

#### Acceptance Criteria

1. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the city name as submitted by the User.
2. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the temperature in degrees Fahrenheit.
3. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the short forecast description (e.g., "Partly Cloudy").
4. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the relative humidity as a percentage.
5. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the wind speed and direction.
6. WHEN current conditions are successfully retrieved, THE Weather_Display SHALL show the weather condition icon provided by the NWS_API.
7. WHEN a new weather lookup is initiated, THE Weather_Display SHALL clear any previously displayed weather data before showing new results.

---

### Requirement 6: Loading State

**User Story:** As a User, I want visual feedback while the app is fetching data, so that I know a request is in progress.

#### Acceptance Criteria

1. WHEN a weather lookup is initiated, THE App SHALL display a visible loading indicator within 100ms of the lookup starting.
2. WHEN the weather lookup completes (successfully or with an error), THE App SHALL remove the loading indicator.
3. WHEN a weather lookup completes, THE App SHALL re-enable the Search_Button and City_Input.

---

### Requirement 7: Error Handling and Display

**User Story:** As a User, I want clear error messages when something goes wrong, so that I understand what happened and can take corrective action.

#### Acceptance Criteria

1. WHEN an error condition occurs, THE App SHALL display the Error_Banner with a human-readable message describing the problem.
2. WHEN a new weather lookup is initiated, THE App SHALL hide any previously displayed Error_Banner.
3. THE Error_Banner SHALL remain visible until the User initiates a new search or dismisses it.
4. IF the City_Input is empty when the User activates the Search_Button, THEN THE App SHALL display an Error_Banner asking the User to enter a city name.

---

### Requirement 8: HTTP Server

**User Story:** As a developer, I want a PowerShell script that starts an HTTP server, so that I can serve the App locally on localhost:8080 without installing additional software.

#### Acceptance Criteria

1. THE HTTP_Server SHALL serve the App's HTML file at `http://localhost:8080`.
2. WHEN a browser requests `http://localhost:8080`, THE HTTP_Server SHALL respond with the correct HTML content and a `200 OK` status code.
3. THE HTTP_Server SHALL use only built-in PowerShell and .NET capabilities, with no third-party dependencies.
4. WHEN the HTTP_Server is started, THE HTTP_Server SHALL print the listening URL to the console so the User knows how to access the App.
5. WHEN the User presses Ctrl+C, THE HTTP_Server SHALL stop gracefully.
