// Mapbox controller unit tests
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { Application } from '@hotwired/stimulus'
import MapboxController from '../../../app/javascript/controllers/mapbox_controller'

// Mock Mapbox GL JS
const mockMap = {
  on: vi.fn(),
  off: vi.fn(),
  remove: vi.fn(),
  setCenter: vi.fn(),
  getCenter: vi.fn(() => ({ lng: 0, lat: 0 })),
  addControl: vi.fn(),
  removeControl: vi.fn(),
  flyTo: vi.fn(),
  resize: vi.fn()
}

const mockGeocoder = {
  on: vi.fn(),
  off: vi.fn(),
  query: vi.fn(),
  clear: vi.fn()
}

vi.mock('mapbox-gl', () => ({
  default: {
    Map: vi.fn(() => mockMap),
    Marker: vi.fn(() => ({
      setLngLat: vi.fn().mockReturnThis(),
      addTo: vi.fn().mockReturnThis(),
      remove: vi.fn()
    })),
    Popup: vi.fn(() => ({
      setLngLat: vi.fn().mockReturnThis(),
      setHTML: vi.fn().mockReturnThis(),
      addTo: vi.fn().mockReturnThis()
    })),
    accessToken: 'test-token'
  }
}))

vi.mock('@mapbox/mapbox-gl-geocoder', () => ({
  default: vi.fn(() => mockGeocoder)
}))

describe('MapboxController', () => {
  let application
  let controller
  let element

  beforeEach(() => {
    // Set up DOM element
    element = document.createElement('div')
    element.setAttribute('data-controller', 'mapbox')
    element.setAttribute('data-mapbox-api-key-value', 'test-api-key')
    element.setAttribute('data-mapbox-latitude-value', '40.7128')
    element.setAttribute('data-mapbox-longitude-value', '-74.0060')
    element.innerHTML = `
      <div data-mapbox-target="map" style="width: 400px; height: 300px;"></div>
      <input data-mapbox-target="latitudeField" type="hidden" />
      <input data-mapbox-target="longitudeField" type="hidden" />
      <input data-mapbox-target="searchInput" type="text" />
    `
    document.body.appendChild(element)

    // Set up Stimulus application
    application = Application.start()
    application.register('mapbox', MapboxController)
    
    controller = application.getControllerForElementAndIdentifier(element, 'mapbox')
  })

  afterEach(() => {
    if (element.parentNode) {
      element.parentNode.removeChild(element)
    }
    application.stop()
    vi.clearAllMocks()
  })

  describe('Initialization', () => {
    it('should initialize with correct API key', () => {
      expect(controller.apiKeyValue).toBe('test-api-key')
    })

    it('should initialize with correct coordinates', () => {
      expect(controller.latitudeValue).toBe(40.7128)
      expect(controller.longitudeValue).toBe(-74.0060)
    })

    it('should create map instance on connect', () => {
      expect(mockMap.on).toHaveBeenCalledWith('click', expect.any(Function))
      expect(mockMap.addControl).toHaveBeenCalled()
    })

    it('should handle missing API key gracefully', () => {
      element.removeAttribute('data-mapbox-api-key-value')
      const consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})
      
      controller.connect()
      
      expect(consoleWarnSpy).toHaveBeenCalledWith('Mapbox API key not configured')
      consoleWarnSpy.mockRestore()
    })
  })

  describe('Map Interactions', () => {
    it('should handle map click events', () => {
      const clickEvent = {
        lngLat: { lng: -73.9857, lat: 40.7484 }
      }
      
      // Simulate map click
      const clickHandler = mockMap.on.mock.calls.find(call => call[0] === 'click')[1]
      clickHandler(clickEvent)
      
      expect(controller.latitudeFieldTarget.value).toBe('40.7484')
      expect(controller.longitudeFieldTarget.value).toBe('-73.9857')
    })

    it('should update coordinates when values change', () => {
      controller.latitudeValue = 41.8781
      controller.longitudeValue = -87.6298
      
      controller.coordinatesValueChanged()
      
      expect(mockMap.setCenter).toHaveBeenCalledWith([-87.6298, 41.8781])
    })

    it('should handle search functionality', () => {
      const searchQuery = 'Central Park, New York'
      controller.searchInputTarget.value = searchQuery
      
      controller.search()
      
      expect(mockGeocoder.query).toHaveBeenCalledWith(searchQuery)
    })

    it('should clear search results', () => {
      controller.clearSearch()
      
      expect(mockGeocoder.clear).toHaveBeenCalled()
      expect(controller.searchInputTarget.value).toBe('')
    })
  })

  describe('Geocoding', () => {
    it('should handle geocoding results', () => {
      const geocodingResult = {
        result: {
          center: [-73.9857, 40.7484],
          place_name: 'Central Park, New York, NY, USA'
        }
      }
      
      // Simulate geocoding result
      const resultHandler = mockGeocoder.on.mock.calls.find(call => call[0] === 'result')[1]
      resultHandler(geocodingResult)
      
      expect(controller.latitudeFieldTarget.value).toBe('40.7484')
      expect(controller.longitudeFieldTarget.value).toBe('-73.9857')
      expect(mockMap.flyTo).toHaveBeenCalledWith({
        center: [-73.9857, 40.7484],
        zoom: 15
      })
    })

    it('should handle geocoding errors', () => {
      const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      
      // Simulate geocoding error
      const errorHandler = mockGeocoder.on.mock.calls.find(call => call[0] === 'error')[1]
      errorHandler(new Error('Geocoding failed'))
      
      expect(consoleErrorSpy).toHaveBeenCalledWith('Geocoding error:', expect.any(Error))
      consoleErrorSpy.mockRestore()
    })
  })

  describe('Marker Management', () => {
    it('should add marker at specified coordinates', () => {
      const coordinates = [-73.9857, 40.7484]
      
      controller.addMarker(coordinates)
      
      expect(controller.marker).toBeDefined()
      expect(controller.marker.setLngLat).toHaveBeenCalledWith(coordinates)
      expect(controller.marker.addTo).toHaveBeenCalledWith(mockMap)
    })

    it('should remove existing marker before adding new one', () => {
      const coordinates1 = [-73.9857, 40.7484]
      const coordinates2 = [-74.0060, 40.7128]
      
      controller.addMarker(coordinates1)
      const firstMarker = controller.marker
      
      controller.addMarker(coordinates2)
      
      expect(firstMarker.remove).toHaveBeenCalled()
      expect(controller.marker.setLngLat).toHaveBeenCalledWith(coordinates2)
    })

    it('should update marker position when coordinates change', () => {
      controller.addMarker([-73.9857, 40.7484])
      
      controller.latitudeValue = 40.7128
      controller.longitudeValue = -74.0060
      controller.coordinatesValueChanged()
      
      expect(controller.marker.setLngLat).toHaveBeenCalledWith([-74.0060, 40.7128])
    })
  })

  describe('Cleanup', () => {
    it('should remove map on disconnect', () => {
      controller.disconnect()
      
      expect(mockMap.remove).toHaveBeenCalled()
    })

    it('should remove marker on disconnect', () => {
      controller.addMarker([-73.9857, 40.7484])
      const marker = controller.marker
      
      controller.disconnect()
      
      expect(marker.remove).toHaveBeenCalled()
    })

    it('should clean up event listeners on disconnect', () => {
      controller.disconnect()
      
      expect(mockMap.off).toHaveBeenCalled()
      expect(mockGeocoder.off).toHaveBeenCalled()
    })
  })

  describe('Error Handling', () => {
    it('should handle map initialization errors', () => {
      const mapError = new Error('Map initialization failed')
      vi.mocked(mockMap.on).mockImplementation((event, callback) => {
        if (event === 'error') {
          callback(mapError)
        }
      })
      
      const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      
      controller.connect()
      
      expect(consoleErrorSpy).toHaveBeenCalledWith('Map error:', mapError)
      consoleErrorSpy.mockRestore()
    })

    it('should validate coordinates before setting', () => {
      const invalidLat = 'invalid'
      const invalidLng = 'invalid'
      
      controller.latitudeFieldTarget.value = invalidLat
      controller.longitudeFieldTarget.value = invalidLng
      
      controller.updateCoordinatesFromFields()
      
      // Should not update map with invalid coordinates
      expect(mockMap.setCenter).not.toHaveBeenCalledWith([invalidLng, invalidLat])
    })
  })

  describe('Responsive Behavior', () => {
    it('should resize map when container size changes', () => {
      // Simulate container resize
      const resizeObserver = new ResizeObserver(() => {
        controller.handleResize()
      })
      
      controller.handleResize()
      
      expect(mockMap.resize).toHaveBeenCalled()
    })

    it('should handle mobile touch events', () => {
      const touchEvent = {
        lngLat: { lng: -73.9857, lat: 40.7484 },
        originalEvent: { type: 'touchend' }
      }
      
      const clickHandler = mockMap.on.mock.calls.find(call => call[0] === 'click')[1]
      clickHandler(touchEvent)
      
      expect(controller.latitudeFieldTarget.value).toBe('40.7484')
      expect(controller.longitudeFieldTarget.value).toBe('-73.9857')
    })
  })
})
