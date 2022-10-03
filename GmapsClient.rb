require "open-uri"
require "json"

class GmapsClient

  def GmapsClient.address_to_coords(user_input)
    gmaps_key = "AIzaSyAgRzRHJZf-uoevSnYDTf08or8QFS_fb3U"

    gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_input}&key=#{gmaps_key}"

    p "Getting coordinates from:"
    p gmaps_url

    raw_gmaps_data = URI.open(gmaps_url).read

    parsed_gmaps_data = JSON.parse(raw_gmaps_data)

    results_array = parsed_gmaps_data.fetch("results")

    first_result_hash = results_array.at(0)

    geometry_hash = first_result_hash.fetch("geometry")

    location_hash = geometry_hash.fetch("location")

    return location_hash
  end
  
end

=begin
***Trial Code***
 # attr_accessor :user_location

  # gmaps_key = "AIzaSyAgRzRHJZf-uoevSnYDTf08or8QFS_fb3U"
  # gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{self.user_location}&key=#{gmaps_key}"

  # def get_location_hash
  #   raw_gmaps_data = URI.open(gmaps_url).read

  #   parsed_gmaps_data = JSON.parse(raw_gmaps_data)

  #   results_array = parsed_gmaps_data.fetch("results")

  #   first_result_hash = results_array.at(0)

  #   geometry_hash = first_result_hash.fetch("geometry")

  #   location_hash = geometry_hash.fetch("location")

  #   return location_hash

  # end

  # def get_latitude(location_hash)
  #   latitude = get_location_hash(location_hash.fetch("lat"))
  #   return latitude
  # end

  # def get_longitude(location_hash)
  #   longitude = get_location_hash(location_hash.fetch("lng"))
  #   return longitude
  # end

=end
