import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WeatherViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Şehir Adı", text: $viewModel.cityName, onCommit:  {
                    viewModel.fetchWeather()
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.fetchWeather()
                }) {
                    Image(systemName: "magnifyingglass")
                        .padding()
                }
                
                Button(action: {
                    viewModel.addFavoriteCity()
                }) {
                    Image(systemName: "star")
                        .padding()
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let weather = viewModel.weather {
                VStack(spacing: 20) {
                    Text(weather.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let icon = weather.weather.first?.icon {
                        let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
                        AsyncImage(url: iconUrl) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                    }
                    
                    Text("\(weather.main.temp, specifier: "%.1f")°C")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
            } else {
                Text("Hava durumu bilgisi yok")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            List {
                ForEach(viewModel.favoriteCities, id: \.self) { city in
                    Text(city)
                        .onTapGesture {
                            viewModel.cityName = city
                            viewModel.fetchWeather()
                        }
                        .contextMenu {
                            Button(action: {
                                if let index = viewModel.favoriteCities.firstIndex(of: city) {
                                    viewModel.removeFavoriteCity(at: index)
                                }
                            }) {
                                Text("Favoriden Kaldır")
                                Image(systemName: "trash")
                            }
                        }
                }
                .onDelete(perform: removeCities)
            }
            .listStyle(PlainListStyle())
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func removeCities(at offsets: IndexSet) {
        for index in offsets {
            viewModel.removeFavoriteCity(at: index)
        }
    }
}

@main // uygulamanın ana giriş noktası olduğunu belirtiyor
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
