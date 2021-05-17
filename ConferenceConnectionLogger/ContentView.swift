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
    func getImageUrl() -> URL {
        let id = self.id.uuidString
        return getDocumentsDirectory().appendingPathComponent(id)
    }
}

//struct DetailView: View {
//    var person: Person
//    var image : UIImage = UIImage(named:"afternoon")!
//    bgImage.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
//    view.addSubview(bgImage)
//    var body: some View {
//        return UIImageView(image: image)
//    }
//}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var optionalData = UIImage(systemName: "Steve")?.jpegData(compressionQuality: 1)
    @State private var imageSelected = false
    @State private var pickImage = false
    @State private var imageName = ""
    @State private var people = [Person]()
    @State private var image: Image?
    @State private var showSheet = false
    @State private var inputImage: UIImage?
    @State private var editName = false
    @State private var nameImage = false
    @State private var newPersonName = ""
    var body: some View {
        NavigationView {
            VStack {
                List(people){ person in
                    NavigationLink(destination: Image("Steve")){
                        Image("Steve")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32.0, height: 32.0)
                        Text(person.name)
                    }
                }
                Button("Add"){
                    self.showSheet = true
                }
            }
            .onAppear(perform: loadUsers)
            .sheet(isPresented: $nameImage, onDismiss: saveUser){
                TextField("Enter image name", text: $newPersonName)
                Button("OK"){
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear(perform: loadUsers)
        .sheet(isPresented: $showSheet, onDismiss: imageNamed) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func imageNamed(){
        nameImage = true
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func loadUsers(){
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let savedPerson = defaults.object(forKey: "SavedPerson") as? Data {
            if let loadedPerson = try? decoder.decode([Person].self, from: savedPerson) {
                self.people = loadedPerson
            }
        }
    }
    
    
    func saveUser(){
        var newPerson = Person()
        loadImage()
        let id = newPerson.id.uuidString
        let url = getDocumentsDirectory().appendingPathComponent(id)
        if let jpegData = inputImage?.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: url, options: [.atomicWrite, .completeFileProtection])
            newPerson.name = newPersonName
            people.append(newPerson)
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(people) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "SavedPerson")
            }
        }
    }
}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
//
//extension Image {
//    private var optionalData = UIImage(systemName: "Steve")?.jpegData(compressionQuality: 1)
//    func load(url: URL){
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url){
//                if let image = Image(uiImage: UIImage(data: data ?? optionalData!)!) {
//                    DispatchQueue.main.async {
//                        self.image = image
//                    }
//            }
//        }
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
