//
//  Constants.swift
//  iHeartMonitor
//
//  Created by Harini Balakrishnan on 5/14/18.
//  Copyright © 2018 Harini Balakrishnan. All rights reserved.
//

import Foundation
struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignInToFp = "SignInToFP"
        static let FpToSignIn = "FPToSignIn"
    }
    
    struct MessageFields {
        static let name = "name"
        static let text = "text"
        static let photoURL = "photoURL"
        static let imageURL = "imageURL"
    }
}
