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

import Foundation
import Firebase
import GoogleSignIn


//Call Log Event Tag and Properties
public let kCallEventTag            = "Call_Event"
public let kCallEventTimestampKey   = "callEndTime"
public let kCallEventDurationKey    = "callDuration"
public let kCallEventReasonKey      = "callLogReason"

//Ringtone Assets
public let kIncomingRingtone        = "incoming_call_ringtone.caf"
public let kOutgoingRingtone        = "outgoing_call_ringtone.caf"
public let kEndCallRingtone         = "endTone.caf"

let _endpointManager : BBMEndpointManager = BBMEndpointManager()

//Our main application instance.
//This handles logging into firebase, configuring the media manager and monitoring and 
//synchronizing chats and their associated keys via BBMKeyManager
class SoftPhoneApp
{
    private let _authController : BBMAuthController = BBMAuthController(tokenManager:BBMGoogleTokenManager.self)

    var authMonitor: ObservableMonitor?
    var keyMonitor: ObservableMonitor?
    var serviceMonitor : ObservableMonitor?

    var keyManager : BBMKeyManager!
    var callListener : CallListener!

    private static let appInstance : SoftPhoneApp = {
        let instance = SoftPhoneApp()

        //Set our logging mode to echo to the console
        BBMEnterpriseService.shared().setLoggingMode(kBBMLogModeFileAndConsole)

        instance.authController().startBBMEnterpriseService()

        instance.startAuthMonitor()
        instance.startServiceMonitor()

        instance.authController().signInSilently()

        return instance
    }()

    class func app() -> SoftPhoneApp {
        return appInstance
    }

    //Get the shared authentication controller
    func authController() -> BBMAuthController {
        return _authController
    }

    //Get the shared endpoint manager
    func endpointManager() -> BBMEndpointManager {
        return _endpointManager
    }

    //iOS CallKit is only available on iOS 10 and up.
    public let callKitManager : CallKitManager? = {
        if #available(iOS 10.0, *) {
            return CallKitManager.init()
        }
        return nil
    }()

    private func startMediaManager() {
        //Start the media manager with the default log path
        let mediaManager = BBMEnterpriseService.shared().mediaManager()!
        mediaManager.start(withLogPath: nil)

        //Set the ringtones
        let endTonePath = Bundle.main.path(forResource: kEndCallRingtone, ofType: nil)
        let endToneURL = NSURL.fileURL(withPath: endTonePath!)
        mediaManager.callEndTone = endToneURL

        if nil == callKitManager {
            //Call kit will play the incoming ringtone so we shouldn't set it
            let incTonePath = Bundle.main.path(forResource: kIncomingRingtone, ofType: nil)
            let incToneURL = NSURL.fileURL(withPath: incTonePath!)
            mediaManager.incomingRingtone = incToneURL
        }

        let outTonePath = Bundle.main.path(forResource: kOutgoingRingtone, ofType: nil)
        let outToneURL = NSURL.fileURL(withPath: outTonePath!)
        mediaManager.outgoingRingtone = outToneURL
    }

    private func startServiceMonitor() {
        serviceMonitor = ObservableMonitor(activatedWithName: "ServiceMonitor") {
            [weak self] () -> Bool in
            if(self?.authController().serviceStarted == true) {
                FIRApp.configure()

                //We need to wait until all of the services are started before 
                //initializing the keyManager, mediaManager and callListeners
                self?.keyManager = BBMKeyManager(keyStorageProvider: BBMFirebaseKeyStorageProvider())

                self?.startMediaManager()
                
                self?.callListener = CallListener()

                return true
            }
            return false
        }
    }

    private func startAuthMonitor() {
        authMonitor = ObservableMonitor(activatedWithName: "AppAuthMonitor") {
            [weak self] () -> Void in

            let logoutHandler : ()->Void = { 
                if (FIRAuth.auth()?.currentUser != nil) {
                    do {
                        self?.keyManager.stopAutomaticKeySync()
                        try FIRAuth.auth()?.signOut()
                    }catch {
                        NSLog("Sign out failed")
                        self?.keyManager.startAutomaticKeySync()
                    }
                }
            }

            //No auth state?  Logout
            guard let authState = self?.authController().authState,
                      authState.account != nil,
                      authState.regId != nil else
            {
                logoutHandler()
                return
            }

            //We are authenticated.  Pass the credentials to Firebase and syncronize our
            //profile keys
            let credentials = FIRGoogleAuthProvider.credential(withIDToken: authState.account.idToken,
                                                               accessToken: authState.account.accessToken)
            FIRAuth.auth()?.signIn(with: credentials) { (user, error) -> Void in
                if let error = error {
                    NSLog("FIRAuth sign-in error %@", error.localizedDescription)
                }else{
                    self?.keyManager.syncProfileKeys(forLocalUser: user?.uid, regId: authState.regId.stringValue)
                }
            }
        }
    }
}