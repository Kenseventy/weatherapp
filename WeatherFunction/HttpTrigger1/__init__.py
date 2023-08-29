import os
import requests
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    API_URL = "http://api.openweathermap.org/data/2.5/weather"
    # env variable to protect API Key
    API_KEY = os.environ.get("WEATHER_API_KEY")
    WINNIPEG_ID = "6183235"  # City ID for Winnipeg

    # Send a GET request to the API with a specific city ID (Winnipeg) to fetch weather data
    response = requests.get(f"{API_URL}?id={WINNIPEG_ID}&appid={API_KEY}&units=metric")
    # Parse the response from the API into a JSON format
    data = response.json()
    # Extract the temperature value from the parsed data
    temperature = data["main"]["temp"]

    # Check if the temperature is below 20 degrees Celsius
    if temperature < 20:
        # Return an alert message indicating the temperature is below 20 degrees
        return func.HttpResponse(f"Alert! Temperature in Winnipeg is {temperature} degrees Celsius. 🧣", status_code=200)
    else:
         # Otherwise, just return the current temperature
        return func.HttpResponse(f"Temperature in Winnipeg is {temperature} degrees Celsius.", status_code=200)
