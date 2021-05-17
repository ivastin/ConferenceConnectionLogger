//
//  ContentView.swift
//  ConferenceConnectionLogger
//
//  Created by COBE on 15/05/2021.
//

import SwiftUI

struct Person: Identifiable, Codable, Comparable {
    var id = UUID()
    enum CodingKeys: CodingKey {
        case id, name
    }
    var name: String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    init (name: String){
        self.id = UUID()
        self.name = name
    }
    init (){
        self.id = UUID()
        self.name = ""
    }
    static func < (lhs: Person, rhs: Person) -> Bool {
        lhs.name < rhs.name
    }
    public func getImageUrl() -> URL {
        let id = self.id.uuidString
        return getDocumentsDirectory().appendingPathComponent(id)
    }
}

struct DetailView: View {
    var optionalData = UIImage(systemName: "Steve")?.jpegData(compressionQuality: 1)
    var person: Person
    var body: some View {
        Image(uiImage: ((loadImageFromURL(person: person)) ?? UIImage(data: optionalData!))!)
            .resizable()
            .scaledToFit()
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct ContentView: View {
    private var optionalData = UIImage(systemName: "Steve")?.jpegData(compressionQuality: 1)
    @State private var people = [Person]()
    @State private var showImageAddingSheet = false
    @State private var inputImage: UIImage?
    @State private var nameImage = false
    @State private var newPersonName = ""
    var body: some View {
        NavigationView {
            VStack {
                List(people){ person in
                   NavigationLink(destination: DetailView(person: person)){
                    Image(uiImage: ((loadImageFromURL(person: person)) ?? UIImage(data: optionalData!))!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32.0, height: 32.0)
                    Text(person.name)
                    }
                    
                }
                Button("Add"){
                    self.showImageAddingSheet = true
                }
            }
            .navigationBarTitle(Text("ConferenceConn"))
            .sheet(isPresented: $nameImage, onDismiss: saveUser){
                TextField("Enter image name", text: $newPersonName)
                Button("OK"){
                    self.nameImage.toggle()
                }
            }
        }
        .onAppear(perform: loadUsers)
        .sheet(isPresented: $showImageAddingSheet, onDismiss: showImageNamingSheet) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func showImageNamingSheet(){
        nameImage = true
    }
    
    
    func loadUsers(){
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let savedPerson = defaults.object(forKey: "SavedPeople") as? Data {
            if let loadedPerson = try? decoder.decode([Person].self, from: savedPerson) {
                self.people = loadedPerson
            }
        }
    }
    
    func saveUser(){
        var newPerson = Person()
        newPerson.name = newPersonName
        let url = newPerson.getImageUrl()
        if let jpegData = inputImage?.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: url, options: [.atomicWrite, .completeFileProtection])
            people.append(newPerson)
            people.sort()
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(people) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "SavedPeople")
            }
        }
    }
}



func loadImageFromURL(person: Person) -> UIImage? {
    let fileURL = person.getImageUrl()
    do {
        let imageData = try Data(contentsOf: fileURL)
        return UIImage(data: imageData)
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
