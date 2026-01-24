//
//  artemisApp.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

@main
struct artemisApp: App {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if didCompleteOnboarding {
                ContentView()
            } else {
                OnboardingContainerView()
            }
        }
    }
}
