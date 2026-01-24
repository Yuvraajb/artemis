//
//  OnboardingContainerView.swift
//  artemis
//
//  Created for onboarding experience
//

import SwiftUI

/// Onboarding state machine - tracks progression through onboarding steps
/// Matches storyboard frames exactly
enum OnboardingStep: Int, CaseIterable {
    case arrival              // Frame 01
    case slsReveal           // Frame 02
    case slsStillness        // Frame 03
    case arPlacement         // Frame 04 & 05 (placement → walk back)
    case purpose             // Frame 06
    case authorizeLaunch     // Frame 07 & 08
    case launchSequence      // Frame 09 & 10 (launch sequence → orbital silence)
    case appUnlock           // Frame 11
    case completed
}

/// Main container that manages onboarding state and transitions
struct OnboardingContainerView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @State private var currentStep: OnboardingStep = .arrival
    
    // Respect Reduce Motion accessibility setting
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch currentStep {
                case .arrival:
                    ArrivalView(onContinue: { advanceToNextStep() }, reduceMotion: reduceMotion)
                case .slsReveal:
                    SLSRevealView(onContinue: { advanceToNextStep() }, reduceMotion: reduceMotion)
                case .slsStillness:
                    SLSStillnessView(onContinue: { advanceToNextStep() })
                case .arPlacement:
                    // Frame 04: AR Placement → Frame 05: AR Scale Comprehension
                    ARPlacementView(onContinue: { advanceToNextStep() })
                case .purpose:
                    PurposeView(onContinue: { advanceToNextStep() }, reduceMotion: reduceMotion)
                case .authorizeLaunch:
                    AuthorizeLaunchView(onContinue: { advanceToNextStep() })
                case .launchSequence:
                    // Frame 09: Launch Sequence → Frame 10: Orbital Silence
                    LaunchSequenceView(onContinue: { advanceToNextStep() }, reduceMotion: reduceMotion)
                case .appUnlock:
                    AppUnlockView(onComplete: { completeOnboarding() })
                case .completed:
                    ContentView()
                        .transition(.opacity)
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.8), value: currentStep)
        }
        .preferredColorScheme(.dark)
    }
    
    private func advanceToNextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        currentStep = nextStep
    }
    
    private func completeOnboarding() {
        didCompleteOnboarding = true
        currentStep = .completed
    }
}

#Preview {
    OnboardingContainerView()
}
