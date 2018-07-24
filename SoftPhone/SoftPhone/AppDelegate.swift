/* Copyright (c) 2017 BlackBerry.  All Rights Reserved.
* 
* Licensed under the Apache License, Version 2.0 (the "License"); 
* you may not use this file except in compliance with the License. 
* You may obtain a copy of the License at 
* 
* http://www.apache.org/licenses/LICENSE-2.0 
* 
* Unless required by applicable law or agreed to in writing, software 
* distributed under the License is distributed on an "AS IS" BASIS, 
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
* See the License for the specific language governing permissions and 
* limitations under the License. 
  
* This sample code was created by BlackBerry using SDKs from Apple Inc. 
* and may contain code licensed for use only with Apple products. 
* Please review your Apple SDK Agreement for additional details. 
*/ 


import UIKit
import GoogleSignIn
import MSAL

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    
    //URL handling is required to handle the URL based callbacks from Google Sign via Safari
    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        if BBMConfigManager.default().type == kGoogleSignIn {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        if BBMConfigManager.default().type == kAzureAD {
            return MSALPublicRTApplication.handleMSALResponse(url)
        }
        return false;
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool
    {
        if BBMConfigManager.default().type == kGoogleSignIn {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
        return false;
    }

}
