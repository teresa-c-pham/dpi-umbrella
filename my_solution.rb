require "http"
require "json"
require "ascii_charts"

# Global variables
size = 40
gmaps_key = "AIzaSyDKz4Y3bvrTsWpPRNn9ab55OkmcwZxLOHI"
pweather_key = "kgcx5l5n4bxXRWQA3XmXjjSjybwUhK5K"


# Output Initial Message
puts "=" * size
puts "    Will you need an umbrella today?    "
puts "=" * size

# Prompt user for their location and store location
puts "\nWhere are you?"
location = gets.chomp

# Get latitude/longitude from Google Maps API
puts "Checking the weather at #{location}..."

(1..location.length).each do |i|
  if location[i-1] == " "
    location[i-1] = "%"
  end
end

# GMAPS: Fetch data and parse to get lat/long
gmaps = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}"
gmaps_data = HTTP.get(gmaps).to_s
gmaps_parse = JSON.parse(gmaps_data)

location_data = gmaps_parse["results"][0]["geometry"]["location"]
lat = location_data["lat"]
long = location_data["lng"]

# PIRATE_WEATHER: Fetch data and parse to get weather
pweather = "https://api.pirateweather.net/forecast/#{pweather_key}/41.8887,-87.6355"
pweather_data = HTTP.get(pweather).to_s
pweather_parse = JSON.parse(pweather_data)
current_temp = pweather_parse["currently"]["temperature"]


puts "Your coordinates are #{lat}, #{long}."
puts "It is currently #{current_temp}°F."

# Output when it will rain
next_hour = pweather_parse["minutely"]["data"]
rain_found = false
counter = 0                 # how many minutes until rainfall
intensity = 0.00              # rain intensity

# Find first instance of rain
(0..60).each do |minute|
  if next_hour[minute]["precipType"] == "rain"
    rain_found = true
    intensity = next_hour[minute]["precipIntensity"]
  else
    counter += 1
  end
end

# Classify intensity of precipitation
rain_class = ""
if intensity == 0.00
  rain_class = "No rain"
elsif intensity < 0.5
  rain_class = "Light rain"
elsif intensity < 2.0
  rain_class = "Moderate rain"
elsif intensity < 6.0
  rain_class = "Heavy rain"
elsif intensity < 10.0
  rain_class = "Very heavy rain"
elsif intensity < 18.0
  rain_class = "Shower"
else
  rain_class = "Cloudburst"
end

# Output Next Hour message
if rain_class == "No rain"
  puts "Next hour: No rain.\n"
else
  puts "Next hour: #{rain_class} starting in #{counter} min.\n"
end

# Output Hours from now vs Precipitation Probability
puts "Hours from now vs Precipitation probability"

# Store Hours and precipitation prob in a 2d array
hourly = pweather_parse["hourly"]["data"]
hour_arr = Array.new
need_umbrella = false
rain_hour = 0


(1..12).each do |hour|
  prob = hourly[hour]["precipProbability"]*100
  new_prob = prob.to_i
  pair = [hour, new_prob]
  hour_arr.append(pair)

  # Check if precipitation prob is above 10%
  if (new_prob > 10) && (!need_umbrella)
    need_umbrella = true
    rain_hour = hour
  end
end

# NOTE: Data must be a pre-sorted array of x,y pair:
puts AsciiCharts::Cartesian.new(hour_arr, :bar => true, :hide_zero => true).draw
if need_umbrella
  puts "You might want to carry an umbrella!"
else
  puts "\nYou probably won`t need an umbrella today."
end
