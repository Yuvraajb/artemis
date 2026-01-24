# Cursor Prompt — Build Cinematic Guided Onboarding for Artemis iOS App

## ROLE

You are a **senior iOS engineer** building a Swift Student Challenge–winning onboarding experience.

Your priorities, in order:

1. Intentional UX
2. State-driven SwiftUI architecture
3. Clean RealityKit + AR integration
4. Accessibility and performance

Avoid gimmicks. Avoid overengineering. Favor restraint and clarity.

---

## TECH STACK (NON-NEGOTIABLE)

* SwiftUI (no UIKit)
* RealityKit for 3D and AR
* AVFoundation for audio
* CoreHaptics for tactile feedback
* iOS 17+

---

## HIGH-LEVEL GOAL

Create a **60–90 second guided onboarding flow** that culminates in a single Signature Moment:

> **The user authorizes and launches Artemis.**

This onboarding must feel:

* Calm
* Cinematic
* Purposeful
* Apple-keynote-level

This is **not a tutorial**. It is a narrative introduction.

---

## ARCHITECTURE REQUIREMENTS

### Onboarding State Machine

Create an enum:

```swift
enum OnboardingStep: Int, CaseIterable {
    case arrival
    case slsReveal
    case arPlacement
    case purpose
    case authorizeLaunch
    case launchSequence
    case completed
}
```

Rules:

* Persist completion with `@AppStorage("didCompleteOnboarding")`
* Each step is a **distinct SwiftUI view**
* All transitions are explicit and animated

---

## ROOT VIEW STRUCTURE

### OnboardingContainerView

Responsibilities:

* Own `@State var currentStep: OnboardingStep`
* Switch views using `switch currentStep`
* Use transitions like:

  * `.opacity`
  * `.move(edge: .bottom)`
* No `NavigationStack`

---

## STEP-BY-STEP IMPLEMENTATION

---

## STEP 1 — ArrivalView (Emotional Hook)

### Purpose

Set tone and gravity.

### Visual

* Black background
* Slowly rotating Earth (simple RealityKit sphere or subtle animation)
* No visible buttons or UI chrome

### Text (large, centered)

* “We’re going back to the Moon.”
* After ~2 seconds: “And beyond.”

### Interaction

* Tap anywhere to continue
* Advance to `.slsReveal`

---

## STEP 2 — SLSRevealView (Scale & Presence)

### Purpose

Communicate scale and seriousness.

### Visual

* RealityKit view showing **single-piece SLS model**
* Low camera angle pointing upward
* Dim lighting that ramps up slowly

### Interaction

* User **swipes up**
* Camera animates upward to reveal full rocket

### Important

Do NOT animate the model.
Only animate:

* Camera position
* Camera field of view
* Light intensity

Advance to `.arPlacement`

---

## STEP 3 — ARPlacementView (Physical Understanding)

### Purpose

Turn AR into comprehension, not spectacle.

### Requirements

* Use RealityKit ARView
* Allow placement only once
* Lock rotation after placement
* Limit gestures

### Overlay Text

* Initial: “Place Artemis in your space.”
* After placement: “Walk back until the full rocket fits in view.”

### Rules

* No continue button until placement succeeds
* Require physical movement

Advance to `.purpose`

---

## STEP 4 — PurposeView (Why Artemis Matters)

### Purpose

Explain the mission’s significance.

### Visual

* Space background
* Earth → Moon trajectory line animation

### Text (one line per tap)

1. “Artemis is how we learn to live beyond Earth.”
2. “How we prepare for Mars.”
3. “And how we go farther than ever before.”

Advance to `.authorizeLaunch`

---

## STEP 5 — AuthorizeLaunchView (Commitment)

### Purpose

Force intentional user action.

### Visual

* SLS on launch pad
* Darkened UI
* Reduced visual noise

### Interaction (Critical)

* Press-and-hold button labeled:

```
AUTHORIZE LAUNCH
```

### Rules

* Hold duration: ~2 seconds
* Button fills progressively
* CoreHaptics feedback during hold
* Releasing early cancels

Advance to `.launchSequence`

---

## STEP 6 — LaunchSequenceView (SIGNATURE MOMENT)

### Purpose

Deliver emotional payoff.

### Sequence

1. Engine glow intensifies (light or emissive adjustment)
2. Camera tilts upward
3. Subtle screen shake
4. Deep rumble audio
5. White flash → brief blackout
6. Fade into orbital Earth view

### Text (after fade-in)

* “You’ve just launched Artemis.”
* Short pause
* “Now explore how it works.”

Advance to `.completed`

---

## STEP 7 — Completion

### Behavior

* Set `didCompleteOnboarding = true`
* Fade into main app interface

---

## ACCESSIBILITY REQUIREMENTS

* VoiceOver labels for all text
* Support Reduce Motion:

  * Replace camera moves with fades
* Support Dynamic Type

---

## PERFORMANCE RULES

* Avoid heavy shaders
* Reuse RealityKit scenes when possible
* Keep AR session minimal and focused

---

## OUTPUT EXPECTATION

Produce:

* SwiftUI view files for each onboarding step
* RealityKit helper / coordinator classes
* Clean state transitions
* Comments that explain **intent**, not obvious code

This onboarding should feel like a **promise of depth**, not a feature tour.

