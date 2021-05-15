//
//  ContentView.swift
//  ConferenceConnectionLogger
//
//  Created by COBE on 15/05/2021.
//

import SwiftUI

struct Person: Identifiable, Codable {
    var id = UUID()
    
    enum CodingKeys: CodingKey {
        case id, image, name
    }
    var name: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // image = try container.decode(Data.self, forKey: .image)
        name = try container.decode(String.self, forKey: .name)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    init (image: Image, name: String){
        self.id = UUID()
        self.name = name
    }
}


struct ContentView: View {
    @State private var imageSelected = false
    @State private var pickImage = false
    @State private var imageName = ""
    @State private var people = [Person]()
    @State private var image: Image?
    @State private var showSheet = false
    @State private var inputImage: UIImage?
    var body: some View {
        NavigationView {
            VStack {
                List(people){ person in
                    NavigationLink(destination: Image(person.name)){
                            Image(person.name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                        Text(person.name)
                    }
                }
                Button("Add"){
                    self.showSheet = true
                }
            }
        }
        .onAppear(perform: loadUsers)
        .sheet(isPresented: $showSheet, onDismiss: saveUser) {
            ImagePicker(image: self.$inputImage)
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func loadUsers(){
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let savedPerson = defaults.object(forKey: "SavedPerson") as? Data {
            if let loadedPerson = try? decoder.decode(Person.self, from: savedPerson) {
                people.append(loadedPerson)
            }
        }
    }
    
    func saveUser(){
        loadImage()
        let url = getDocumentsDirectory()
        if let jpegData = inputImage?.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: url, options: [.atomicWrite, .completeFileProtection])
            let person = Person(image: image!, name: "Steve")
            people.append(person)
            UIImageWriteToSavedPhotosAlbum(inputImage!, nil, nil, nil)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(person) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "SavedPerson")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
