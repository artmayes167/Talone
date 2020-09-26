//
//  ContentView.swift
//  TwoGT
//
//  Created by Arthur Mayes on 7/8/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit
import AlamofireImage
import CoreData

//     @Environment(\.colorScheme) var colorScheme: ColorScheme
//
//     var body: some View {
//         if colorScheme == .dark {
//             DarkContent()
//         } else {
//             LightContent()
//         }
//     }

struct ContentView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.imageCache) var cache: ImageCache
    @State var name = AppDelegate.user.handle ?? "YOU!"
    @State var email: String = { () -> String in
        if let emails = AppDelegate.user.emails {
            let x = emails.filter {
                if let e = ($0 as? Email) {
                    return e.name == DefaultsKeys.taloneEmail.rawValue
                }
                return false
            }
            if let str = x.first as? Email {
                return str.emailString!
            }
        }
        return ""
    }()
    var imageName = Profile.current?.imageURL(forMode: Profile.PictureMode.square, size: CGSize.init(width: 200, height: 200))
    var body: some View {

        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                                  .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 10)
            
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
                TextField("Handle", text: $name)
                TextField("Primary Email", text: $email)
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
