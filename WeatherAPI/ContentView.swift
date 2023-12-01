import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.hourlyForecasts) { forecast in
                       HStack {
                           Text(forecast.formattedTime)
                           Spacer()
                           Text("\(forecast.temperature, specifier: "%.1f")°C")
                       }
                   }
            .navigationTitle("Tiempo en \(viewModel.currentCity)")
            .onAppear {
                viewModel.requestLocation()
                
            }
            .alert(isPresented: Binding<Bool>.constant($viewModel.errorMessage.wrappedValue != nil), content: {
                Alert(title: Text("Error"), message: Text($viewModel.errorMessage.wrappedValue ?? "Unknown error"), dismissButton: .default(Text("OK")))
            })
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
