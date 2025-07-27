import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mapbox"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "locationName", "search"]
  static values = { 
    apiKey: String,
    latitude: Number,
    longitude: Number,
    zoom: { type: Number, default: 14 },
    interactive: { type: Boolean, default: true }
  }

  connect() {
    if (!this.apiKeyValue) {
      console.error("Mapbox API key not provided")
      return
    }

    this.initializeMap()
  }

  initializeMap() {
    // Load Mapbox GL JS dynamically
    if (!window.mapboxgl) {
      const script = document.createElement('script')
      script.src = 'https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.js'
      script.onload = () => this.createMap()
      document.head.appendChild(script)

      const link = document.createElement('link')
      link.href = 'https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.css'
      link.rel = 'stylesheet'
      document.head.appendChild(link)
    } else {
      this.createMap()
    }
  }

  createMap() {
    mapboxgl.accessToken = this.apiKeyValue

    // Default to a central location if no coordinates provided
    const defaultLat = this.latitudeValue || 40.7128
    const defaultLng = this.longitudeValue || -74.0060

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [defaultLng, defaultLat],
      zoom: this.zoomValue,
      interactive: this.interactiveValue
    })

    // Add navigation controls
    if (this.interactiveValue) {
      this.map.addControl(new mapboxgl.NavigationControl())
    }

    // Add marker if coordinates exist
    if (this.latitudeValue && this.longitudeValue) {
      this.addMarker(this.longitudeValue, this.latitudeValue)
    }

    // Add click handler for interactive maps
    if (this.interactiveValue) {
      this.map.on('click', (e) => {
        this.updateLocation(e.lngLat.lng, e.lngLat.lat)
      })
    }

    this.map.on('load', () => {
      this.mapTarget.classList.remove('opacity-50')
    })
  }

  addMarker(lng, lat) {
    if (this.marker) {
      this.marker.remove()
    }

    this.marker = new mapboxgl.Marker({ color: '#ef4444' })
      .setLngLat([lng, lat])
      .addTo(this.map)
  }

  updateLocation(lng, lat) {
    // Update form fields
    if (this.hasLatitudeTarget) {
      this.latitudeTarget.value = lat.toFixed(6)
    }
    if (this.hasLongitudeTarget) {
      this.longitudeTarget.value = lng.toFixed(6)
    }

    // Add/update marker
    this.addMarker(lng, lat)

    // Reverse geocode to get location name
    this.reverseGeocode(lng, lat)
  }

  async reverseGeocode(lng, lat) {
    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${lng},${lat}.json?access_token=${this.apiKeyValue}&limit=1`
      )
      const data = await response.json()
      
      if (data.features && data.features.length > 0) {
        const placeName = data.features[0].place_name
        if (this.hasLocationNameTarget) {
          this.locationNameTarget.value = placeName
        }
      }
    } catch (error) {
      console.error('Reverse geocoding failed:', error)
    }
  }

  async searchLocation() {
    const query = this.searchTarget.value.trim()
    if (!query) return

    try {
      const response = await fetch(
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${this.apiKeyValue}&limit=1`
      )
      const data = await response.json()
      
      if (data.features && data.features.length > 0) {
        const feature = data.features[0]
        const [lng, lat] = feature.center
        
        // Update map and form
        this.map.flyTo({ center: [lng, lat], zoom: this.zoomValue })
        this.updateLocation(lng, lat)
        
        // Update location name with the found place
        if (this.hasLocationNameTarget) {
          this.locationNameTarget.value = feature.place_name
        }
      } else {
        alert('Location not found. Please try a different search term.')
      }
    } catch (error) {
      console.error('Geocoding failed:', error)
      alert('Search failed. Please try again.')
    }
  }

  // Action methods
  search() {
    this.searchLocation()
  }

  clearLocation() {
    if (this.hasLatitudeTarget) this.latitudeTarget.value = ''
    if (this.hasLongitudeTarget) this.longitudeTarget.value = ''
    if (this.hasLocationNameTarget) this.locationNameTarget.value = ''
    
    if (this.marker) {
      this.marker.remove()
      this.marker = null
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }
}
