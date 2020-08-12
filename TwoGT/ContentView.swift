//
//  ContentView.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit
//import AlamofireImage

struct ContentView: View {
    @Environment(\.imageCache) var cache: ImageCache
    @State var name = Profile.current?.firstName ?? "YOU!"
    @State var lastName = Profile.current?.lastName ?? "none"
    @State var email = Profile.current?.userID ?? ""
    var imageName = Profile.current?.imageURL(forMode: Profile.PictureMode.square, size: CGSize.init(width: 200, height: 200))
    var body: some View {

        VStack {
//            Image(systemName: "person.circle.fill")
//                .resizable()
//                                  .frame(width: 200, height: 200, alignment: .center)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                .shadow(radius: 10)
            
            AsyncImage(
                url: imageName!,
                   cache: self.cache,
                   placeholder: Image(systemName: "person.circle.fill"),
                   configuration: { $0.resizable() }
                )
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                .shadow(radius: 2)
            Image("metal-nameplate").resizable(resizingMode: .stretch)
                .frame(width: 250, height: 40, alignment: .center)
                .cornerRadius(3.0)
                .offset(y: -55)
                .opacity(0.9)
                .padding(.bottom, -55)
            Text(name).font(.title)
                .offset(y: -63)
                .padding(.bottom, -63)
            HStack {
                TextField("First Name", text: $name)
                TextField("Last Name", text: $lastName)
                TextField("User Name", text: $email)
            }
            Spacer()
        }.padding()
        
//        List {
        //                HStack {
        //                    Image(systemName: "person.circle.fill").resizable()
        //                        .frame(width: 40, height: 40, alignment: .leading)
        //                    Spacer(minLength: 8.0)
        //                    VStack(alignment: .leading, spacing: 8.0) {
        //                        Text("Hi")
        //                        Text("Welcome to Hello World")
        //                    }
        //                }.padding()
        //            }.navigationBarTitle(title)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
