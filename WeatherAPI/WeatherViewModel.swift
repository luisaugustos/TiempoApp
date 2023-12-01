import Foundation
import CoreLocation


// ViewModel que maneja la lógica de la ubicación y la obtención del clima, tambien convierte el lat/lng en ciudad.
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var hourlyForecasts: [HourlyForecast] = []
    @Published var currentCity: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        getCityName(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] cityName in
                    DispatchQueue.main.async {
                        self?.currentCity = cityName ?? "Desconocido"
                    }
                }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
        
    }

    private func fetchWeatherData(latitude: Double, longitude: Double) {
        isLoading = true
        weatherService.fetchWeatherData(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedWeatherData):
                    self?.hourlyForecasts = fetchedWeatherData
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func getCityName(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Error en la geocodificación inversa: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            if let placemark = placemarks?.first {
                // Extraer el nombre de la ciudad del CLPlacemark y devolverlo
                let cityName = placemark.locality
                completion(cityName)
            } else {
                completion(nil)
            }
        }
    }


}
