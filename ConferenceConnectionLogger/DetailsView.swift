//
//  DetailsView.swift
//  ConferenceConnectionLogger
//
//  Created by Mladen Ivastinovic on 17.05.2021..
//

import SwiftUI

struct DetailsView: View {

    @State var image: UIImage = UIImage()
    let person: Person

    init(person: Person) {
        self.person = person
    }
    
    
    func loadImage(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }

    
    var body: some View {
        Image(uiImage: image)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width:200, height:300)
                .background(Color.black)
            .onAppear(perform: {
                self.loadImage(url: self.person.getImageUrl())
            })
        Text(person.name)
     }
    
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(person: Person(name: ""))
    }
}
