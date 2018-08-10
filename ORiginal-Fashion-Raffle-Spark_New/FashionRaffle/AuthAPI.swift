//
//  AuthAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/11/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthAPI : NSObject {
    
    let userRef = API().userRef
    
    
    // Create new user with Email
    func createNewUser(withName name:String, withEmail email:String, withPassword password: String, onSuccess:@escaping()->Void) {
        Config.showPlainLoading(withStatus: "Registering...")
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            user, error in
            if error != nil {
                Config.showError(withStatus: error!.localizedDescription)
                return
            }
            guard let userID = user?.uid else {
                Config.dismissPlainLoading()
                return
            }
            
            let newUser = Profile.newUser(username: name, userID: userID, email: email)
            Profile.currentUser = newUser
            newUser.sync(onSuccess: {
                FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: {
                    EmailVError in
                    if EmailVError != nil {
                        Config.showError(withStatus: EmailVError!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        Config.dismissPlainLoading()
                        try! FIRAuth.auth()?.signOut()
                        onSuccess()
                    }
                })
            }, onError: {
                error in
                print(error.localizedDescription)
                Config.dismissPlainLoading()
                return
            })
        })
    }
    
    // Sign in with Email
    func signInWithEmail(withEmail email:String, withPassword password: String, onSuccess:@escaping()->Void, onEmailNotVerified: @escaping()->Void) {
        Config.showPlainLoading(withStatus: "Logging in...")
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
            user, error in
            if error != nil {
                Config.showError(withStatus: error!.localizedDescription)
                return
            }
            guard let uid = user?.uid else {
                Config.dismissPlainLoading()
                return
            }
            if user?.isEmailVerified == false {
                Config.dismissPlainLoading()
                self.authLogOut()
                onEmailNotVerified()
                return
            }
            
            API.userAPI.fetchUserInfo(withID: uid, completion: {
                profile in
                if let fetchedProfile = profile {
                    Profile.currentUser = fetchedProfile
                    
                    DispatchQueue.main.async {
                        Config.dismissPlainLoading()
                        onSuccess()
                    }
                    
                }
                
            })
        })
    }
    
    // Sign in with FaceBook Credentials
    func signInWithFaceBook(withAccessToken token: String, onSuccess:@escaping() -> Void, onError:@escaping()->Void) {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
        // Check if there is a Database Value
        Config.showPlainLoading(withStatus: "Logging in...")
        FIRAuth.auth()?.signIn(with: credential, completion: {
            user, error in
            if error != nil {
                Config.showError(withStatus: error!.localizedDescription)
                onError()
                return
            }
            guard let userID = user?.uid else{
                Config.dismissPlainLoading()
                return
            }
            API.userAPI.fetchUserInfo(withID: userID, completion: {
                fetchedProfile in
                if let profile = fetchedProfile {
                    Profile.currentUser = profile
                }
                else {
                    // No value in the database, will create one
                    print("No data in the database, will create one")
                    for contents in (user?.providerData)! {
                        let name = contents.displayName
                        let email = contents.email
                        let fbID = contents.uid
                        let newFBUser = Profile.newUser(username: name, userID: userID, email: email)
                        if let imageURL = URL(string: "http://graph.facebook.com/\(fbID)/picture?type=large") {
                            newFBUser.profilePicUrl = imageURL
                        }
                        Profile.currentUser = newFBUser
                        newFBUser.sync(onSuccess: {}, onError: {
                            error in
                            print(error.localizedDescription)
                        })
                    }
                }
                DispatchQueue.main.async {
                    Config.dismissPlainLoading()
                    onSuccess()
                }
                
            })
            
        })
    }
    
    // Check if currentUser is nil
    func checkCurrentUser() -> Bool {
        
        if FIRAuth.auth()?.currentUser != nil {
            return true
        }
        else {
            return false
        }
        
    }
    
    // LogOut
    func authLogOut() {
        try! FIRAuth.auth()?.signOut()
    }
    
    
    // Send Reset Password Email
    func sendPasswordReset(withEmail email:String, onSuccess: @escaping()-> Void) {
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: {
            error in
            if error != nil {
                Config.showError(withStatus: error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    
}
