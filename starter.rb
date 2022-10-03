require "open-uri"
require "json"


line_width = 40

puts "="*line_width
puts "Will you need an umbrella today?".center(line_width)
puts "="*line_width
puts
puts "Where are you?"
# user_location = gets.chomp
user_location = "Trenton"
puts "Checking the weather at #{user_location}...."

# Get the lat/lng of location from Google Maps API

require "./GmapsClient.rb"

location_hash = GmapsClient.address_to_coords(user_location)

p location_hash

latitude = location_hash.fetch("lat")

longitude = location_hash.fetch("lng")

puts "Your coordinates are #{latitude}, #{longitude}."

# Get the weather from Dark Sky API

dark_sky_key = "26f63e92c5006b5c493906e7953da893"

dark_sky_url = "https://api.darksky.net/forecast/#{dark_sky_key}/#{latitude},#{longitude}"

# p "Getting weather from:"
# p dark_sky_url

raw_dark_sky_data = URI.open(dark_sky_url).read

parsed_dark_sky_data = JSON.parse(raw_dark_sky_data)

currently_hash = parsed_dark_sky_data.fetch("currently")

current_temp = currently_hash.fetch("temperature")

puts "It is currently #{current_temp}°F."

# Some locations around the world do not come with minutely data.
minutely_hash = parsed_dark_sky_data.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")

  puts "Next hour: #{next_hour_summary}"
end

hourly_hash = parsed_dark_sky_data.fetch("hourly")

hourly_data_array = hourly_hash.fetch("data")

next_twelve_hours = hourly_data_array[1..12]

precip_prob_threshold = 0.10

any_precipitation = false

next_twelve_hours.each do |hour_hash|

  precip_prob = hour_hash.fetch("precipProbability")

  if precip_prob > precip_prob_threshold
    any_precipitation = true

    precip_time = Time.at(hour_hash.fetch("time"))

    seconds_from_now = precip_time - Time.now

    hours_from_now = seconds_from_now / 60 / 60

    puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
  end
end

if any_precipitation == true
  require "twilio-ruby"

  puts "You might want to take an umbrella!"

  # Send a text message

  twilio_client = Twilio::REST::Client.new("AC28922e0822d827ee29834fe1dc6f681e", "1560b96faf1c13419b9f3db964d8c5c7")

  # Craft your SMS as a Hash literal with three keys
  sms_info = {
  :from => "+13126636198",
  :to => "+16308259952", # Put your own phone number here if you want to see it in action
  :body => "It's going to rain today — take an umbrella!"
}
# Send your SMS
  twilio_client.api.account.messages.create(sms_info)

else
  puts "You probably won't need an umbrella."
end

#gem install twilio-ruby
