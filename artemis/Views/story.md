# Artemis App — Cinematic Onboarding Storyboard

This storyboard defines the **narrative, visual composition, and technical intent** for every frame of the onboarding experience.

It is written to be consumed by an LLM or engineer and translated directly into SwiftUI + RealityKit implementation.

Tone reference: **Apple keynote opening + NASA calm authority**

---

## STORY ARC OVERVIEW

**Narrative progression:**

1. Arrival → Presence → Understanding → Purpose → Commitment → Transformation → Invitation

**Emotional curve:**

* Quiet awe → grounded scale → intellectual clarity → intention → release → wonder

---

# FRAME 01 — VOID → EARTH APPEARS

### Narrative Intent

The user arrives in silence. Space first. Ego last.

### Visual Composition

* Screen starts completely black
* Tiny stars fade in slowly (low density)
* Earth fades in at center
* Earth rotates **very slowly** (barely perceptible)

### Camera

* Fixed camera
* No parallax
* No zoom

### Text Overlay (Center, Large)

```
We’re going back to the Moon.
```

After ~2 seconds, second line fades in:

```
And beyond.
```

### Motion Rules

* Earth rotation speed: extremely low
* Text fade-in duration: ~0.6s

### Audio

* Near silence
* Very soft ambient space tone

### Interaction

* Tap anywhere advances

### Technical Notes

* SwiftUI overlay + RealityKit sphere
* No buttons visible

---

# FRAME 02 — CAMERA DESCENT → SLS EMERGES

### Narrative Intent

Reveal scale without explaining it.

### Visual Composition

* Darkness below Earth
* As camera tilts downward, SLS rocket fades in from shadow
* Rocket occupies center vertical axis

### Camera

* Low-angle perspective
* Camera slowly tilts downward
* Slight forward movement

### Lighting

* Single directional light
* Intensity ramps from 20% → 60%

### Text Overlay (Bottom, Subtle)

```
This is the most powerful rocket ever built.
```

### Interaction

* User **swipes upward**

### Motion Trigger

Swipe causes:

* Camera elevation increase
* Full rocket revealed top-to-bottom

### Technical Notes

* Do NOT animate model transforms
* Animate camera transform only

---

# FRAME 03 — FULL SLS REVEAL (STILLNESS)

### Narrative Intent

Let the scale sit. Do nothing.

### Visual Composition

* Entire SLS visible
* Rocket perfectly centered
* No motion except slight light shimmer

### Camera

* Static
* Low FOV (emphasizes height)

### Text Overlay

None

### Audio

* Silence

### Interaction

* Tap anywhere advances

---

# FRAME 04 — MODE TRANSITION → AR WORLD

### Narrative Intent

Bring the impossible into the personal.

### Visual Composition

* Rocket fades out
* Camera dissolves into AR feed

### Overlay Text (Center)

```
Place Artemis in your space.
```

### Interaction

* Tap to place rocket

### Technical Notes

* Lock rotation after placement
* Disable scale gestures

---

# FRAME 05 — AR SCALE COMPREHENSION

### Narrative Intent

Force physical understanding.

### Visual Composition

* Rocket placed in AR
* User camera begins close to rocket

### Overlay Text (Bottom)

```
Walk back until the full rocket fits in view.
```

### Rules

* No continue button
* User must physically move

### Motion

* Rocket remains static
* Environment motion driven by user movement

### Audio

* None

---

# FRAME 06 — AR FADE → SPACE TRAJECTORY

### Narrative Intent

Transition from scale to purpose.

### Visual Composition

* AR scene fades to black
* Space fades back in
* Earth appears
* Trajectory line animates Earth → Moon

### Camera

* Fixed
* Wide framing

### Text (One Line Per Tap)

1.

```
Artemis is how we learn to live beyond Earth.
```

2.

```
How we prepare for Mars.
```

3.

```
And how we go farther than ever before.
```

### Technical Notes

* Trajectory drawn using simple line animation

---

# FRAME 07 — RETURN TO LAUNCH PAD (DARKENED)

### Narrative Intent

Everything now depends on intention.

### Visual Composition

* SLS on launch pad
* Environment darker than before
* UI minimal

### Text

```
This mission requires intention.
```

Below:

```
Authorize launch.
```

---

# FRAME 08 — USER COMMITMENT (PRESS & HOLD)

### Narrative Intent

Make the user *decide*.

### Visual Composition

* Large centered button

```
AUTHORIZE LAUNCH
```

### Interaction

* Press-and-hold (~2s)

### Visual Feedback

* Circular progress fill
* Subtle pulse

### Haptics

* Low-frequency pulse during hold

### Failure Case

* Release early → reset

---

# FRAME 09 — LAUNCH SEQUENCE (SIGNATURE MOMENT)

### Narrative Intent

Release tension. Transform state.

### Visual Sequence

1. Engine glow increases
2. Camera tilts upward
3. Subtle screen shake
4. Deep rumble audio
5. White flash
6. Full blackout (0.4s)

### Technical Notes

* Emissive/light intensity only
* Camera animation only

---

# FRAME 10 — ORBITAL SILENCE

### Narrative Intent

After chaos, silence.

### Visual Composition

* Earth from orbit
* No UI

### Audio

* Silence → faint ambient tone

### Text (Center)

```
You’ve just launched Artemis.
```

Pause, then:

```
Now explore how it works.
```

---

# FRAME 11 — APP UNLOCK

### Narrative Intent

Invitation, not instruction.

### Visual Composition

* UI tabs fade in
* No animation rush

### Final Text

```
Start anywhere. Go deep.
```

### Technical Notes

* Set onboarding complete flag
* Transition to main app

---

## END STATE

The user should feel:

* Calm
* Curious
* Trusted
* Invited

This storyboard prioritizes **timing, restraint, and narrative clarity** over mechanical complexity.
