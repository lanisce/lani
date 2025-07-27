class MapboxService
  include HTTParty
  base_uri 'https://api.mapbox.com'

  def initialize
    @access_token = Rails.application.credentials.mapbox&.access_token || ENV['MAPBOX_ACCESS_TOKEN']
    raise 'Mapbox access token not configured' unless @access_token
  end

  # Geocode an address to get coordinates
  def geocode(address)
    return nil if address.blank?

    response = self.class.get(
      "/geocoding/v5/mapbox.places/#{URI.encode_www_form_component(address)}.json",
      query: {
        access_token: @access_token,
        limit: 1,
        types: 'address,poi'
      }
    )

    if response.success? && response['features']&.any?
      feature = response['features'].first
      {
        longitude: feature['center'][0],
        latitude: feature['center'][1],
        place_name: feature['place_name'],
        address: feature['properties']['address'] || feature['text']
      }
    else
      Rails.logger.error "Mapbox geocoding failed: #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Mapbox geocoding error: #{e.message}"
    nil
  end

  # Reverse geocode coordinates to get address
  def reverse_geocode(longitude, latitude)
    return nil unless longitude && latitude

    response = self.class.get(
      "/geocoding/v5/mapbox.places/#{longitude},#{latitude}.json",
      query: {
        access_token: @access_token,
        limit: 1,
        types: 'address,poi'
      }
    )

    if response.success? && response['features']&.any?
      feature = response['features'].first
      {
        place_name: feature['place_name'],
        address: feature['properties']['address'] || feature['text']
      }
    else
      Rails.logger.error "Mapbox reverse geocoding failed: #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Mapbox reverse geocoding error: #{e.message}"
    nil
  end

  # Get directions between two points
  def directions(start_coords, end_coords, profile: 'driving')
    return nil unless start_coords && end_coords

    start_lon, start_lat = start_coords
    end_lon, end_lat = end_coords

    response = self.class.get(
      "/directions/v5/mapbox/#{profile}/#{start_lon},#{start_lat};#{end_lon},#{end_lat}",
      query: {
        access_token: @access_token,
        geometries: 'geojson',
        overview: 'full'
      }
    )

    if response.success? && response['routes']&.any?
      route = response['routes'].first
      {
        distance: route['distance'], # in meters
        duration: route['duration'], # in seconds
        geometry: route['geometry']
      }
    else
      Rails.logger.error "Mapbox directions failed: #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Mapbox directions error: #{e.message}"
    nil
  end

  # Generate static map URL
  def static_map_url(longitude, latitude, zoom: 14, width: 400, height: 300, marker: true)
    return nil unless longitude && latitude

    marker_param = marker ? "/pin-s+ff0000(#{longitude},#{latitude})" : ''
    
    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static#{marker_param}/#{longitude},#{latitude},#{zoom}/#{width}x#{height}?access_token=#{@access_token}"
  end

  # Check if service is properly configured
  def self.configured?
    Rails.application.credentials.mapbox&.access_token.present? || ENV['MAPBOX_ACCESS_TOKEN'].present?
  end
end
