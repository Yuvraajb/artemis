# Artemis iOS App Requirements

## Feature: 3D & AR Models Tab (Orion + SLS)

## remember our goal is to to build an app that stands out in the student swift code challenge 

---

## 1. Feature Overview

This document defines the **initial scope** for the Artemis iOS app, focusing exclusively on a single tab that delivers **high‑quality 3D and AR visualization** of NASA hardware. The goal is to create a polished, realistic, and intuitive experience that allows users to explore the **Orion spacecraft** and the **Space Launch System (SLS) rocket**.

This is the foundation feature. All future features will build on top of this.

---

## 2. Platform & Technical Stack

**Target Platform**

* iOS 17+
* iPhone and iPad

**Primary Technologies**

* Swift
* SwiftUI
* RealityKit (preferred over SceneKit)
* ARKit
* USDZ 3D model format

**Rendering & Performance**

* RealityKit rendering pipeline
* Metal via RealityKit (no custom shaders in this phase)
* Optimized for smooth 60 FPS interaction

---

## 3. App Navigation & Tab Placement

**Tab Name**

* `3D Models`

**Tab Purpose**

* Serve as the central hub for all spacecraft and rocket visualizations

**Navigation Structure**

```
3D Models Tab
 ├── Model Selection Screen
 │    ├── Orion Spacecraft
 │    └── SLS Rocket
 └── Model Viewer Screen
      ├── 3D Viewer Mode
      └── AR Placement Mode
```

---

## 4. Model Selection Screen

**Purpose**
Allow users to choose which vehicle they want to explore.

**UI Requirements**

* Dark‑mode first design
* Two large, tappable cards:

  * Orion Spacecraft
  * SLS Rocket
* Each card includes:

  * Vehicle name
  * High‑quality thumbnail render

**Behavior**

* Tapping a card opens the Model Viewer screen
* No scrolling required on standard devices

---

## 5. Model Viewer Screen

### 5.1 Default Mode: 3D Viewer

**Core Features**

* Full 3D model rendered on a neutral dark background
* Touch interactions:

  * One‑finger drag → rotate
  * Pinch → zoom
  * Two‑finger drag → pan

**Camera Controls**

* Auto‑centered model on load
* Reset camera button

**UI Elements**

* Vehicle name at top
* Mode toggle button (3D ↔ AR)
* Reset view button

---

### 5.2 AR Mode

**Activation**

* User taps “View in AR” button

**AR Behavior**

* Plane detection (horizontal surfaces)
* Model placement preview before confirmation
* Tap to place the model in real space

**Post‑Placement Interactions**

* Drag → reposition
* Pinch → scale
* Rotate gesture → rotate model

**Environment**

* Real‑world lighting estimation enabled
* Shadows enabled for realism

---

## 6. 3D Model Requirements

**Models Included (Phase 1)**

* Orion Spacecraft
* Space Launch System (SLS) Rocket

**Model Specifications**

* Format: USDZ
* High‑detail geometry with optimized polygon count
* Realistic textures (PBR where possible)
* Correct real‑world proportions

**Performance Constraints**

* Fast load time
* No frame drops during interaction

---

## 7. Non‑Goals (Explicitly Out of Scope)

The following are intentionally excluded from this phase:

* Animations (launch, staging, etc.)
* Internal cutaway views
* Educational text overlays
* Audio or narration
* Mission timelines

These will be added in future iterations.

---

## 8. Quality Bar

This feature should feel:

* Professional
* Museum‑grade
* Stable and bug‑free

Completion and polish matter more than feature count.

---

## 9. Future Expansion Hooks (Not Implemented Yet)

This architecture must support later additions such as:

* Exploded views
* Component labels
* Mission simulations
* Artemis II / III timelines
* Interactive training scenarios

---

**End of Phase 1 Requirements**


##phase 2
# Cursor Prompt – Phase 2: Interactive Info Tab (Artemis App)

## Role

You are a **senior iOS engineer and motion designer** building a production-quality SwiftUI feature for a student-led space education app inspired by NASA’s Artemis missions.

You are precise, minimal, and opinionated. You prioritize clean UX, smooth animations, and clarity over complexity.

---

## Feature Context

This feature is a **separate tab** in the app called:

> **“Learn Artemis”**

This tab is **not** a simulator and **not** a settings screen.
It is a **dedicated interactive learning experience** where users swipe, tap, and explore to understand the Artemis mission.

---

## High-Level Objective

Build a **Tinder-style swipeable card interface** that teaches users about the Artemis mission through interaction rather than text-heavy explanations.

This tab should:

* Feel playful but credible
* Encourage exploration
* Make users want to keep swiping
* Work smoothly on real devices

---

## Technical Constraints

* Platform: iOS
* Framework: SwiftUI only
* Architecture: Light MVVM (no coordinators, no overengineering)
* Animations: Native SwiftUI animations
* External dependencies: None

---

## Tab Integration Requirements

* This feature must live inside its **own TabView tab**
* Tab icon: SF Symbol suggestion: `sparkles`, `moon.stars`, or `rectangle.stack`
* Tab title: **Learn** or **Artemis**

---

## Core Feature: Swipeable Info Cards

### Functional Requirements

* Cards are displayed in a stacked layout
* Only the top card is interactive
* Users can drag cards left or right
* Card rotates slightly based on drag distance
* If drag exceeds a threshold, card animates off screen
* If drag does not exceed threshold, card snaps back
* When a card is dismissed, the next card animates forward

### Animation Requirements

* Use spring animations
* Motion must feel natural and responsive
* Rotation should be subtle and proportional
* No jitter, lag, or abrupt transitions

---

## Card Interaction Requirements

### Tap-to-Flip

* Tapping a card flips it horizontally (3D rotation on Y-axis)
* Front and back are separate SwiftUI views
* Flip animation must feel physical

### Long Press

* Long press toggles a simplified explanation mode
* Content switches to short, plain-language text

---

## Card Content Structure

Each card represents **one concept**.

### Front of Card

* Title (large, bold)
* Optional image or illustration
* One-sentence explanation

### Back of Card

* Expanded explanation (still concise)
* Bullet points preferred over paragraphs

---

## Data Modeling

Create a clean, extensible data model for cards.

Each card should support:

* id
* title
* shortDescription
* detailedDescription
* simplifiedDescription
* optional image name
* category (overview, timeline, systems, crew)

---

## Initial Card Set (Phase 2 Scope)

Implement cards for the following topics:

1. What is Artemis II?
2. Why Artemis exists
3. Artemis mission timeline
4. Orion spacecraft overview
5. Space Launch System (SLS)

Use placeholder images and text where needed.

---

## UX Expectations

* Cards should feel tactile
* Transitions should guide the eye
* Content should never overwhelm the user
* No scroll views inside cards
* No dense text blocks

---

## Code Quality Expectations

* Use reusable views
* Keep gesture logic isolated
* Comment complex animation logic
* Avoid magic numbers (use constants)

---

## Output Expectation

Produce:

* A SwiftUI view for the Learn Artemis tab
* A swipeable card stack component
* A card view with flip animation
* A simple view model supplying mock data

The result should be **drop-in usable**, cleanly structured, and easy to extend in Phase 3.

---

## Tone & Style Guidance

* Clean
* Modern
* Subtle NASA-inspired feel
* No cartoonish UI

Build this as if it will be reviewed by engineers and designers.

Start with the core swipe interaction, then layer in flip and long-press behavior.
**end of phase 2**

**phase 3**
# Cursor Prompt – Phase 3: Astronaut Chat (Text-Only, Core ML)

## Role

You are a **senior iOS engineer with ML experience** building a production-ready, text-only chat feature using **Core ML** for an educational space app.

You are pragmatic and opinionated. You favor correctness, performance, and clear UX over gimmicks.

---

## Feature Context

This is a **new, separate tab** in the app called:

> **“Crew Chat”**

This tab allows users to **select an astronaut and chat with a simulated AI persona** based on that astronaut’s public background and mission role.

Important: This is a **simulation**, not impersonation.

---

## High-Level Objective

Build a **text-only astronaut chat system** that:

* Runs primarily on-device using Core ML
* Lets users choose an astronaut via image cards
* Opens a scoped chat session per astronaut
* Produces responses aligned with each astronaut’s public persona
* Is easy to extend with more astronauts later

No voice, no audio, no speech synthesis.

---

## Legal & Safety Requirements (Non-Negotiable)

* The UI must clearly label chats as **“Simulated persona based on public information”**
* The model must never claim to literally be the real astronaut
* No private or non-public information may be used
* Responses must stay within known public facts

---

## Technical Constraints

* Platform: iOS
* UI Framework: SwiftUI
* ML Runtime: Core ML
* Architecture: Light MVVM
* External dependencies: None required

---

## Core Feature Flow

1. User opens **Crew Chat** tab
2. User sees a grid/list of astronaut cards (image + name)
3. User taps an astronaut
4. A chat screen opens scoped to that astronaut
5. User types a question
6. App generates a response using:

   * Astronaut-specific persona prompt
   * Public-data context
   * Core ML LLM inference

---

## Astronaut Selection UI

### Requirements

* Grid or vertical list of astronaut cards
* Each card includes:

  * Portrait image
  * Name
  * Short role tagline (e.g. “Mission Commander – Artemis II”)

### Interaction

* Tap card → navigates to chat view

---

## Chat UI Requirements

### Layout

* Header with astronaut image + name
* Subtitle: “Simulated persona — educational use only”
* Scrollable chat transcript
* User messages on right
* Astronaut messages on left
* Text input bar at bottom

### UX Rules

* No typing lag
* Loading indicator while model generates
* Auto-scroll to newest message

---

## Persona Modeling Strategy (Required)

Do **NOT** fine-tune a model per astronaut.

Instead, use **persona prompting + retrieval-augmented context**.

### Persona Prompt Must Include

* Tone and communication style
* Professional role (pilot, commander, engineer, etc.)
* Knowledge boundaries
* Explicit rule: do not claim to be the real person

Example instruction conceptually:

> “You are a simulated educational persona inspired by a NASA astronaut’s public career. Speak clearly, technically when appropriate, and stay grounded in public information only.”

---

## Data Sources

Each astronaut has a **local public-info corpus**:

* NASA biography text
* Public interviews / Q&A
* Mission descriptions

These are stored as **plain text files** in the app bundle or downloaded once and cached.

---

## Retrieval + Generation Pipeline

1. User submits message
2. App retrieves relevant astronaut documents using embeddings
3. Build system prompt:

   * Persona prompt
   * Retrieved public context
4. Send prompt to Core ML LLM
5. Render model output in chat

---

## Core ML Requirements

### Model

* Use a **small-to-medium LLM** optimized for on-device inference
* Model must be loaded via Core ML
* Responses must be generated synchronously or with async task handling

### Abstraction

Create a reusable wrapper:

* `LLMManager`

  * loadModel()
  * generateResponse(prompt:)

---

## Data Models

```swift
struct Astronaut {
  let id: String
  let name: String
  let imageName: String
  let roleTagline: String
  let personaPrompt: String
  let corpusFiles: [String]
}

struct ChatMessage {
  let id: UUID
  let sender: Sender
  let text: String
  let timestamp: Date
}
```

---

## Cursor Prompt — Build Order

### Step 1: Astronaut Selector

> “Build a SwiftUI `CrewChatHomeView` that displays a grid of astronaut cards. Tapping a card navigates to a chat view and passes the selected astronaut model.”

### Step 2: Chat UI

> “Create a SwiftUI chat interface with left/right message bubbles, auto-scrolling, and a text input bar. Use mock responses for now.”

### Step 3: Persona Prompt Injection

> “Add support for astronaut-specific system prompts. Ensure the prompt includes a disclaimer that the persona is simulated and based on public information.”

### Step 4: Core ML Integration

> “Integrate a Core ML LLM via an `LLMManager` class. Replace mock responses with model-generated text.”

### Step 5: Retrieval Context (Optional in Phase 3)

> “Add simple keyword-based or embedding-based document retrieval to inject relevant public context into the prompt.”

---

## UX & Product Principles

* Educational first, not role-play fantasy
* Concise, informative answers
* No hallucinated personal stories
* Clear simulation labeling at all times

---

## Phase 3 Deliverables

* Crew Chat tab
* Astronaut selection screen
* Text-only chat per astronaut
* Core ML text generation pipeline
* Persona prompt system
* Mock or real public data corpus

---

## Phase 4 Preview (Not Implemented Now)

* Voice
* AR presence
* Multi-turn memory tuning
* Mission-specific chat modes

---

## Success Criteria

Phase 3 is successful if:

* Users can clearly choose an astronaut
* Chats feel distinct per astronaut
* Responses are fast, grounded, and educational
* Feature runs reliably on real devices

Build this cleanly and extensibly so future phases layer on to
**end of phase 3**