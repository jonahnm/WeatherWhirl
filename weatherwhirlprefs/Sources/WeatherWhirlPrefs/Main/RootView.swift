import SwiftUI
import Combine
import Foundation
import WeatherWhirlPrefsC
import Comet
@available(iOS 14.0, *)
struct RootView: View {
    @StateObject private var preferenceStorage = PreferenceStorage()
    @State private var selectedOption: String?
        @State private var isDebugMenuPresented = false
        private let options = ["Tornado [Currently defunct]", "Light rain"]
        @State private var backgroundImage: UIImage? = nil
        
        var body: some View {
            NavigationView {
                ZStack {
                    if let backgroundImage = backgroundImage {
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                    }
                    VStack {
                        Button("Open Debug Menu") {
                            isDebugMenuPresented = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $isDebugMenuPresented) {
                        DebugMenuView(selectedOption: $selectedOption, options: options)
                            .environmentObject(preferenceStorage)
                    }
                }
                .onAppear {
                    loadImage()
                }
            }
        }
        
        func loadImage() {
            ImageLoader.loadImage(from: "https://media.springernature.com/w300/springer-static/image/art%3A10.1038%2F521135a/MediaObjects/41586_2015_Article_BF521135a_Figa_HTML.jpg?as=webp") { image in
                self.backgroundImage = image
            }
        }
}
@available(iOS 14, *)
struct DebugMenuView: View {
    @Binding var selectedOption: String?
    @EnvironmentObject var preferenceStorage: PreferenceStorage
    let options: [String]
    
    var body: some View {
        VStack {
            Picker("Select an option", selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            Button("Trigger") {
                if selectedOption == "Light rain" {
                    preferenceStorage.shouldOverride = true
                    preferenceStorage.override = selectedOption!
                    Respring.execute()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
@available(iOS 14, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
@available(iOS 14, *)
struct ImageLoader {
    static func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }.resume()
    }
}
