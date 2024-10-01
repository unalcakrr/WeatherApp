//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Ünal Çakır on 14.06.2024.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var cityName: String = ""
    @Published var isLoading: Bool = false
    @Published var favoriteCities:  [String] = []
    
    private let favoritesKey = "favoriteCities"
    let apiKey = "ab582031a0cc48bcb6fc68240efbba10" // OpenWeatherMap'ten aldığınız API anahtarı
    
    init() {
        loadFavoriteCities()
    }
    
    func fetchWeather() {
        guard !cityName.isEmpty else { return }
        
        isLoading = true
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        self.weather = try decoder.decode(WeatherResponse.self, from: data)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
        }.resume()
    }
    
    func addFavoriteCity() {
        if !cityName.isEmpty && !favoriteCities.contains(cityName) {
            favoriteCities.append(cityName)
            saveFavoriteCities()
        }
    }
    
    func removeFavoriteCity(at index: Int) {
        favoriteCities.remove(at: index)
        saveFavoriteCities()
    }
    
    private func saveFavoriteCities() {
        UserDefaults.standard.set(favoriteCities, forKey: favoritesKey)
    }
    
    private func loadFavoriteCities() {
        if let savedCities = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteCities = savedCities
        }
    }
}
