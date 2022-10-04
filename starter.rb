require "open-uri"
require "json"
require "mailgun-ruby"
require "twilio-ruby"


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

dark_sky_key = ENV.fetch("DARK_SKY_API_KEY")

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


  puts "You might want to take an umbrella!"


  # Send a text message
  twilio_sid = ENV.fetch("TWILIO_ACCOUNT_SID")

  twilio_token = ENV.fetch("TWILIO_AUTH_TOKEN")
  
  twilio_sending_phone_number = ENV.fetch("TWILIO_SENDING_PHONE_NUMBER")
  personal_phone = ENV.fetch("PERSONAL_PHONE")

  twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

  # Craft your SMS as a Hash literal with three keys
  sms_info = {
  :from => twilio_sending_phone_number,
  :to => personal_phone, # Put your own phone number here if you want to see it in action
  :body => "It's going to rain today — take an umbrella!"
}
# Send your SMS
  twilio_client.api.account.messages.create(sms_info)



  # Send an email
  
  mg_key = ENV.fetch("MAILGUN_API_KEY")
  mg_sending_domain = ENV.fetch("MAILGUN_SENDING_DOMAIN")
  personal_email = ENV.fetch("PERSONAL_EMAIL")
  mg_client = Mailgun::Client.new(mg_key)

  email_info = {
    :from => "umbrella@appdevproject.com",
    :to => personal_email,  # Put your own email address here if you want to see it in action
    :subject => "Take an umbrella today!",
    :text => "It's going to rain today, take an umbrella with you!"
  }

  mg_client.send_message(mg_sending_domain, email_info)


else
  puts "You probably won't need an umbrella."
end

