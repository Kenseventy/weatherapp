from flask import render_template, request, jsonify
from app import app
import requests
import os

def get_weather_data(city_name):
    if not city_name:
        return None

    # OpenWeather API details
    API_URL = "http://api.openweathermap.org/data/2.5/weather"
    API_KEY = os.environ.get("WEATHER_API_KEY")
    
    # Construct the full URL. Adding units=metric to get temperature in Celsius.
    full_url = f"{API_URL}?q={city_name}&appid={API_KEY}&units=metric"

    try:
        response = requests.get(full_url)
        data = response.json()
        
        # Check for valid response from OpenWeather API
        if data.get("cod") != 200:
            return None
        
        # Process and return the data (customized for OpenWeather's response structure)
        return {
            "city": data["name"],
            "temperature": data["main"]["temp"],
            "description": data["weather"][0]["description"]
        }

    except Exception as e:
        # Handle any exception that arises when making the API call
        print(e)
        return None



@app.route('/')
def index():
    # Check temperature alert from Azure Function for Winnipeg
    # env variable to protect URL
    ALERT_FUNCTION_URL = os.environ.get('ALERT_FUNCTION_URL')
    alert_response = requests.get(ALERT_FUNCTION_URL)
    if 'Alert' in alert_response.text:
        msg = alert_response.text.split(" ",1)
        alert_msg = msg[1]
    else:
        alert_msg = "No sweater alerts at the moment."

    return render_template('index.html', alert=alert_msg)

@app.route('/search', methods=['POST'])
def search():
    city_name = request.form.get('city')
    weather_data = get_weather_data(city_name)

    if weather_data:
        return jsonify(weather_data)
    else:
        return jsonify({"error": "Weather data not found for the given city"}), 404
        
