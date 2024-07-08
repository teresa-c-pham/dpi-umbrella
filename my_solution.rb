require "http"
require "json"

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
long = location_data["long"]

# PIRATE_WEATHER: Fetch data and parse to get weather
pweather = "https://api.pirateweather.net/forecast/#{pweather_key}/41.8887,-87.6355"
pweather_data = HTTP.get(pweather).to_s
pweather_parse = JSON.parse(pweather_data)

puts pweather_parse.keys
