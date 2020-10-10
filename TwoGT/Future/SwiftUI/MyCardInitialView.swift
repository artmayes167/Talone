//
//  MyCardInitialView.swift
//  TwoGT
//
//  Created by Arthur Mayes on 9/19/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit

struct MyCardInitialView: View {
    @ObservedObject var fbmanager = UserLoginManager()
    var buttonActions = MyCardInitialButtonManager()
       var body: some View {
        VStack(spacing: 10.0) {
            Text("Initiate Card Data").bold()
                .font(.title)
            LineView()
            Spacer()
            Text("The following button is owned by the Evil Empire of Doom, which has contributed to the downfall of American democracy, by negligence, if not outright complicity.  But you gave them your information, and it will make this app more useful for you.")
            Spacer()
            Image("downArrow")
                .resizable()
                                  .frame(width: 50, height: 25, alignment: .center)
               Button(action: {
                   self.fbmanager.facebookLogin()
               }) {
                   Text("Continue with Facebook")
               }
            Image("upArrow")
                .resizable()
                                  .frame(width: 50, height: 25, alignment: .center)
            Button(action: {
                self.buttonActions.goToManual()
            }) {
                Text("(Manual Entry Coming Soon)")
            }.disabled(true)
            Text("Your information will be saved in the app, and will not be transmitted to our database.")
            
        }.padding()
        }
}

struct MyCardInitialView_Previews: PreviewProvider {
    static var previews: some View {
        MyCardInitialView()
    }
}

struct LineView: View {
    var body: some View {
        self.colorInvert()
        self.frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

class MyCardInitialButtonManager {
    func goToManual() {
        
    }
}

class UserLoginManager: ObservableObject {
    let loginManager = LoginManager()
    func facebookLogin() {
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){
                        let fbDetails = result as! NSDictionary
                        print(fbDetails)
                    }
                })
            }
        }
    }
}
