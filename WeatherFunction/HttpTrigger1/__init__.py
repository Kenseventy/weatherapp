import os
import requests
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    API_URL = "http://api.openweathermap.org/data/2.5/weather"
    API_KEY = os.environ.get("WEATHER_API_KEY")
    WINNIPEG_ID = "6183235"  # City ID for Winnipeg

    response = requests.get(f"{API_URL}?id={WINNIPEG_ID}&appid={API_KEY}&units=metric")
    data = response.json()
    temperature = data["main"]["temp"]

    if temperature < 20:
        return func.HttpResponse(f"Alert! Temperature in Winnipeg is {temperature} degrees Celsius. 🧣", status_code=200)
    else:
        return func.HttpResponse(f"Temperature in Winnipeg is {temperature} degrees Celsius.", status_code=200)
