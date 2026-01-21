# Cursor Prompt — Artemis Learn Cards Stack (Apple Today Style)

> **Paste this entire prompt into Cursor**

---

## 🎯 Role

You are a **senior Apple platform engineer** who has built production-quality iOS experiences comparable to Apple’s **App Store Today tab**.

Your task is to build an **Artemis Learn Cards Stack** from scratch using **Apple-native frameworks first**, prioritizing **SwiftUI system components** and avoiding unnecessary custom gesture engines.

---

## 📱 Feature Goal

Build a **Today-tab style Learn Cards experience** with:

* Smooth vertical card stacking
* Natural scroll physics
* Subtle depth, scale, and parallax
* Tap-to-expand immersive detail views
* Zero jank, zero over-animation

This feature is for an **Artemis mission educational iOS app**.

---

## 🧠 Design Principles (Non-Negotiable)

* **Apple-first architecture**
* Prefer **SwiftUI-native APIs** over custom math
* Use system behaviors wherever possible

### Strongly Prefer:

* `ScrollView(.vertical)`
* `LazyVStack`
* `GeometryReader`
* `containerRelativeFrame`
* `scrollTransition`
* `visualEffect`
* `matchedGeometryEffect`
* `NavigationStack`

### Avoid Unless Absolutely Necessary:

* Manual `DragGesture` physics
* UIKit bridges
* Custom animation curves that fight system feel

Code should feel like something **Apple would approve internally**.

---

## 🧱 Learn Card Structure

Each Learn Card must include:

* Full-width rounded rectangle (`cornerRadius: 24–30`)
* System shadow and elevation
* Hero title (large, bold)
* Short subtitle / description
* Optional background image or gradient
* Subtle parallax on scroll

Cards must scale and slightly dim as they move off-center (Today tab behavior).

---

## 📚 Data Model

Define a `LearnCard` model containing:

* `id`
* `title`
* `subtitle`
* `themeColor`
* `imageName` (optional)
* `detailText`

Populate with **Artemis-focused content**, such as:

* Artemis II Crew
* SLS Rocket
* Orion Capsule
* Mission Timeline
* Lunar Objectives

---

## 🧩 View Architecture (Required)

### 1. `LearnCardsView`

* Hosts the vertical scroll experience
* Uses `LazyVStack(spacing: ...)`
* Applies scroll-based scaling and blur via `scrollTransition`

### 2. `LearnCardView`

* Pure UI component
* No navigation logic
* Uses `GeometryReader` for depth/parallax

### 3. `LearnCardDetailView`

* Full-screen immersive view
* Activated via tap
* Uses `matchedGeometryEffect`
* Supports vertical scroll for long content

---

## ✨ Animation & Interaction Rules

* All animations must be:

  * Subtle
  * Spring-based or default system animations
* No exaggerated easing
* Expansion should feel **organic**, not modal

Use:

* `withAnimation(.spring())`
* `matchedGeometryEffect` for seamless transitions

---

## 🧪 iOS & Quality Constraints

* Minimum target: **iOS 17+**
* Must support Dynamic Type
* Must support Dark Mode
* No layout shifts or clipped text

---

## 📦 Deliverables

Cursor should generate:

1. Full SwiftUI implementation
2. Clean file separation
3. Reusable components
4. Inline comments explaining Apple-specific decisions

---

## 🚨 Final Instruction

Do **NOT** over-engineer.
If a system API exists, **use it**.

The end result should feel like:

> “This could live inside the App Store Today tab — and nobody would question it.”

---

**Begin implementation now.**
