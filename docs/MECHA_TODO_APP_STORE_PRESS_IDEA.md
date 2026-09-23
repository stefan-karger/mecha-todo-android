# MECHA//TODO Google Play and press asset brief

Status: aligned with the design confirmed on 2026-09-23. [IDEA.md](IDEA.md) defines product behavior and [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) defines delivery and acceptance. Required work is the English Google Play package. Optional press and social concepts below are retained for future use and are outside V1 delivery.

The six phone screenshots are the selected story, not a universal Play screenshot requirement. Capture the completed native app with valid records and include both branded appearances. This brief does not certify the current skeleton, privacy behavior or unpublished support endpoints.

---

## 1. Purpose

This document defines the visual assets, screenshot plan, listing copy, metadata and acceptance criteria for the first Android release of MECHA//TODO. Separate optional sections retain ideas for later press material.

Create a launch package that:

- communicates the app within a few seconds,
- looks consistent with the in-app MECHA//TODO visual language,
- satisfies Google Play requirements,
- gives Google Play enough polished media for recommendations and store presentation,
- can be reused later for GitHub, a landing page, social posts, Product Hunt, Reddit, or press outreach,
- avoids exaggerated marketing claims,
- stays faithful to the actual product.

This brief assumes the Android version is a native **Kotlin + Jetpack Compose** port.

---

## 2. Product Positioning

### Core product idea

MECHA//TODO is a focused todo application with a lightweight progression system.

The core loop is:

```text
CAPTURE TASK
    ↓
FOCUS ON ACTIVE TASKS
    ↓
COMPLETE TASK
    ↓
EARN XP
    ↓
LEVEL / RANK PROGRESSION
    ↓
RETURN TO TASKS
```

The progression system should support the task workflow rather than overshadow it.

### Product pillars

The store material should consistently communicate these pillars:

1. **Focus**
   - Active tasks are kept visible.
   - Additional tasks can wait in Standby.
   - The user is not encouraged to build an enormous visible backlog.

2. **Progression**
   - Completing work earns XP.
   - XP contributes to levels and ranks.
   - The nine approved geometric rank badges make progression visible.

3. **Momentum**
   - LINK / COMBO mechanics add small bonuses.
   - These should feel like encouragement rather than a complicated game economy.

4. **Simplicity**
   - Fast task creation.
   - No unnecessary workflow ceremony.
   - The app should still feel like a todo app first.

5. **Device-local storage**
   - V1 has no account, cloud sync, analytics, app backup, transfer, import or export.
   - Explain the accepted risk of permanent data loss without implying recovery.
   - Verify store wording against the final release and its dependencies before submission.

---

## 3. Naming and Brand Usage

### In-app brand

Preferred visual brand:

```text
MECHA//TODO
```

Use this brand for the Android launcher label and other display contexts that permit it. The approved ready task screen has no product-name header, and the system splash contains the helmet without text. Branding does not add either element.

### Google Play listing title

Listing title under current Play metadata rules:

```text
Mecha Todo
```

The user prefers MECHA//TODO wherever allowed. Current [Play metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842?hl=en) prohibits repeated special characters in the title, so this uses the explicitly authorized plain-name fallback. Recheck the policy at submission without changing the launcher brand.

---

# 4. Launch Asset Inventory

Create the following assets before the first production submission.

## Required / primary Play Store assets

```text
play-store/
├─ icon/
│  └─ play-icon-512.png
├─ feature/
│  └─ feature-graphic-1024x500.png
├─ screenshots/
│  └─ phone/
│     ├─ 01-focus.png
│     ├─ 02-xp.png
│     ├─ 03-rank.png
│     ├─ 04-standby.png
│     ├─ 05-combo.png
│     └─ 06-privacy.png
├─ listing/
│  └─ en.md
├─ release-notes/
│  └─ 1.0.md
└─ compliance-notes/
   ├─ privacy.md
   ├─ data-safety.md
   ├─ content-rating.md
   └─ reviewer-access.md
```

## Optional future press assets, outside V1 delivery

```text
press/
├─ logo/
│  ├─ mecha-todo-logo-dark.svg
│  ├─ mecha-todo-logo-light.svg
│  ├─ helmet-mark.svg
│  └─ helmet-mark.png
├─ app-icon/
│  └─ play-icon-512.png
├─ screenshots/
│  ├─ clean/
│  └─ annotated/
├─ feature/
│  └─ feature-graphic-1024x500.png
├─ social/
│  ├─ social-square-1080x1080.png
│  └─ social-landscape-1200x630.png
├─ text/
│  ├─ one-liner.md
│  ├─ short-description.md
│  ├─ full-description.md
│  ├─ feature-list.md
│  └─ project-facts.md
└─ README.md
```

The press folder is excluded from the agreed V1 delivery. These ideas may reuse the store material if a later request includes press work.

---

# 5. Visual Direction

## General style

The store page should look like the product.

Avoid generic app-store marketing templates that introduce an unrelated visual language.

Preferred characteristics:

- JetBrains Mono typography where appropriate,
- MECHA//TODO purple + green accents,
- the approved branded light and dark palettes, with truthful captures of each,
- large but compact headlines,
- strong spacing,
- minimal decorative chrome,
- real app UI doing most of the visual work,
- no fake Pixel / Samsung device frame unless there is a very strong reason.

The screenshots should feel like extensions of the app itself.

## Screenshot composition

Preferred portrait output:

```text
1080 × 1920 px
```

General composition:

```text
┌─────────────────────────────────┐
│                                 │
│   SHORT STORE HEADLINE          │
│   SECOND LINE IF NEEDED         │
│                                 │
│   ─────────────────────         │
│                                 │
│   ACTUAL APP UI                 │
│                                 │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

Recommended:

- reserve approximately 15–20% of the top area for the headline,
- let the real app occupy the majority of the screenshot,
- keep annotations short,
- never annotate every control,
- do not use arrows/callouts unless they genuinely improve comprehension.

---

# 6. Screenshot Story

The screenshot sequence should tell one coherent story:

```text
1. THIS IS A FOCUSED TODO APP
2. COMPLETION EARNS XP
3. XP BUILDS RANKS
4. ACTIVE / STANDBY MANAGES FOCUS
5. COMBO / LINK ADDS MOMENTUM
6. YOUR TASKS STAY LOCAL
```

The first three screenshots are the most important.

A user should understand the main differentiator by screenshot 3 without reading the full store description.

---

# 7. Screenshot 01 — Core Todo Experience

## Goal

Immediately communicate:

> This is a todo app first.

Do not lead with Settings progression.

## App state

Capture the main task screen.

Recommended state:

- around 4 active tasks,
- visible task input / composer,
- XP / rank HUD visible,
- partially filled XP bar,
- no huge backlog,
- no modal,
- no settings,
- no completed-history clutter,
- Standby collapsed.

Example task data:

```text
Send project update
Book dentist appointment
Finish presentation slides
Water the plants
```

Tasks should feel realistic but generic.

## Annotation

Preferred:

```text
FOCUS ON WHAT
MATTERS NOW.
```

Alternative:

```text
YOUR TASKS.
YOUR FOCUS.
```

Preferred first option because it explains the product benefit more clearly.

## What this screenshot must communicate

- task-first design,
- focus,
- minimal friction,
- subtle progression layer.

## Alt text

```text
MECHA//TODO task screen with four active tasks, rank badge, level progress and the new-task input.
```

## Acceptance criteria

- active task list is readable,
- no placeholder names like "Task 1",
- progression is visible but secondary,
- headline does not cover important UI,
- composition works even as a small store thumbnail.

---

# 8. Screenshot 02 — Completion Reward

## Goal

Explain the core progression loop.

## App state

Capture the short moment after completing a task.

Ideal state:

- completed task remains visible briefly,
- checkmark / completion state visible,
- XP reward feedback visible,
- progress bar has visibly advanced,
- remaining active tasks still visible.

If the Android implementation uses transient feedback, create a deterministic screenshot state specifically for this asset.

Potential in-app feedback:

```text
TASK COMPLETE · +10 XP
```

Use the final in-app wording instead of inventing store-only UI.

## Annotation

Preferred:

```text
COMPLETE TASKS.
EARN XP.
```

## What this screenshot must communicate

```text
doing useful work → visible progress
```

This is the single most important product mechanic after basic task management.

## Alt text

```text
A completed task awarding XP while the level progress bar updates at the top of MECHA//TODO.
```

## Acceptance criteria

- XP reward is obvious without zooming,
- screenshot still looks like a todo app,
- no confetti or exaggerated reward treatment unless the real app has it,
- UI must reflect actual shipping behavior.

---

# 9. Screenshot 03 — Rank / Progression

## Goal

Show the most visually distinctive part of MECHA//TODO.

## App state

Open the progression section in Settings. There is no separate Progression destination.

Do not use the earliest starter rank.

Use a visually interesting mid/high rank such as:

```text
Colonel
General
Marshal
```

Choose whichever rank badge is visually strongest in the final implementation.

Show:

- large rank badge,
- rank name,
- current level,
- lifetime XP,
- the next named milestone shown by the actual Settings interface.

## Annotation

Preferred:

```text
LEVEL UP.
RANK UP.
```

Alternative:

```text
TURN PROGRESS
INTO RANK.
```

Use the first unless the second fits the brand better.

## What this screenshot must communicate

- progression is persistent,
- the badge system is unique,
- levels have visible meaning.

## Alt text

```text
Settings progression section showing an approved rank badge, current rank, level, Lifetime XP and the next named milestone.
```

## Acceptance criteria

- badge is large enough to be visually compelling,
- no badge is used that is not actually obtainable,
- rank terminology matches the shipped app,
- no visual mock that misrepresents the in-app appearance.

---

# 10. Screenshot 04 — Active / Standby

## Goal

Explain the focus-management model.

## App state

Main task screen with:

- Active section visibly full or nearly full,
- e.g. `8 / 8`,
- Standby expanded,
- 3–4 additional tasks visible,
- visual separation between Active and Standby.

Example:

### Active

```text
Send project update
Order printer ink
Book dentist appointment
Finish presentation slides
Water the plants
...
```

### Standby

```text
Sort photos from the weekend
Clean up downloads folder
Replace bike brake pads
Read saved article
```

## Annotation

Preferred:

```text
ACTIVE NOW.
STANDBY LATER.
```

## What this screenshot must communicate

MECHA//TODO does not require all tasks to compete for attention at once.

## Alt text

```text
Active task list at capacity with additional tasks organised in the expanded Standby section below.
```

## Acceptance criteria

- Active and Standby distinction is obvious,
- enough tasks exist to demonstrate the mechanic,
- screen does not look overloaded,
- Standby appears intentionally secondary.

---

# 11. Screenshot 05 — LINK / COMBO Momentum

## Goal

Show the lightweight bonus mechanic without making the app look like a game pretending to be a todo app.

## App state

Create a seeded state with visible momentum.

Preferred:

```text
COMBO 4/5
```

or an equivalent actual UI state.

If LINK is easier to understand visually, use a LINK-ready state instead.

Preferred priority:

1. COMBO if the UI is obvious,
2. LINK if the COMBO visual is too subtle.

## Annotation

Preferred:

```text
A LITTLE MOMENTUM
GOES A LONG WAY.
```

Alternative:

```text
BUILD MOMENTUM.
KEEP MOVING.
```

## What this screenshot must communicate

- consecutive action is rewarded,
- the mechanic is small and supportive,
- the user does not need to manage a complicated RPG system.

## Alt text

```text
Task screen showing COMBO progress in the reward HUD while the user works through active tasks.
```

## Acceptance criteria

- mechanic is understandable from the visual,
- annotation explains the benefit rather than rules,
- do not include a wall of mechanic descriptions,
- use actual in-app values.

---

# 12. Screenshot 06 — Privacy / Local Storage

## Goal

Finish with a trust signal.

Only use this screenshot if the final Android app genuinely stores its task data locally and does not sync it to a server.

## App state

Settings / About / Data screen showing:

- device-local storage explanation,
- no account requirement if true,
- privacy wording,
- optional erase/reset control lower down.

Avoid making destructive controls the central object.

## Annotation

Preferred:

```text
YOUR TASKS STAY
ON YOUR DEVICE.
```

Alternative:

```text
LOCAL BY DEFAULT.
```

## Required Android wording change

Do not retain web-specific wording such as:

```text
Browser-local data
```

Use:

```text
Device-local data
```

or another implementation-accurate equivalent.

## Alt text

```text
Settings screen explaining that MECHA//TODO stores tasks locally on the Android device.
```

## Acceptance criteria

- claim matches the final architecture,
- no cloud/privacy claim is made if analytics, remote sync, crash tooling, or accounts materially change the behavior,
- text is readable,
- screen closes the sequence calmly.

---

# 13. Screenshot Order

Use this order:

```text
01 Focus
02 XP
03 Rank
04 Active / Standby
05 Momentum
06 Privacy
```

Do not move the progression screenshot to position 1.

The intended interpretation is:

```text
"Okay, todo app."
        ↓
"Oh, I earn XP."
        ↓
"Ah, there are levels/ranks."
        ↓
"Standby keeps it manageable."
        ↓
"There are small bonuses."
        ↓
"And my tasks remain local."
```

---

# 14. Screenshots Not Worth a Dedicated Store Slot

Do not dedicate a main Play Store screenshot to:

- edit task,
- delete task,
- undo,
- app version,
- debug information,
- generic settings,
- completed history alone,
- empty states,
- confirmation dialogs,
- data reset,
- purely decorative logo screens.

These can exist in the app and in documentation, but they do not answer:

> Why should somebody install MECHA//TODO?

---

# 15. Screenshot Annotation Copy

Preferred final set:

```text
01  FOCUS ON WHAT MATTERS NOW.

02  COMPLETE TASKS.
    EARN XP.

03  LEVEL UP.
    RANK UP.

04  ACTIVE NOW.
    STANDBY LATER.

05  A LITTLE MOMENTUM
    GOES A LONG WAY.

06  YOUR TASKS STAY
    ON YOUR DEVICE.
```

Tone:

- direct,
- compact,
- confident,
- no hype,
- no claims like "best",
- no download commands,
- no fake awards,
- no medical promises.

---

# 16. Screenshot Alt Text

Use unique alt text for every Play screenshot.

Recommended set:

### 01

```text
MECHA//TODO task screen with four active tasks, rank badge, level progress and the new-task input.
```

### 02

```text
A completed task awarding XP while the level progress bar updates at the top of MECHA//TODO.
```

### 03

```text
Settings progression section showing an approved rank badge, current rank, level, Lifetime XP and the next named milestone.
```

### 04

```text
Active task list at capacity with additional tasks organised in the expanded Standby section below.
```

### 05

```text
Task screen showing COMBO progress in the reward HUD while the user works through active tasks.
```

### 06

```text
Settings screen explaining that MECHA//TODO stores tasks locally on the Android device.
```

Keep each alt text concise and descriptive.

Avoid phrases like:

```text
Image of...
Screenshot of...
Beautiful screenshot showing...
```

---

# 17. Seed Data for Store Screenshots

Create deterministic screenshot seed data in the Android app or test fixtures.

Suggested tasks:

```text
Send project update
Book dentist appointment
Finish presentation slides
Water the plants
Order printer ink
Sort photos from the weekend
Clean up downloads folder
Replace bike brake pads
Read saved article
Plan next week's workouts
```

Rules:

- avoid private names,
- avoid brand names,
- avoid lorem ipsum,
- avoid "test task",
- avoid joke tasks,
- avoid political/religious/medical subjects,
- keep task length representative of real usage,
- mix work and everyday tasks.

The seeded local dataset should also provide:

```text
Rank: visually interesting mid/high rank
Level: enough to show progression
XP: partially filled progress bar
Combo: e.g. 4/5
Active: around 4 tasks for screenshot 1
Active: near/full capacity for screenshot 4
Standby: 3–4 tasks
```

---

# 18. Play Store App Icon

## File

```text
play-icon-512.png
```

## Dimensions

```text
512 × 512 px
```

## Direction

Use the MECHA helmet mark as the primary focal object.

The icon should:

- remain recognizable at very small sizes,
- preserve the purple / green identity,
- avoid tiny line detail,
- avoid embedding text,
- avoid adding a fake Android rounded-square mask,
- avoid a large black border around the actual icon artwork.

The icon should feel related to the in-app helmet/rank language.

---

# 19. Feature Graphic

## File

```text
feature-graphic-1024x500.png
```

## Dimensions

```text
1024 × 500 px
```

## Concept

The feature graphic should establish the brand and complement the adjacent Play icon. Use a distinct composition with a truthful native UI crop or approved badge geometry; do not enlarge the listing icon as the entire graphic.

Suggested layout:

```text
[ helmet / badge visual ]   MECHA//TODO
                            TASK CONTROL SYSTEM
```

Optional supporting line:

```text
PLAN · EXECUTE · COMPLETE · REPEAT
```

Only use this if it remains legible and does not clutter the graphic.

The feature graphic should not try to explain every product feature.

### Preferred visual hierarchy

1. helmet/logo,
2. MECHA//TODO,
3. optional small descriptor,
4. subtle HUD / technical detail.

Avoid:

- screenshot collages,
- tiny UI mockups,
- fake ratings,
- "DOWNLOAD NOW",
- "NEW",
- device frames,
- excessive copy.

---

# 20. Short Description

## Purpose

Communicate the product and its differentiator within one short sentence.

The short description should contain:

```text
todo / task concept
+
focus
+
light progression
```

Do not try to mention every mechanic.

## Recommended draft

```text
A focused todo list with XP, ranks and badges for getting things done.
```

## Alternative

```text
Turn everyday tasks into XP, ranks and progress.
```

### Recommendation

Prefer the first for launch because it explicitly contains:

```text
todo list
```

which helps users understand the product immediately.

---

# 21. Full Description Concept

## Tone

The full description should be:

- concise,
- product-focused,
- not corporate,
- not overly game-like,
- not stuffed with keywords,
- factual,
- clear about privacy/storage behavior.

Recommended length:

```text
~700–1200 characters
```

There is no benefit in filling the entire Play Store limit.

## Recommended structure

### Opening

Explain the product in one sentence.

```text
MECHA//TODO is a focused todo list with a lightweight progression system.
```

### Core loop

```text
Add the things you actually need to do, complete them, earn XP once, and move on with your day.
```

### Focus system

Explain Active / Standby.

### Progression

Explain XP, levels, ranks, and badges.

### Momentum

Briefly explain LINK / COMBO.

### Features

Use a short feature list.

### Privacy / account model

Only state what is true for the shipping Android version.

---

# 22. Full Description — Draft Direction

A starting draft for the agent:

```text
MECHA//TODO is a focused todo list with a lightweight progression system.

Add the things you actually need to do, complete them, earn XP once, and move on with your day.

Your current tasks stay in the Active while extra tasks wait in Standby, keeping the main list manageable. Completing tasks builds XP, levels and ranks, with distinctive rank badges marking your progress.

LINK and COMBO bonuses add a little extra momentum without turning your task list into another system you have to maintain.

Designed for focus:

• Fast one-line tasks
• Focused Active and Standby lists
• XP and level progression
• Ranks and geometric rank badges
• Lightweight LINK and COMBO bonuses
• Completed-task history
• Device-local storage
• No account required

MECHA//TODO is designed to be ADHD-friendly, but it is a productivity tool rather than a medical or treatment app.
```

## Important implementation check

Before publishing, verify every claim.

Especially:

```text
Device-local storage
No account required
No cloud sync
No analytics
ADHD-friendly wording
```

If the Android version changes any of these assumptions, update the store copy.

---

# 23. Initial Release Notes

## Purpose

Release notes describe what changed.

They should not read like advertising copy.

## Recommended V1 release note

```text
Initial Android release.

Includes task management, Active and Standby lists, XP progression, ranks, rank badges, LINK and COMBO bonuses, and device-local storage.
```

## Alternative more human version

```text
Initial Android release of MECHA//TODO.

Add and manage tasks, earn XP for completed work, progress through levels and ranks, and keep extra tasks organised in Standby.
```

Prefer the first for a concise technical release log.

---

# 24. One-Liner / Press Description

This optional future press section can reuse the English store description. It creates no additional V1 deliverable.

Recommended:

```text
A focused todo list with XP, ranks and badges for getting things done.
```

---

# 25. Reusable Feature List

Use a consistent feature list across press material.

```text
- Fast task capture
- Active and Standby task organisation
- XP for completed work
- Level progression
- Rank progression
- Approved geometric rank badges
- LINK bonuses
- COMBO bonuses
- Completed-task history
- Device-local task storage
- Native Android UI
```

Remove or modify any item that does not ship in the initial Android version.

---

# 26. Press Kit Project Facts

These settled facts can be reused in the store package or a later press kit:

```text
Store title: Mecha Todo
Brand: MECHA//TODO
Launcher label: MECHA//TODO
Platform: Android
Framework: Kotlin + Jetpack Compose
Category: Productivity
Developer: Stefan Karger
Application ID: stefankarger.mechatodo
Launch version: 1.0
Initial versionCode: 1
Pricing: Free, no purchases
Ads: None
Account required: No
Cloud sync: No
Data model: App-private device-local storage, no app backup or transfer
Language: English interface and store material
Audience: Teenagers and adults, ages 13 and up
Publisher website: https://stefan-karger.de
Support email: mecha-todo@stefan-karger.de
Privacy policy: https://stefan-karger.de/mecha-todo/privacy
```

The owner must activate the support alias and publish the policy before submission. These addresses are agreed destinations, not a claim that they are live. No marketing website or public native source repository is required.

---

# 27. Press / Launch Screenshots

Keep two screenshot variants.

## Clean screenshots

Pure app UI, no marketing annotation.

Use for:

- GitHub README,
- documentation,
- blog articles,
- press requests,
- product pages.

## Annotated screenshots

The six Play Store screenshots defined above.

Use for:

- Google Play,
- social launch posts,
- launch threads,
- Product Hunt-style galleries.

This avoids needing to recreate assets later.

---

# 28. Optional Social Assets

Outside the agreed V1 delivery. The following concepts are available only for a later social-assets request.

## Square

```text
1080 × 1080
```

Concept:

```text
MECHA//TODO
helmet mark
one strong UI crop
"Focused tasks. Visible progress."
```

## Landscape share card

```text
1200 × 630
```

Concept:

```text
helmet + MECHA//TODO + one UI crop
```

Avoid loading the card with feature lists.

---

# 29. Language Strategy

Ship English-only interface, listing text, screenshots and release notes. Multilingual user-entered task text remains supported. Translation is outside V1 delivery.

### English annotation set

```text
FOCUS ON WHAT MATTERS NOW.
COMPLETE TASKS. EARN XP.
LEVEL UP. RANK UP.
ACTIVE NOW. STANDBY LATER.
A LITTLE MOMENTUM GOES A LONG WAY.
YOUR TASKS STAY ON YOUR DEVICE.
```

---

# 30. What Not to Claim

Avoid claims such as:

```text
Best todo app
#1 productivity app
Guaranteed focus
Boost productivity by X%
Treats ADHD
Improves ADHD
Scientifically proven
Never procrastinate again
Life-changing
```

The app can be described as:

```text
focused
ADHD-friendly
lightweight
device-local
gamified
progression-based
```

provided the wording remains descriptive and matches the product.

Do not imply medical treatment.

---

# 31. Android-Port-Specific Copy Checks

Before producing final assets, audit the Android UI for leftover web terminology.

Search for terms such as:

```text
browser
localStorage
web
PWA
install app
browser storage
desktop app
```

Replace with platform-appropriate language where needed.

Examples:

```text
Browser-local data
→ Device-local data

Install PWA
→ remove

Open in browser
→ remove or replace
```

Store screenshots must show the final native Android terminology.

---

# 32. Screenshot Production Workflow

Recommended process:

```text
1. Implement final visual Android UI.
2. Create deterministic screenshot seed data.
3. Add a development-only screenshot scenario helper if useful.
4. Set emulator/device to a fixed resolution.
5. Disable debug banners / developer overlays.
6. Set time, battery and system bars consistently.
7. Capture clean screenshots.
8. Keep untouched originals.
9. Create annotated copies.
10. Export PNG.
11. Check readability at small thumbnail size.
12. Verify all visible features exist in the production build.
```

Do not manually Photoshop app UI elements into screenshots.

Annotations around the UI are fine; fabricated in-app UI is not.

---

# 33. Suggested Screenshot Test Fixture

If useful, create a development-only fixture such as:

```text
StoreScreenshotScenario
```

Possible states:

```text
FOCUS
COMPLETION_REWARD
PROGRESSION
ACTIVE_STANDBY
COMBO
PRIVACY
```

Each scenario should preload deterministic data.

This makes it easy to recreate assets after future UI redesigns.

The fixture must never be exposed in production UI.

---

# 34. Asset Naming Convention

Use predictable names.

```text
play-icon-512.png
feature-graphic-1024x500.png

01-focus-1080x1920.png
02-xp-1080x1920.png
03-rank-1080x1920.png
04-standby-1080x1920.png
05-combo-1080x1920.png
06-privacy-1080x1920.png
```

Use the English screenshot set:

```text
en/
```

Example:

```text
screenshots/
└─ en/
   ├─ 01-focus.png
   └─ ...
```

---

# 35. Recommended Repository Placement

Do not put large marketing assets into Android runtime resources.

Use the implementation plan's output location:

```text
docs/release-assets/1.0/
├─ play-store/
├─ captures/
│  ├─ clean/
│  └─ annotated/
└─ manifest.md

app/src/main/res/
├─ drawable/
├─ mipmap-*/
└─ ...
```

Store marketing assets belong in a documentation / release-assets area, not in `app/src/main/res` unless the app itself uses them.

---

# 36. Agent Tasks

The agent receiving this handoff should:

1. inspect the current MECHA//TODO Android implementation,
2. verify which documented features actually ship in V1,
3. verify the exact rank names and progression UI,
4. verify whether storage is fully device-local,
5. verify whether any analytics, crash reporting, sync, accounts or remote services exist,
6. create deterministic screenshot seed states,
7. capture the six clean screenshots,
8. create annotated versions using this brief,
9. export final Play Store graphics,
10. prepare English listing copy,
11. verify both branded light and dark presentation,
12. prepare initial release notes,
13. align privacy and support copy with the approved endpoints and verified release,
14. validate that every visible screenshot state can actually occur in production,
15. keep all reusable source assets separate from Android runtime resources.

---

# 37. Acceptance Criteria

The required Play package is complete when the screenshot, store-graphics and text checks below pass alongside the implementation plan's release gates. The optional press list is excluded from V1 acceptance.

## Screenshots

- [ ] Six portrait screenshots exist.
- [ ] Every screenshot uses real application UI.
- [ ] The screenshots form the intended narrative.
- [ ] All screenshots use consistent layout and typography.
- [ ] All annotations are readable.
- [ ] Screenshot records are valid deterministic data; no developer controls or impossible states appear.
- [ ] The first screenshot clearly looks like a todo app.
- [ ] Screenshot 2 clearly shows XP reward.
- [ ] Screenshot 3 clearly shows rank progression.
- [ ] Screenshot 4 clearly shows Active / Standby.
- [ ] Screenshot 5 clearly shows LINK or COMBO momentum.
- [ ] Screenshot 6 only claims device-local storage if true.

## Store graphics

- [ ] 512×512 Play Store icon exists.
- [ ] 1024×500 feature graphic exists.
- [ ] No fake device-frame dependency is required.
- [ ] All exported assets look correct at reduced thumbnail size.

## Text

- [ ] App title is finalized.
- [ ] Short description is finalized.
- [ ] Full description is finalized.
- [ ] Initial release notes are finalized.
- [ ] Screenshot alt text exists.
- [ ] English copy has been proofread.
- [ ] All release copy is English, matching the approved V1 language scope.
- [ ] Privacy wording matches the actual application.

## Optional future press package, excluded from V1 acceptance

- [ ] Clean logo assets exist.
- [ ] Clean screenshots exist.
- [ ] Annotated screenshots exist.
- [ ] One-liner exists.
- [ ] Feature list exists.
- [ ] Project facts file exists.
- [ ] Social assets exist or are explicitly deferred.

---

# 38. Final Recommended Store Narrative

The Play listing should communicate this sequence:

```text
MECHA//TODO
    ↓
a focused todo app
    ↓
complete useful tasks
    ↓
earn XP
    ↓
build levels and ranks
    ↓
use Active / Standby to avoid clutter
    ↓
use small LINK / COMBO bonuses for momentum
    ↓
keep the experience simple and local
```

The app must always remain recognizable as a useful todo tool.

The gamification is the differentiator.

It is not the product itself.

---

# 39. Locked First-Pass Copy

Unless implementation changes require edits, use these as the first asset-production targets.

## Play title

```text
Mecha Todo
```

## Short description

```text
A focused todo list with XP, ranks and badges for getting things done.
```

## Screenshot annotations

```text
FOCUS ON WHAT MATTERS NOW.

COMPLETE TASKS.
EARN XP.

LEVEL UP.
RANK UP.

ACTIVE NOW.
STANDBY LATER.

A LITTLE MOMENTUM
GOES A LONG WAY.

YOUR TASKS STAY
ON YOUR DEVICE.
```

## Initial release note

```text
Initial Android release.

Includes task management, Active and Standby lists, XP progression, ranks, rank badges, LINK and COMBO bonuses, and device-local storage.
```

---

# 40. Final Principle

Every store asset should pass one test:

> Does this help a new user understand why MECHA//TODO is different while still showing the app truthfully?

If not, remove it.

The strongest launch package is not the one with the most marketing material.

It is the one where the icon, screenshots, description, UI, progression system and privacy story all feel like the same product.
