# MECHA//TODO native Android specification

Status: approved by the user on 2026-09-23 after questions Q1 through Q30 and final shared-understanding confirmation. The [decision log](../.scratch/native-v1-design/decision-log.md) records the interview. The [implementation plan](IMPLEMENTATION_PLAN.md) defines the work and acceptance gates. Application implementation has not started; the Android application remains a skeleton.

Build one native Android application with Kotlin, Jetpack Compose, and Room. Preserve Web V1's task and progression behavior, with the explicit Android differences recorded here. Use one app module, one screen ViewModel, one concrete repository, a small Room database, and pure Kotlin functions for the rules.

Section 13 records the settled decisions. The deliverable includes a tested native application and Google Play submission readiness. Account registration, identity verification, the closed test, policy hosting, and store review are explicit release tasks. Actual publication is separate. Optional press campaigns and social media assets are outside this work.

## 1. Evidence and current project

The product authority is [Web V1 CONTEXT.md](../_reference/mecha-todo/CONTEXT.md). Algorithms and tests refine that contract. [AGENTS.md](../AGENTS.md) requires native Android implementation and protects the reference checkout. [KISS_GUIDELINES.md](KISS_GUIDELINES.md) governs architecture. The [store and press brief](MECHA_TODO_APP_STORE_PRESS_IDEA.md) supplies creative guidance within the scope settled here.

Reference revision inspected: d2c3f09a7222e1ae6e15cf327135dc93c7876f7f, dated 2026-09-21. Web V1 is implemented; its context still says production deployment is pending.

| Area | Evidence inspected |
| --- | --- |
| Rules | [rules-v1.ts](../_reference/mecha-todo/src/config/rules-v1.ts), all files in [domain](../_reference/mecha-todo/src/domain/), and the corresponding domain tests |
| Storage | [models.ts](../_reference/mecha-todo/src/persistence/models.ts), schemas, validation, migrations, database opening, startup, composer draft, and [repository.ts](../_reference/mecha-todo/src/persistence/repository.ts) |
| Interaction | [App.tsx](../_reference/mecha-todo/src/app/App.tsx), SettingsDialog, delete-undo, dialog-focus, ProgressionIdentity, and app.css |
| Badges | [badge-geometry.ts](../_reference/mecha-todo/src/app/badge-geometry.ts), RankBadge, badge descriptors, renderer snapshots, and identity tests |
| Acceptance | Every domain test file, repository and UI test scenarios, [release-checklist.md](../_reference/mecha-todo/docs/release-checklist.md), and production audit script |
| Android identity | [launcher assets](assets/appicon/README.md), [splash assets](assets/splash/README.md), vector resource templates, original helmet artwork, and Play icon |
| Native starting point | Gradle configuration, manifest, MainActivity, theme, backup rules, resources, and example tests |

The Android project has one :app module and package/application ID stefankarger.mechatodo. It declares minSdk 26, compileSdk 37, targetSdk 37, versionCode 1, and versionName 1.0. It uses AGP 9.4.1, Gradle 9.6.0, Kotlin Compose plugin 2.2.10, and Compose BOM 2026.02.01. The daemon toolchain is Java 25; application Java compatibility is 11. These are different settings with different purposes.

MainActivity enables edge-to-edge and renders "Hello Android!". The theme still uses template purple colors, system light/dark selection, and dynamic color. The manifest enables backup and points to effectively empty example backup rules. Launcher artwork is still the Android template. Room, a product ViewModel, application repository, SplashScreen integration, and product tests do not exist. Some independently versioned AndroidX dependencies are much older than the BOM. Select compatible stable versions when adding the required libraries; do not change the build stack as part of this design task.

### Runtime and verification evidence

The reference was copied to a disposable directory outside the repository, then built and exercised there. Nothing inside _reference/ was changed.

- The unmodified Web release command ran 128 tests. It passed 126 and failed two badge text snapshots.
- Both failures were newline differences. Expected snapshots contained CRLF; generated JSON contained LF. Both matched exactly after newline normalization.
- After normalizing only those two files in the disposable copy, all four badge renderer tests passed in a targeted rerun.
- The separate production audit passed for ten output files.
- The local Android launcher asset consistency script passed.
- Rendered phone task UI and tablet Settings were visually inspected, along with the Play icon and splash preview. Browser tests exercised phone, tablet, and desktop layouts.

The environment used Node 24.13.0 and npm 10.1.0; the reference requests Node 24.15.0 and npm 11.12.1. Dependency installation therefore needed an engine-check override in the disposable copy. This evidence is useful for analysis, but it is not a clean release certification with the pinned toolchain. No Android feature implementation or new Android test suite was created or run.

## 2. Product scope

Keep the loop short: add a real task, complete it, receive XP once, see progress, leave.

The initial Android scope includes task creation, editing, completion, reopening, deletion, Undo, Active and Standby placement, Completed history, progression, Settings, and confirmed local-data erasure.

Use one dataset per Android app installation and OS user/profile. Core task use works without connectivity because the executable, font, assets, and database are on the device. This is an explicit Android capability beyond Web V1's unsupported-offline boundary. Airplane-mode cold start must verify it.

Support one MECHA//TODO app window per profile. Further launches return to that task without losing its current state. Resizing and split screen with other apps remain supported. Do not advertise simultaneous independent MECHA//TODO windows. Verify the Activity launch configuration with actual repeated launches and window changes; a repository singleton alone does not enforce this interaction model.

Keep accounts, synchronization, backend services, analytics, telemetry, ads, import/export, reminders, due dates, recurring tasks, categories, manual task prioritization, and alternate game systems outside this release. There is no Web-to-Android data adoption path. Room schema version 1 is an independent native schema.

The app is free, without in-app purchases. The interface, listing, screenshots, and release notes are English. The intended audience is teenagers and adults, represented by Play's 13-15, 16-17, and 18-and-over target groups. Distribute in every country the verified publisher account can support, subject to the applicable submission requirements. Target audience and content rating remain distinct declarations.

Use the domain terms todo, Active, Standby, Completed, completion award, Lifetime XP, LINK, COMBO, rules version, and local data problem. User-facing copy can continue to call an individual todo a "task". Use "Active", rather than introducing "Active Bay" from older code and press copy.

The initial distribution target is Android phones, tablets, foldables, and ordinary resizable Android windows, including keyboard and mouse use. TV, Auto, Wear OS, and XR-specific experiences need their own product decisions. Do not add those launchers, manifests, or navigation systems now.

## 3. Domain contract in Kotlin

### 3.1 Text and identity

Saving a todo must:

1. Collapse each run of ECMAScript whitespace to one ASCII space.
2. Trim that resulting space at each end.
3. Count Unicode code points.
4. Accept 1 through 280 code points, inclusive.

Use the exact whitespace set: U+0009 through U+000D, U+0020, U+00A0, U+1680, U+2000 through U+200A, U+2028, U+2029, U+202F, U+205F, U+3000, and U+FEFF. Java/Kotlin default regex whitespace, Char.isWhitespace, and trim are not interchangeable with JavaScript's definition. U+0085 and U+200B must not become spaces merely because another library regards them as separators.

Count with the JVM's code-point facilities, not String.length. Preserve case, emoji sequences, combining marks, and Unicode composition. A grapheme such as a family emoji can contain several code points. Do not apply NFC normalization, silently truncate, or cap the text field by UTF-16 length. Retain invalid input so the user can correct it.

Preserve the errors "Enter a task." and "Task must be 280 characters or fewer." Duplicate normalized text remains valid. Generate opaque UUIDs with UUID.randomUUID(). Persist IDs as strings and never encode order, text, or date into them. Validation should accept an existing nonempty opaque ID; it need not reject test or migrated data solely for lacking UUID syntax.

### 3.2 Status, order, and capacity

Use three explicit statuses, stored as the stable strings active, standby and completed. Do not persist Kotlin enum ordinals.

| Property | Required behavior |
| --- | --- |
| Active and Standby | Sort by immutable creationOrder, ascending |
| Completed | Sort by latest completionOrder, descending |
| Editing | Changes text and update time only |
| Open todo | completedAt and completionOrder are both null |
| Completed todo | Both completion fields are present and a completion award exists |
| Reopening | Goes to Active and clears both completion fields, while retaining the award |
| Completing again | Gets a new completionOrder and completedAt, without a second award |
| Initial sections | Active open; Standby and Completed closed |
| History loading | Oldest 20 Standby records or newest 20 Completed records first |

Use sequence counters, not timestamps, for order. Clock rollback, equal timestamps, edits, and timezone changes must not reorder tasks. IDs provide a deterministic secondary sort key.

~~~text
activeCapacity(level) = min(8 + floor(level / 5), 16)
~~~

Capacity is 8 at levels 0 through 4, 9 at levels 5 through 9, and reaches 16 at level 40. It is a placement target, not a limit on valid Active records. Reopen and Undo may put Active above capacity. Do not reject those actions, demote other tasks, or show an error for 9 / 8.

New tasks enter Active when its committed count is below capacity, otherwise Standby. Completing an open task fills available slots from the oldest Standby tasks, using the level after any new award. Deleting an Active task also fills available slots. Deleting Standby or Completed does not promote anything.

The completion rule above follows implemented and tested behavior. The context mentions Active completion, but the test "fills every available slot from the oldest Standby todos" completes a Standby task and expects promotion. Q6 explicitly settles the Android contract in favor of that tested behavior.

Do not backfill on startup, edit, reopen, or Undo. Undo restores the exact prior status and order; it never reverses promotions that occurred after deletion.

### 3.3 Completion awards

The existence of a completion award determines eligibility. Current status, today's completed-list count, and whether a task is still present do not determine eligibility.

| Rule | Value |
| --- | --- |
| Rules version | 1 |
| Base award | 10 XP |
| LINK | 5 XP on today's first eligible completion when yesterday has an award |
| COMBO | Ordinal 5 adds 2; 10 adds 4; 15 adds 6; 20 adds 8 |
| Other ordinals | No COMBO, including 6, 11, 16, 21, and 25 |
| Lifetime XP | Sum of all retained completion awards |

Assign today's ordinal as max(existing dailyOrdinal for that stored dayKey) + 1. Do not substitute COUNT + 1. Validated data can contain ordinal gaps, and the Web validator does not require continuity.

LINK and COMBO cannot occur in the same V1 award because their eligible ordinals differ. There is no streak multiplier, penalty for a missed day, daily cap, XP decay, or repeated COMBO cycle after 20.

First completion inserts an immutable award. Reopen, re-complete, edit, delete, and Undo cannot change its time, day, ordinal, XP components, or rules version. Deleting its todo leaves history with the opaque ID and award fields, without task text. That history still affects Lifetime XP, LINK, and COMBO ordinals.

An open todo may already have an award. An award may have no todo. A Completed todo must have an award. These are deliberately asymmetric relationships.

### 3.4 Progression and rounding

The pacing anchor is 5,000 XP at level 100, equal to 500 base-only completions. Bonuses can reach it sooner. Do not describe it as exactly 500 completed tasks.

~~~text
p = ln(499) / ln(99)
T(0) = 0
T(level >= 1) = JavaScript Math.round(10 * (1 + (level - 1)^p))
level(xp) = greatest level whose T(level) <= xp
current earned XP = xp - T(level)
current level span = T(level + 1) - T(level)
progress = clamp(current earned XP / current level span, 0, 1)
~~~

Use exponential bracketing and binary search, as in the reference algorithm. Avoid a level table that ends at 100 or 300.

| Level | Cumulative XP |
| --- | --- |
| 0 | 0 |
| 1 | 10 |
| 2 | 20 |
| 3 | 36 |
| 4 | 54 |
| 5 | 75 |
| 10 | 205 |
| 20 | 546 |
| 50 | 1,938 |
| 100 | 5,000 |
| 300 | 22,249 |
| 1,000 | 113,620 |

At 66 Lifetime XP the level is 4, and the HUD shows 12 / 21 XP. This differs from Lifetime XP.

Use Long for stored integer quantities and for derived levels/milestone inputs, but preserve the Web supported bound of 9,007,199,254,740,991. High reachable levels exceed Int. Keep only genuinely bounded values such as rank indexes, capacity and V1 award components as Int. Check additions and sequence increments before committing. Kotlin's wider integer range must not silently expand the product contract.

Use Double only for the curve and progress ratio. Kotlin round uses ties-to-even and must not replace JavaScript Math.round. Select rounding with ties toward positive infinity for nonnegative values and verify it against Web-generated fixtures. Also check the floating-point exponent and threshold results, rather than assuming mathematical equivalence gives identical boundaries.

Thresholds used for search bracketing or the next level may exceed the maximum supported stored XP. Do not clamp them to that maximum, which could prevent the search from terminating. Keep those intermediate comparisons representable and guard conversions; arbitrary safe-integer level inputs can produce thresholds beyond Long. Extend tests to high reachable levels and the maximum supported Lifetime XP before claiming parity across the supported range.

### 3.5 Rank, designation, and badges

| Levels | Rank |
| --- | --- |
| 0 through 4 | Cadet |
| 5 through 9 | Specialist |
| 10 through 14 | Sergeant |
| 15 through 19 | Lieutenant |
| 20 through 24 | Captain |
| 25 through 29 | Major |
| 30 through 34 | Colonel |
| 35 through 39 | General |
| 40 onward | Marshal |

Levels 40 through 49 have no designation. From level 50, each designation spans ten levels in this exact order:

~~~text
Alfa, Bravo, Charlie, Delta, Echo, Foxtrot, Golf, Hotel, India,
Juliett, Kilo, Lima, Mike, November, Oscar, Papa, Quebec, Romeo,
Sierra, Tango, Uniform, Victor, Whiskey, X-ray, Yankee, Zulu
~~~

Zulu starts at level 300 and remains final. Numeric levels continue. Preserve "Alfa", "Juliett", and "X-ray" exactly.

Cadet through General have zero through four pips, calculated as level modulo five. Every Marshal uses the same approved badge with no pips. Designations change text only.

The HUD shows level, rank, and optional designation separately. Use a minimum of three digits for the visible level without truncating longer levels. Render the designation separator as //, but announce "Marshal, designation Alfa". Settings shows the current identity and one next named milestone. At Zulu it shows "Named progression: Final".

Committed feedback prioritizes a new rank, then a new designation, then a level increase. Capacity growth and the number of promoted tasks can accompany that result. Derive the before/after comparison from the committing transaction so concurrent completions cannot compare against a stale UI snapshot.

Changing rank display rules does not rewrite awards or bump their reward rules version. Do not persist level, rank, designation, badge, pips, or progress percentage.

## 4. Time and calendar semantics

Persist event timestamps as epoch milliseconds and award dayKey as a fixed Gregorian YYYY-MM-DD string. Capture the instant and the current device ZoneId together inside the write transaction, after waiting for the writer, when calculating a first award. Convert that instant to LocalDate once.

Use LocalDate.minusDays(1) for yesterday. Subtracting 86,400,000 milliseconds fails around daylight-saving transitions. minSdk 26 already provides java.time.

The stored day key is the reward fact. Never derive old day keys again from timestamps and the device's current timezone. Clock or timezone changes can cause users to revisit an earlier day; awards already on that key still count. There is no anti-cheat or retroactive LINK correction.

The Web code samples time during the transaction before the actual storage commit. Follow that practical boundary. If the transaction crosses midnight after sampling, keep its sampled date. Do not calculate the day at UI tap time, or amend the award after commit.

Validate fixed-width day keys with strict Gregorian parsing, including leap years, independently of the user's locale or preferred display calendar. Stored timestamps must be integer epoch milliseconds from 0 through 9,007,199,254,740,991. A supported current clock must also yield a local date with a four-digit year from 0000 through 9999. These are separate bounds. Reject an unsupported clock before an operation that writes timestamps or creates fresh metadata, including before destructive file erasure. Do not create data that fails the next startup.

An invalid current clock or exhausted supported XP/order range rejects the affected operation without changing its data. Explain the clock problem or supported limit and keep trusted existing data available. Neither condition alone means the stored dataset is corrupt. Draft-only writes do not need a timestamp. Daily indicators can show a clock explanation while the existing task list and Lifetime XP remain readable.

The reference requires updatedAt >= createdAt but writes the raw current clock during edits, completion, reopening, and promotion. Q5 resolves the defect for Android: clamp updatedAt to max(previous updatedAt, createdAt, sampled instant). Retain the actual sampled instant for awardedAt, completedAt, and dayKey. This adjustment must not move a reward into another day.

The daily HUD uses the current calendar, not a permanently captured application-start date. Refresh it on foreground entry, after mutations, and on date/time/timezone changes. While the screen remains visible across midnight, schedule one in-process refresh for the next local day boundary and recompute it after clock changes. No exact alarm, service, or WorkManager job is needed.

The HUD reports LINK READY when yesterday has an award and today has none, and LINK ACTIVE when a stored award today has LINK. Display an upcoming COMBO hint alongside LINK when both apply. Do not let LINK suppress it. These are independent indicators; V1 still never grants both bonuses in the same award.

For the COMBO hint, use today's maximum stored dailyOrdinal, or 0 if none exist. Show COMBO 4/5, 9/10, 14/15, or 19/20 only when that maximum is one short of the respective bonus ordinal. Hide the hint at the milestone and after ordinal 20. This is explicitly different from Web's count-based hint so valid ordinal gaps cannot promise a bonus that the next completion will not earn. Reward allocation and amounts stay unchanged. The hint persists until the underlying day/award state changes; it is not a timed reward toast. Wrap indicators when necessary, and expose both labels without overlapping or truncating them.

## 5. Architecture and ownership

~~~mermaid
flowchart TD
    UI["Compose task screen and Settings"] --> VM["TodoViewModel"]
    VM --> Repo["TodoRepository"]
    Repo --> DB["Room database and DAO"]
    Repo --> Rules["Pure Kotlin task, reward, and progression functions"]
    DB --> Repo
    Repo --> Flow["Committed snapshots through Flow"]
    Flow --> VM
~~~

Keep all production code in :app. A shallow package arrangement under the existing namespace is sufficient:

~~~text
MainActivity.kt
MechaTodoApplication.kt
data/       Room entities, DAO, database, repository, startup validation
domain/     Text, reward, calendar, progression, rank, capacity functions
ui/         TodoViewModel, task screen, Settings content, badge renderer
ui/theme/   Color, typography, theme, a few shared dimensions
~~~

The domain package groups meaningful pure rules. It is not a use-case layer or separate Gradle module.

| Component | Responsibility and reason |
| --- | --- |
| Application/container | Own one database and repository for the process; supply a manual ViewModel factory |
| MainActivity | Install splash, host Compose, configure edge-to-edge, connect platform lifecycle callbacks |
| TodoViewModel | Own screen state, invoke meaningful repository methods, coordinate pending actions and transient feedback |
| TodoRepository | Enforce invariants across several tables, transact writes, prepare/validate storage, and expose consistent reads |
| DAO | Express related SQL operations across the tables; one DAO is sufficient initially |
| Pure functions | Make exact reward, rank, text, calendar, and capacity behavior independently testable |
| Compose components | Render state, manage local presentation and focus, and invoke callbacks |

Use constructor injection with a java.time.Clock, a ZoneId supplier, an ID supplier, and an elapsed-time supplier where needed. These are concrete test inputs, not a reason to create service interfaces. No Hilt, Koin, base classes, event bus, reducer framework, generic Resource wrappers, repository interface/implementation pair, or trivial use-case classes.

Reuse entity values where their meaning matches what callers need. A screen snapshot legitimately differs because it contains section counts, visible lists, and derived progression. Do not add entity-to-data-to-domain-to-UI copies of each todo.

Use ordinary methods such as addTodo, editTodo, setTodoCompleted, deleteTodo, and undoDelete. Completion accepts the desired state rather than a blind toggle, so retrying the same request cannot accidentally reopen a task.

Settings is an overlay of the same task destination and reads the same progression state. It does not need another repository or ViewModel. A full-window presentation on compact windows and a constrained dialog on larger windows are enough. Introduce a navigation library only if real destinations appear.

Add only the dependencies that support these responsibilities: Room runtime and compiler with compatible KSP processing, lifecycle-viewmodel-compose, lifecycle-runtime-compose, and core-splashscreen. Reuse the existing Compose and Material 3 dependencies. Add room-testing and coroutine test support for the relevant tests. Keep the version catalog coherent with AGP's Kotlin configuration; do not add another Kotlin Android plugin or a bundled SQLite driver by habit.

### State placement

| State | Owner and lifetime |
| --- | --- |
| Todos, awards, metadata | Room; survive process death and ordinary app updates |
| Composer text | Screen ViewModel while editing; a best-effort durable composer draft row for restart |
| Composer selection and focus | Compose-local state |
| Inline edit ID and raw text | Screen ViewModel while editing; a separate best-effort durable edit draft row for restart; validate restored text without saving the task |
| Inline validation and pending Save/Discard dialog | ViewModel/transient UI; recompute validation when needed; never restore or replay a pending action |
| Section disclosures and list scroll | Local Compose saveable state for restoration of the same task; defaults apply to a fresh task |
| Visible history limits | ViewModel, with only small limits saved if needed for task restoration |
| Settings visibility | Local saveable presentation state |
| Erase confirmation | Transient UI; never restore an already-confirmed destructive action |
| Pending database actions | ViewModel coroutine state; never serialize work for replay |
| Delete snapshot and deadline | ViewModel memory only |
| Progression and daily indicators | Derived from Room and current calendar |
| Reward/status feedback | ViewModel memory with an identity and acknowledgement; never durable reward events |

SavedStateHandle and rememberSaveable use saved-instance-state storage with limited size. Store small IDs, flags, and positions, not task lists, awards, deletion snapshots, or large arbitrary input. A ViewModel survives configuration change, not process death. [Android state-saving guidance](https://developer.android.com/develop/ui/compose/state-saving)

Collect observable state with collectAsStateWithLifecycle. Keep the actual database in the application container, outside Activity/Composable lifetimes.

## 6. Room schema

Use the stable database name mecha-todo.db, independent of the display name. Keep database schema version, app version, and reward rules version separate.

### Tables

| Table | Columns |
| --- | --- |
| todos | id TEXT primary key; text TEXT; status TEXT; creationOrder INTEGER; completionOrder nullable INTEGER; createdAt INTEGER; updatedAt INTEGER; completedAt nullable INTEGER |
| completion_awards | todoId TEXT primary key; awardedAt INTEGER; dayKey TEXT; dailyOrdinal INTEGER; baseXp INTEGER; linkBonus INTEGER; comboBonus INTEGER; totalXp INTEGER; rulesVersion INTEGER |
| app_meta | id INTEGER primary key with the sole value 0; createdAt INTEGER; rulesVersion INTEGER; nextCreationOrder INTEGER; nextCompletionOrder INTEGER |
| composer_draft | id INTEGER primary key with the sole value 0; rawText TEXT |
| edit_draft | id INTEGER primary key with the sole value 0; todoId TEXT; rawText TEXT |

All columns are non-null except the two todo completion fields. Quantities and times map to Kotlin Long; small rule components can use Int with explicit allowed values. Require exactly one valid app_meta row. Each draft table permits zero or one valid row; absence means no stored draft. Empty raw composer text is valid. An edit draft requires a nonempty opaque todoId and raw text, which may be empty or over the task limit while the user is editing.

Validate the raw SQLite storage class of every authoritative column before typed Room mapping or aggregates such as SUM and MAX. Integer fields require stored INTEGER values; text fields require TEXT; NULL is permitted only for the two nullable completion fields. Use typeof or cursor type inspection before getters can coerce malformed values. SQLite column affinity alone does not enforce the stored type. Values that SQLite legitimately stored as INTEGER through affinity conversion are integers; validate their bounds normally. Never repair a stored REAL, BLOB or nonnumeric TEXT value by casting it. Apply the same type checks separately to optional drafts so their logical failures retain the nonblocking policy. [SQLite storage classes and affinity](https://www.sqlite.org/datatype3.html)

A fresh dataset has no todos, awards or draft rows. Initialize app_meta with id 0, the validated current createdAt, rulesVersion 1 and both next-order counters at 0, matching the reference. Order values are nonnegative safe integers; daily award ordinals start at 1. Allocate the stored next counter, then increment it in the same transaction. Refuse the operation if its new stored counter would exceed the supported bound.

Draft validation checks the expected SQLite value types, singleton ID and cardinality separately from authoritative records. Raw draft text is not subject to saved-task normalization or length validation. A valid draft whose task is missing is unresolved optional state, not permission to create that task. Do not add a foreign key that automatically deletes this recoverable text.

Do not add a foreign key from completion_awards to todos. Cascading deletion would destroy XP; a restrictive foreign key would prevent the required task deletion. Nor should every todo require an award. Enforce the conditional Completed-to-award requirement in repository transactions and startup validation.

Required indexes:

- Unique todos.creationOrder.
- Unique todos.completionOrder. Multiple null values are allowed for open tasks.
- Composite todos indexes on status, creationOrder, id and status, completionOrder, id.
- Unique completion_awards index on dayKey, dailyOrdinal. Its leading dayKey also serves day lookup and maximum ordinal queries.

The award primary key enforces one award per todo. Use abort-on-conflict inserts. Never use replace or upsert for awards, because either can overwrite immutable history. Keep award update/delete operations unavailable to ordinary task methods; confirmed full erasure is the only deletion path.

Use Room-supported primary keys, nullability, and unique indexes as database constraints. Add explicit record validation for status relationships, rule values, text normalization, safe bounds, and arithmetic. Room schema validation alone does not validate those invariants. Avoid a parallel hand-written schema or trigger framework merely to duplicate all validators.

### Derived data and drafts

Do not port Web's derived-stats metadata cache initially. Obtain Lifetime XP from SUM(totalXp), and counts from SQL, in a consistent transaction. This removes a second stored value that can drift from the awards. Validate sums safely before trusting them. Measure large-history queries before introducing a cache.

Drafts are deliberately nonauthoritative. Two optional Room rows let Add clear the submitted composer draft and Save clear the submitted edit draft in the same transactions as their task changes. Full erasure clears both atomically. This avoids a Room/DataStore coordination protocol for two text values. DataStore can be introduced later for actual user preferences.

Typing updates the UI immediately and persists asynchronously. Serialize writes, coalesce obsolete queued snapshots, and retain only the latest pending value for each slot. Do not postpone persistence indefinitely during continuous typing. Attempt a final flush when leaving the foreground, but do not promise that Android will keep the process alive to finish it. The durability promise is the last committed draft, not every keystroke. Preserve raw whitespace, composition text and over-limit input.

A failed draft save leaves the current text in memory and shows a persistent, nonmodal warning that the latest text may not survive restart. Keep valid task operations available. Composer and edit slots fail independently where possible. A logically malformed stored draft, or an unresolved edit whose task is missing, remains untouched until explicit Discard saved draft or full erasure. Its slot cannot silently overwrite that record; new typing or another task's editor can operate in memory with the warning. Add and Save must still work while preserving the protected record. Schema failure or physical corruption of the shared database still blocks the app through LocalDataProblem.

Before Add or Save, finish or supersede earlier queued writes for the submitted slot, briefly prevent edits to that input, and transact the task change plus clearance of its matching valid draft. Match by slot/task ownership and current session, not exact raw-text equality: failed draft persistence may have left an older value for the same input. Await prior draft attempts, but do not require them to have succeeded before using the current in-memory text. Protected malformed/unresolved records, including one in the submitted slot, must not prevent a valid task write or be silently deleted by it. Keep typed input when the task write fails.

A known successful Add clears its submitted in-memory composer text immediately. A known successful Save closes and clears its submitted editor immediately. Do this even if the later refresh fails, while retaining any unrelated unsaved input. A protected saved draft remains stored with its warning until explicit discard; ordinary cancellation of a different memory-only editor does not authorize removing it.

Cancel and Discard clear the corresponding valid draft, or the explicitly selected malformed slot, through the same serialized writer. Invalidate obsolete queued writes first. If durable clearance fails, honor cancellation in memory, permit the requested action, and show: "The saved draft could not be cleared. It may return after restarting." Do not claim that the stored draft was deleted.

Use a small in-memory dataset-session identity and draft generations to reject obsolete queued writes after Add, Save, Cancel, reset or replacement. They are coordination values, not another persistent command system. No old operation may resurrect text after a successful clearance. Cover these races with real Room transactions and controlled coroutine scheduling.

### Transaction boundaries

| Operation | One write transaction must contain |
| --- | --- |
| Add | Read authoritative progression and Active count; allocate creation order; choose status; insert todo; increment counter; clear matching valid composer draft |
| Edit / Save | Read existing target; normalize/validate new text; update only text and update time; clear matching valid edit draft |
| First completion | Read current todo and award eligibility; capture calendar; allocate daily ordinal; calculate and insert award; allocate latest completion order; update todo; promote oldest Standby using new XP/capacity; advance metadata |
| Re-complete | Verify existing award; update todo and latest completion order; promote into available slots; preserve award |
| Reopen | Verify completed target and its award; set Active; clear completion fields; preserve creation order and award |
| Delete | Read exact snapshot and award existence; delete todo; promote only if former status was Active; retain awards; leave no matching valid edit draft pointing at the deleted task |
| Undo | Verify snapshot belongs to current dataset session and ID/order do not conflict; reinsert exact snapshot; verify an award exists if restoring Completed |
| Erase, healthy database | Delete all task, award, composer-draft, edit-draft and metadata rows; insert fresh core metadata; commit together |

Do not await UI, animation, network, or a draft debounce timer inside a database transaction. Use suspending Room transaction APIs and dispatch database work off the main thread.

SQLite transactions and uniqueness constraints are the authority for concurrency. A repository Mutex can coordinate local lifecycle operations, draft writes, reset, and closing connections. It does not replace SQL transactions or protect a second connection by itself.

Repeated setTodoCompleted(id, true) on an already Completed todo succeeds as an unchanged, already-credited result. Setting false on an already open todo is unchanged and must not move Standby into Active. Editing a missing target and restoring an existing ID report a conflict; they never recreate or overwrite it. Edits retain Web's last successful write wins behavior.

On a real uniqueness race, re-read within a fresh transaction and either recognize the already-applied result or retry the whole operation a bounded number of times. Do not catch a failed award insert and continue halfway through the same transaction.

### Committed reads and pagination

Read Active rows, section counts, visible history prefixes, progression inputs, and award indicators from one read transaction. Combining unrelated DAO flows independently can briefly show a new XP total with old rows, or the same todo in Active and Completed.

Use Room invalidation to request a new snapshot, then publish it as one screen value. Observe only relevant product tables for task snapshots, so every draft keystroke does not recalculate the list. Share observation at the screen boundary.

Initially fetch 20 rows plus one to detect more. "Show 20 more" increases the Standby visible limit; "Show 20 older" increases Completed. Re-query that ordered prefix after mutations and preserve the user's visible limit. This is simpler than keeping Web cursor arrays synchronized in Compose. Exactly 20 records must not show a load-more action. Load collapsed history only when needed. Do not add Paging 3 until measurements justify it.

Return a mutation's committed outcome separately from later snapshot/read failures. Once the transaction succeeds, a failed refresh must say that the task was saved and offer to reload. It must not ask the user to repeat an Add with a new ID. Keep the previous snapshot visibly marked as out of date, consume any input already submitted successfully, and preserve unrelated unsaved input. Make the stale task/input view read-only and suspend task mutations and draft writes until a successful reload. If erasure committed, immediately remove the old snapshot and both drafts from the display even if refresh fails.

Retry a failed read without reopening the database when the existing connection remains trustworthy. A required full reopen follows the startup path and invalidates Undo. If the data can no longer be trusted, use LocalDataProblem. The readonly stale state still permits Retry and the existing confirmed-erasure path. Never show optimistic XP or imply that known committed work must be submitted again.

## 7. Opening, migration, and local data problems

### Startup

Use meaningful states: Opening, Ready, StaleSnapshot, and LocalDataProblem. StaleSnapshot means a prior committed view is visibly out of date after a failed refresh; it is read-only until reload succeeds. A transient busy/open failure can use a retryable explanation within the error state. Do not copy browser-tab-specific error categories or instructions.

Before Ready:

1. Open the existing file and run an explicitly supported migration, or create version 1 only for a new dataset.
2. Let Room validate the expected SQL schema.
3. Validate raw storage classes, authoritative values and cross-record relationships in a consistent transaction, before typed mappings and aggregates can conceal malformed values.
4. Rebuild safe ordering counters if required.
5. Read the initial committed screen snapshot.

Load optional drafts after establishing trust in the authoritative dataset. A missing draft row is valid. Classify logical draft problems separately, preserve the affected records and show the agreed nonblocking warning. A draft problem must not turn healthy saved tasks into an apparently empty list or a global data error.

Check normalized nonempty text, safe integer values, status/completion fields, unique order values, strict day keys, allowed V1 award components, exact total XP, supported rules, safe Lifetime XP accumulation, one core metadata row, and Completed records with matching awards.

Do not require every award to have a todo, every open todo to be unawarded, contiguous daily ordinals, or awardedAt to equal the latest completedAt. Do not recalculate historical LINK eligibility against today's view of history. A user may have moved the clock backward and added yesterday's award later.

Web distinguishes valid-but-stale derived metadata from malformed metadata: it rebuilds safe counters and valid cached stats, but blocks on invalid core records, malformed cache records, and unsafe stored XP. Android's absence of the cached-stats row removes that particular failure mode. It does not permit dropping bad authoritative data.

Counter rebuilding must never rewrite todo order. Do it only when no live Undo snapshot can conflict with a reused order value. Normal mutations keep counters advancing; a full reopen first invalidates Undo.

Use streaming validation for growing history rather than holding all awards in the UI. Validate enough to trust the complete authoritative dataset. Do not silently skip a malformed record because it lies outside the first page.

Check file existence before invoking automatic creation. An existing empty, foreign, or damaged file is a local data problem, not permission to initialize an empty database. Missing core metadata in an existing database must never trigger creation of replacement metadata. Test these cases through the real open path.

Run a read-only SQLite quick_check during startup alongside domain validation, off the main thread. It detects structural problems but does not verify unique constraints or index/table consistency. Keep explicit uniqueness checks over the authoritative records; use fuller integrity checks in corruption tests where needed. Neither check authorizes repair. [SQLite integrity checks](https://www.sqlite.org/pragma.html#pragma_quick_check)

### Corruption policy

Preserve the database on failure. Show "Local data could not be opened." with Retry and an explicit "Erase local data" path. No usable-looking empty list, automatic repair, quarantine, dropped row, reset, or in-memory persistence fallback.

Disabling Room destructive migration is necessary but insufficient. The default SupportSQLiteOpenHelper corruption callback deletes the database file. Its configuration also has an option to permit file recreation after failed opening. [Corruption callback](https://developer.android.com/reference/androidx/sqlite/db/SupportSQLiteOpenHelper.Callback), [open-helper configuration](https://developer.android.com/reference/androidx/sqlite/db/SupportSQLiteOpenHelper.Configuration.Builder)

For an Android-only Room implementation, prefer the framework SQLite integration with one narrowly scoped open-helper factory/callback adapter. Delegate normal creation and migration to Room; override corruption handling so it never calls the deleting default, disable data-loss recovery, and report the failure. This adapter has one concrete purpose: preserving the product's no-automatic-erasure guarantee.

Pin and test the chosen Room/SQLite integration before building features on it. If a different driver is selected, verify its actual corruption and reopen behavior instead of assuming that a catch around Room opening preserves the file. A physically damaged file, migration failure, and ordinary full-storage write failure need separate tests.

Retry must close/reopen safely and inspect the same data. It must not switch to another filename, copy only good rows, or recreate missing tables.

For a recoverable write error, keep the input or row and offer retry. If storage is no longer trustworthy or readable, block further mutations behind LocalDataProblem. Report no reward before commit. Diagnostics must contain safe categories, not task text, SQL bound values, or serialized records.

### Migrations

Start native Room at schema version 1 and export its schema into version control. Every released supported version needs a representative fixture, an ordered migration path, schema validation, and assertions that task values and immutable awards survived. Include reopened rewarded todos and orphaned awards in fixtures.

A migration that transforms authoritative data must validate the transformed values within its migration transaction and fail before committing an invalid result. Startup validation still runs afterward. A schema-only migration test cannot establish that reward history was preserved.

Never use fallbackToDestructiveMigration, its downgrade variant, or selected-version destructive fallbacks. Unknown newer schemas/rules should produce an update/retry explanation, preserving files. MigrationTestHelper checks structure; explicit fixture assertions check data and domain semantics. [Room migrations](https://developer.android.com/training/data-storage/room/migrating-db-versions), [MigrationTestHelper](https://developer.android.com/reference/androidx/room/testing/MigrationTestHelper)

Reward changes need a new reward rules version with continued interpretation of V1 awards. Display-only rank/designation changes need neither award rewrites nor a Room migration. A product rename must not change the database filename or release application ID.

### Confirmed erasure

The dialog must say that every task, completion award, progression value, composer draft and unfinished inline edit will be removed. Cancel and Back change nothing. This confirmation replaces the ordinary unsaved-edit guard; saving text immediately before full erasure is unnecessary. Do not conflate ordinary task deletion, which retains XP, with this reset.

For readable storage, perform the table reset in one transaction. Suspend task and draft writes while it runs, and keep previous input available in memory until the outcome is known. Serialize reset with other mutations. On successful commit, start a new dataset session and invalidate Undo, feedback, editors and queued draft writes from the previous session. Reset disclosures and return to level 0 Cadet. Old work must not add a task or draft afterward.

If the transaction rolls back, preserve the tasks and current typed drafts, report that erasure failed, and resume the surviving dataset once storage is trustworthy. Do not clear editor state before commit. If erasure committed but the next read fails, remove the old data and drafts from the UI immediately, say erasure succeeded, and offer to reload. Never present the old dataset as if it survived a successful erasure.

For an unreadable or unsupported database, confirmed erasure can close all handles and delete the known database and SQLite sidecars before creating a fresh one. File deletion/recreation is not a Room transaction. If deletion or recreation fails, remain on the error screen and explain that reset did not finish. Never claim rollback of a file that has already been deleted.

Keep this deletion operation tied to the exact configured app-private path, especially if using the no-backup directory. It must never scan for or delete unrelated files. "Erase" describes removal from the app's usable storage, not a forensic secure-wipe guarantee.

## 8. Lifecycle, process death, and Undo

Room commits survive Activity recreation and process death. An interrupted transaction either commits or rolls back; UI cancellation does not prove that a commit failed. On restart, read the database instead of replaying pending UI events. A task whose first completion committed before the process died already owns its award.

Use viewModelScope for screen-triggered operations. Rotation keeps the same ViewModel. Finishing the task or losing the process can cancel work; there is no need for a service or persistent work queue for local button actions. Re-throw coroutine cancellation rather than presenting it as a generic database error.

Do not save optimistic checked states, in-flight flags, or reward events. On recreation, committed state wins. Feedback should not replay because Flow emitted the same total or a collector restarted.

Retain small disclosure/scroll presentation state when Android restores the same task, while a new task normally starts Active open and the other sections closed. Restoring a valid unfinished edit overrides those disclosure and scroll defaults: open its current section, load enough history and bring the editor into view without automatically opening the keyboard. A restored Settings overlay stays above it until dismissed.

| Event | Result |
| --- | --- |
| Rotation or window resizing | Retain in-memory text, the editor, presentation and any live Undo with its original deadline |
| Background/foreground with process alive | Retain current interaction; refresh the date and check Undo expiry before presenting it |
| Same-task restoration after process death | Read committed tasks and the last durable drafts; restore small disclosure/scroll/Settings state; let the restored edit take priority over list positioning |
| Fresh task launch | Apply default disclosures, then restore durable drafts; reveal a valid edit as above |
| Target moved between sections | Use its current persisted status and location, never an old todo snapshot from the draft |
| Target text changed | Keep the raw draft; an explicit Save follows last-successful-write-wins; Cancel leaves the current saved task intact |
| Target no longer exists | Never recreate it; retain the unresolved draft and show the nonblocking warning with explicit Discard |
| Draft persistence failed before process death | Restore only the last committed draft; never claim that newer typing was durable |
| Any process restart | Discard Undo, pending actions, reward feedback and destructive confirmations; never replay a completion, deletion or reset |

### Undo contract

Deletion commits immediately. Only the newest successful deletion in commit order offers Undo. A failed deletion must not replace the existing offer. Coroutine result-delivery order must not let an older deletion replace a newer offer.

Keep a PendingUndo value containing the exact deleted todo, a monotonic deadline, and the repository's current dataset-session identity. Do not write it to Room, DataStore, SavedStateHandle, an Intent, or saved-instance state.

- Base duration is 5,000 milliseconds, adjusted by Android's recommended accessibility timeout with text and controls enabled. Start the single deadline when the committed deletion outcome becomes an offer, including while the app is backgrounded. Do not wait for a snackbar or foreground collector.
- Use elapsedRealtime for expiry so wall-clock changes do not extend or shorten it, and sleep/background time counts.
- Rotation retains the offer and original deadline. Do not restart its timer.
- Returning from the background first checks the deadline. Never display an already-expired action.
- Process death, a finished app task, reset, or a full database reopen/replacement discards the offer. A snapshot Retry on the same trustworthy connection keeps the original deadline.
- A second deletion replaces it. Ordinary reward messages must not quietly queue, hide, or extend it.
- Consume the offer before starting restore. Both successful and failed Undo consume it, matching Web behavior.
- Check eligibility when the user invokes Undo. A tap accepted before the deadline remains eligible while waiting for the database writer; recheck session/ID/order conflicts inside the transaction, not the expired UI timer.
- Reinsert the original status, creation order, completion order, and timestamps. Do not mint an award or undo a promotion.
- Reject a snapshot from a previous dataset session or with an ID/order conflict. Never use upsert to force it back.

Q3 approves the native accessibility-timeout adaptation. Use calculateRecommendedTimeoutMillis with text and controls enabled, and keep the visible action and actual eligibility tied to the same monotonic deadline. [Compose AccessibilityManager](https://developer.android.com/reference/kotlin/androidx/compose/ui/platform/AccessibilityManager)

Keep a clearly labelled deletion/Undo control in the composer's nonmodal feedback area, separate from the latest ordinary status message. A newer completion message cannot hide or relabel the deletion it will restore. Ordinary feedback replaces the previous ordinary message; it does not form a queue or reset Undo. Settings can cover the underlying area, but never pauses the deadline. Announcements remain polite and do not steal focus.

## 9. Native interaction and layout

### Task screen

Preserve the hierarchy: compact progression HUD, one task-list scroll region, composer and feedback. There is no visible product-name header on the ready screen. Keep Settings reachable from the HUD.

Use a single LazyColumn for section headers, task rows, empty states, and load-more controls. Stable item keys use todo IDs. Do not nest independent scrolling lists inside each section.

Keep the content left aligned within a centered column on larger windows. The Web maximum is 680 CSS pixels; a native width around 680 dp is a starting design dimension, not an exact unit conversion. Do not add dashboard columns, a navigation rail, or a bottom navigation bar for this one destination.

The normal phone layout keeps HUD and composer available while the task list scrolls. For short windows, landscape with the IME, and large text, allow the hierarchy to participate in a single scrollable layout if fixed regions would leave no usable task area. Preserve order and reachable controls. Do not force portrait or shrink text to preserve a screenshot.

Use the current window's usable width and height, not device labels or raw screen pixels. Android 16 makes resizability and unrestricted orientation the baseline on large screens for apps targeting API 36. Include tablet, fold/unfold, split screen, and desktop window resizing in acceptance. [Android large-screen behavior](https://developer.android.com/develop/adaptive-apps/guides/app-orientation-aspect-ratio-resizability)

### Task actions

Each row has a visible completion control, editable task text, and Delete action. Preserve these paths for touch, mouse, keyboard, and accessibility services. Do not make swipe or long press the only way to act.

One-line storage does not mean one-line display. Long tasks wrap and all controls remain reachable. Completed text remains readable with a modest strike-through and a checked state.

Keep one inline editor. Save through the visible Save action, IME Done or hardware Enter outside character composition. Explicit Cancel and Escape discard directly. Focus loss alone neither saves nor discards, including on backgrounding, closing the keyboard or opening Settings.

For changed text, Back first dismisses the keyboard. A subsequent Back, opening another task's editor, or completing/deleting the edited task offers Save, Discard or Keep editing. Save continues the requested action only after a successful save and usable refreshed state. A failed validation or write returns to the original editor with its input and error, and cancels the continuation. Unchanged text needs no discard guard. Settings and section collapse preserve the unfinished editor. Unrelated row actions remain usable.

If Save succeeds and the subsequent completion/deletion fails, keep the saved text and explain which second action failed. These are separate user-understandable outcomes. If the process dies between them, read committed state at restart and never replay the second action. A committed Save followed by failed refresh stops the continuation and enters StaleSnapshot.

Use IME composition-aware input. Do not intercept an Enter key that is committing a composing character. Paste must reach the normalizer without losing newline separators or adjacent words.

Adding should not focus the composer automatically on app launch. A successful touch Add dismisses the software keyboard; hardware-keyboard entry retains focus for another task. Use the initiating interaction on hybrid devices, not a permanent device classification. Validation or storage failure keeps the draft and input interaction. A restored inline edit likewise does not open the keyboard automatically.

Web immediately checks a completing row, disables its completion control, and briefly retains it for 240 ms before reconciliation. A failed write reverses that visual check and restores focus. Rewards appear only after commit.

Preserve the immediate check response in Compose as a small per-row pending visual state. Do not optimistically change XP, counts, promotions, or persistent status. Delete keeps the row until commit. Coordinate actions on the same row so edit/delete cannot race its pending completion. Keep other rows usable. Disabled system animations remove the brief visual hold; they never alter the transaction.

### Feedback and Settings

Preserve compact feedback such as "TASK COMPLETE · +10 XP", "TASK COMPLETE · ALREADY CREDITED", "TASK REOPENED · XP RETAINED", "ADDED TO STANDBY", and "TASK DELETED · XP RETAINED". Do not present a second reward for an unchanged repeated completion request.

Keep the three empty states:

~~~text
Nothing active right now. Add a task when you're ready.
Nothing on standby right now. Extra tasks will wait here.
Nothing completed yet. Finished tasks will collect here.
~~~

Settings contains progression, device-local data information, application/database/rules versions, offline privacy policy text with its public link, the support address, and local-data erasure. Use a full-window view on compact windows and an opaque constrained dialog on larger windows. Preserve focus within dialogs and return it to the opener on dismissal. Native Back and predictive Back follow overlay order, with erasure confirmation above Settings. Dismissing Settings reveals any retained inline edit; it does not discard it.

Use Android string resources, plural resources, and locale-aware number formatting. Ship English UI and store material. Users may enter tasks in other languages; test emoji, composing input, mixed-direction text and unsupported-font fallback. Keep canonical rank/designation spelling stable. Uppercase is for the product mark, rank presentation, and short status labels, not explanations or error paragraphs.

### Edge-to-edge and IME

Retain enableEdgeToEdge and adjustResize. Draw the background behind system bars but inset content away from status/navigation bars, display cutouts, and desktop caption bars. Set system icon appearance to suit the selected light or dark app background. [Edge-to-edge setup](https://developer.android.com/develop/ui/compose/system/setup-e2e)

Choose one owner for each inset. A Scaffold can supply system/cutout padding; consume that padding before child IME handling. Position the composer above the keyboard with the appropriate IME inset, without adding navigation-bar padding twice. Test gesture and three-button navigation. [Material 3 inset guidance](https://developer.android.com/develop/ui/compose/system/material-insets)

Bring the focused editor into view. Error text, Undo, Save, and Delete must remain reachable when the keyboard occupies most of the window.

## 10. Accessibility and visual identity

Use native semantic controls and minimum 48 by 48 dp interaction targets. This intentionally exceeds Web's 44 CSS pixel minimum. Do not place overlapping invisible targets around tightly packed controls. [Compose accessibility defaults](https://developer.android.com/develop/ui/compose/accessibility/api-defaults)

Provide task-specific names for Complete, Reopen, Edit, and Delete. Expose checked state separately from task text. A text button that starts editing must announce that action. Section disclosures need heading, count, and expanded/collapsed semantics. Ensure merged row semantics do not swallow its separate actions.

Expose level progress with native progress semantics and an accessible current/span description. Speak the rank and optional designation once; hide the adjacent badge from accessibility when it duplicates that identity. Do not make screen readers pronounce the decorative // separator.

Use a polite live region for committed feedback and validation errors. Announce one result once. Do not flood TalkBack with every frame of an animated progress bar or a repeated StateFlow value.

Support TalkBack, Switch Access, keyboard Tab/Shift-Tab, Enter/Space, Escape where available, and visible focus. After a row disappears, focus a stable next action or section control rather than a destroyed element. After a rejected write, return focus to the original action. New feedback must not steal focus.

Test at 200% font scale and enlarged display size, including 280-code-point text and long identities such as Marshal // November. Reflow labels and action rows; do not ellipsize away the designation or force fixed text heights. Minimum targets are floors, not fixed row heights.

Honor disabled system animations and reduced-motion needs. Color must not be the only sign of status, failure, focus, or completion. Web forced-colors CSS has no direct Compose port. Check Android high-contrast text, color correction, inversion, and readable contrast on real native controls instead of claiming CSS forced-colors parity.

### Theme and badges

Ship branded light and dark palettes and follow the device's current appearance automatically. Do not derive colors from wallpaper or add an in-app theme override. On a device without a user-facing dark-mode switch, follow its reported configuration. A mode change while editing preserves all input and pending state.

Use semantic color roles with matched foreground/background pairs. The approved dark colors remain the reference; the adapted light colors below make the implementation concrete. Do not invert bitmap artwork or reuse bright dark-theme status colors on light surfaces.

| Role | Dark | Light |
| --- | --- | --- |
| Background | #09070D | #F5F1F8 |
| Surface | #15101D | #FFFFFF |
| Raised surface | #1E1629 | #EDE5F2 |
| Border | #4A355B | #897895 |
| Text | #F5F1F8 | #21152B |
| Muted text | #B7A9C2 | #67546F |
| Purple accent | #B86CFF | #7636A9 |
| Progress | #45FF63 | #26742D |
| Status | #54FF73 | #246B2B |
| Warning | #FFC857 | #8A5A00 |
| Danger | #FF6B7A | #B32642 |

The selected light text/status/accent roles have calculated contrast of at least 4.72:1 on all three listed light backgrounds. The light border is at least 3.30:1. These token calculations are not a substitute for testing actual rendered states, opacity, disabled controls and filled buttons. Require at least 4.5:1 for ordinary text and 3:1 for meaningful control/focus graphics. The dark base border is decorative grouping; use a contrasting accent or foreground for meaningful control boundaries and focus. Choose explicit on-accent/on-status colors for filled controls instead of assuming the normal foreground works on every fill.

Bundle a licensed native JetBrains Mono font asset and its license, with system fallback for unsupported scripts and emoji. The Web WOFF2 font is not an Android font resource. No runtime font download.

Reuse the nine approved badge geometries in native vector resources or ImageVectors, with one small renderer for the pips. Keep their 32-unit geometry and transparent negative space. Do not parse SVG strings at runtime or generate random procedural variants.

Preserve the solid Lieutenant and Major diamonds, General's filled star, Colonel's wider hexagonal frame and internal bars, and Marshal's tall diamond, shoulders, continuous V, and separate lower wings. Render smooth diagonals and fractional geometry with one contrasting tint per theme and transparent negative space. Do not change badge geometry or introduce pixel-art substitutes.

The shaded purple/green launcher helmet is a separate asset family. Preserve the complete approved launcher artwork, including its background gradient and corner accents as well as the helmet's internal gradients. Keep app UI, rank badges and the splash window background flat. The launcher assets do not authorize glass effects, decorative grids or ornamental telemetry inside the app.

### Launcher and splash

Use [docs/assets/appicon/android](assets/appicon/android/) as the launcher resource source. The layers are 108 dp, with the mark inside the 66 dp safe region. Keep the opaque full-bleed background, transparent foreground, API 26 adaptive definition, and API 33 monochrome layer. Test round, squircle, other launcher masks, and themed icons. [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive)

Replace or remove every competing template launcher reference when integrating, including roundIcon and the existing unqualified resources. Both icon references must resolve to the approved family. With minSdk 26, older legacy-density fallbacks are unnecessary for supported devices. The 512 by 512 Play icon is a store upload, not the adaptive foreground.

Use the [prepared SplashScreen resources](assets/splash/README.md) with AndroidX core-splashscreen and the system SplashScreen API. Install it before super.onCreate, apply Theme.MechaTodo.Starting to the launcher Activity, and use the normal theme as postSplashScreenTheme. Do not create a splash Activity or an in-app imitation. [Native splash integration](https://developer.android.com/develop/ui/views/launch/splash-screen/migrate)

The static icon has a 288 dp canvas and fits the 192 dp safe circle for an icon without a separate background. Keep the approved colored helmet. Use a solid splash background matching the selected app background: #09070D in dark mode and #F5F1F8 in light mode, including the normal window and first Compose frame. Add matching light/night resource variants and system-icon appearance. The existing previews show the dark treatment and intended geometry, not exact platform positioning or completed light-mode acceptance. [System splash dimensions](https://developer.android.com/develop/ui/views/launch/splash-screen)

Dismiss the splash when the first useful app frame is available. If storage validation is slow, show an ordinary Opening screen, then Ready or LocalDataProblem. Any keep-on-screen condition reads only a quick in-memory flag. Never wait on disk inside it, impose a brand timer, or hide an error behind the splash.

## 11. Backup, restore, and privacy

The skeleton currently enables Android backup and must be changed. Q2 selects no application backup, cloud backup, device transfer, import or export. Permanent loss after uninstall, clearing app storage, device loss or unrecoverable corruption is an accepted V1 limitation. Explain it plainly and verify the implemented exclusions before making a shipping claim.

Android's default backup includes app databases and files. On some manufacturers' devices, allowBackup=false does not by itself disable device-to-device transfer. Use the old full-backup rules for older Android and explicit exclusions in both cloud-backup and device-transfer sections of data-extraction-rules. Keep product storage in a no-backup location where supported, and test the actual path and transport behavior. Do not opt into cross-platform transfer. [Android backup behavior](https://developer.android.com/identity/data/autobackup)

The narrow open-helper factory for corruption handling can also select its supported no-backup database directory. Keep all Room files and both drafts under the same policy. Exclude any future product preferences explicitly as well. XML comments or absence of INTERNET permission are not evidence that system backup is disabled.

Test backup and restore on API 26/30 and 31+, plus a supported device-transfer path. Verify that tasks, award history, both drafts and progression do not reappear after reinstall/restore under the no-backup policy. Do not promise recovery that does not exist.

Settings copy, to be verified against the release implementation:

> Your tasks and progress are stored in this app on this device. No account or cloud sync is used. MECHA//TODO does not send your tasks to us.
>
> App backup and transfer are disabled. Uninstalling the app, clearing its storage, losing the device, or an unrecoverable data problem can permanently remove your data.
>
> Deleting a task keeps its XP history without its text. Erase local data removes all tasks, completion awards, the unfinished task draft, and any unfinished edit.

Confirm the backup sentence against the implemented and tested policy before shipping. Prefer "Stored on this device. No account. No cloud sync." in store copy until the stronger claim is justified.

Keep storage app-private. No product feature needs INTERNET, external storage, notification, contact, or location permission. Audit the merged release manifest and transitive dependencies for unexpected permissions or SDK initialization.

Do not add analytics or crash-reporting SDKs. Do not log task text or database arguments. Bundle fonts/assets. Any user-requested privacy/support web link should open externally with no task content appended.

Do not claim application-level encryption, guaranteed anonymity, forensic erasure, or control over the user's keyboard and OS services. The award history has no task text, but its timestamps and opaque identifiers still belong in the data explanation.

Use https://stefan-karger.de/mecha-todo/privacy for the public English policy page, headed "MECHA//TODO privacy policy". Use mecha-todo@stefan-karger.de as the dedicated support alias forwarding to the owner's inbox. The owner must publish the page and activate/test the alias before submission. No marketing website is required.

Bundle the same policy text in Settings for offline reading, with a user-requested external link to the public page. Cover the publisher/contact, tasks, awards, both drafts, nonportable storage, retained XP after deletion, full erasure, external links and voluntary support contact. Distinguish the app's behavior from the separately hosted website and from the user's keyboard/OS services. Verify wording against the final release, not the current skeleton.

A public policy is required even without collected data. Local-only processing is outside Play's data-collection definition, but declarations must describe the actual release and its SDKs. [User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en), [Data safety definitions](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)

## 12. Testing parity and release evidence

Port behaviors and fixtures, not Playwright APIs or IndexedDB schema assertions. Pure Kotlin tests cover deterministic rules. Instrumented tests use actual Room/SQLite for constraints, transactions, restart, corruption, and migrations. Compose tests cover native semantics and input. Device checks cover behavior that a JVM test cannot establish.

| Web evidence | Android acceptance |
| --- | --- |
| todo-text.spec.ts | Exact whitespace set, composition preservation, emoji/code-point counting, empty/1/280/281 boundaries, duplicates, and no truncation |
| rewards.spec.ts | Every ordinal through at least 25, LINK eligibility, mutual exclusion, history retention, gap-aware max ordinal, repeat completion |
| progression.spec.ts | Listed thresholds, every boundary and threshold-minus-one through level 1,000, high reachable levels, safe-integer endpoints, current/span progress |
| ranks.spec.ts and badge.spec.ts | Every base boundary, all 26 designations, final Zulu, pips, deterministic descriptors |
| rank-badge-renderer.spec.ts | Approved native geometry at compact/detail sizes, transparent gaps, unchanged Marshal badge at every designation |
| repository.spec.ts | Normalized insert, duplicate text, backward/equal clocks without reordered lists, last successful edit wins, missing targets, exact page sizes |
| completion-repository.spec.ts | Same-todo and different-todo concurrent writers, unique awards and daily ordinals, reopen above capacity, newest re-completion order, multi-slot promotion after Active and Standby completion |
| delete-repository.spec.ts and delete-undo.spec.ts | Delete every status, retain awards, latest offer by commit order, deadline at invocation, failed Undo consumption, restore exact order/status, preserve promotions |
| database.spec.ts and startup-erasure.spec.ts | Schema and record failures block Ready; no automatic deletion; safe metadata recovery; migration rollback; retry; confirmed atomic reset |
| application.spec.ts and todo-row-actions.spec.ts | Durable composer and edit drafts, independent logical draft failures, guarded editing of all statuses, pending feedback, failed writes, no duplicate rows during delayed refresh, saved mutation with stale read-only view |
| progression-settings-badges.spec.ts and designation-identity.spec.ts | HUD current XP versus Lifetime XP, simultaneous LINK/COMBO, truthful ordinal-based hints including gaps, all names and milestones, committed feedback priority, derived identity changes without award rewrites |
| release-gates.spec.ts and visual-review.spec.ts | One column, long content, dialogs, focus, enlarged text, accessible targets and feedback, network/log privacy, representative visual states |

Add Android-specific acceptance:

- Cold/warm/hot startup on API 26, 31, and current target devices. No second splash, forced wait, or light-background flash.
- Rotation, same-task restoration, background/foreground, real process termination/relaunch, and normal app finish. Activity recreation alone is not a process-death test.
- Kill before commit and after commit but before feedback. First completion remains exactly once; pending feedback and Undo do not resurrect.
- Monotonic Undo expiry across clock changes, rotation, background time and accessibility timeout extension. Test accepted taps that wait beyond the deadline for a writer and out-of-order delivery of successful deletion results.
- Cross midnight while waiting for a transaction, change timezone while the app is visible, daylight-saving spring/fall, leap day, year boundaries, and extreme supported clock inputs.
- Disk-full/write rejection, unreadable file, existing empty/foreign file, physically corrupted database, unsupported schema/rules, malformed row beyond the first page, and failure during migration. Assert the database is not automatically replaced.
- Raw SQLite storage-class mismatches in authoritative integer/text columns, including values typed getters or aggregate queries could coerce. Accept valid stored integers after affinity conversion; classify optional-draft type failures independently.
- Corruption-callback tests through the actual selected Room open path. Merely throwing an exception from a fake repository does not test preservation.
- Cancellation and refresh failure after a known commit; pending draft writes racing Add/Save/Cancel/reset; stale Undo after reset; two repository connections with contending completions.
- Restored inline edits in collapsed sections and beyond the first history page; changed/missing targets; independent malformed composer/edit slots; durable discard failure and warning; Save succeeding before a failed or interrupted follow-up action.
- Opening and saving another editor while a malformed or missing-target draft remains protected; successful Add/Save consumes submitted input despite failed refresh and clears its older valid stored draft by ownership rather than raw-text equality.
- Repeated launcher intents return to the existing app window and preserve input. Window resize and theme changes do not create a competing draft owner.
- Rolled-back erasure retains current drafts; committed erasure clears old UI immediately even when refresh fails. No stale action or delayed draft write survives the dataset change.
- A real file-backed reopen and an install-over-old-version migration test for every supported released schema. In-memory Room tests alone do not cover durability.
- Keyboard/IME composition, touch, mouse, TalkBack, Switch Access, minimum targets, 200% text, display enlargement, and disabled animations.
- Gesture and three-button navigation, cutouts, caption bars, landscape with IME, split screen, tablet width, fold/unfold, and resizing without losing entered text.
- Backup exclusion and restore behavior, including award history and both drafts.
- Offline cold start and task operations, release manifest/network/log audit, themed launcher masks, and native splash rendering.

Use in-memory Room and constructor-supplied clocks/IDs where they are sufficient. Add file-backed instrumentation where the failure requires it. A repository interface is justified only if a concrete test needs substitution that these tools cannot provide.

Use deterministic native screenshot fixtures for empty, ordinary, expanded, completion reward, every badge family, long designation, Settings, error, and confirmation states. Seed awards and derive progression for store captures. Some Web visual tests deliberately inject impossible high-level/low-XP screen states to stress layout; those are useful layout probes, not valid store screenshots.

### Required verification matrix

Record actual device/emulator names, OS builds, window sizes and commands in the acceptance checklist. Provision the following configurations during test setup; unavailable coverage remains a release blocker rather than an inferred pass.

| Configuration | Required coverage |
| --- | --- |
| API 26 compact phone | Minimum-platform install/startup, system splash compatibility, file-backed Room, launcher masks, narrow layout and offline use |
| API 30 phone | Older backup-rule path, gesture/three-button navigation, both theme modes, process death and IME |
| API 31 phone | System SplashScreen boundary, newer backup/transfer rules, theme transitions and system bars |
| API 37 phone | Target-platform behavior, repeated launches, predictive Back where available, full task/Settings flow |
| Large tablet and resizable window | At least 600 dp and 840 dp widths, portrait/landscape, caption bars, mouse/keyboard, narrow split-screen resizing |
| Foldable | Fold/unfold and continuity of text, editor, scroll and Undo deadline |
| 16 KB-capable environment | Final bundle/native-library audit and install/run compatibility on a real or emulated 16 KB configuration |
| Physical Android device | TalkBack, Switch Access, real IME composition, launcher/splash appearance and release smoke test; owner also completes Play device verification on an eligible device |
| Supported backup and device-transfer paths | Attempt backup/reinstall/restore/transfer and verify absence of tasks, awards and both drafts under the selected no-backup policy |

Across relevant configurations test both light and dark appearance, 200% font scale, enlarged display size, long task text, long rank designations, disabled animations and the IME consuming most of a short window. Controls must remain reachable by scrolling; simultaneous visibility of every region is not required.

Use valid deterministic history fixtures of 1,000 todos with 10,000 retained awards and 10,000 todos with 100,000 retained awards. Include orphaned awards, reopened rewarded tasks and deep history pages. These are verification sizes, not user-facing storage limits. Both must pass complete off-main-thread validation, file-backed reopening, mutations and history loading without an ANR, crash or out-of-memory failure. Stream award validation and keep only the queried UI prefixes instead of retaining all awards in screen state. Record startup, transaction, refresh and memory measurements on the named configurations; optimize a demonstrated bottleneck before adding a cache or a new paging framework. No latency claim may be published without corresponding device evidence.

Before release, run the native unit suite, Android lint, instrumented Room and Compose tests, release bundle build, migration fixtures, accessibility/device checks, and a release manifest/dependency audit. Keep a concise acceptance-to-test checklist like Web V1's. Add tests for actual risks and behavior; do not build a general testing platform first.

## 13. Settled decisions and document precedence

The [decision log](../.scratch/native-v1-design/decision-log.md) records all thirty answers. The following resolves the former proposal table and names the explicit differences from Web V1.

| Area | Settled native contract |
| --- | --- |
| Delivery | Complete native application and Play submission readiness; publication is separate; optional press/social campaigns are excluded |
| Dataset and recovery | One dataset and one app window per OS user/profile; no backup, transfer, import or export; accepted permanent-loss limitation |
| Undo | Five-second base adjusted for accessibility; monotonic deadline includes background time; timely tap fixes eligibility before writer wait; separate labelled control |
| Editing | Inline explicit Save/Cancel, composition-aware Done/Enter, Escape cancellation; no save on blur; changed-edit interruption guard |
| Drafts | Separate optional composer/edit rows; both survive restart to their last committed values; logical draft failure is nonblocking and never silently overwrites malformed records |
| Restored edit | Reveal current section and editor ahead of scroll/disclosure defaults, without opening the keyboard; never resurrect a missing task |
| Failed discard | Honor cancellation in memory and warn that a draft not cleared from storage may return after restart |
| Clock | Clamp update metadata only; preserve actual award/completion times and stored day keys; reject an unsupported live clock without calling healthy history corrupt |
| Standby completion | A changed completion promotes oldest Standby tasks into available Active slots, including when the completed task was in Standby |
| Daily HUD | LINK and one-away COMBO hints coexist; COMBO predicts the next actual ordinal, including valid gaps; foreground/date refresh changes display only |
| Commit/read failures | Distinct committed outcome and stale read-only view; no repeated Add; committed erasure removes old UI; rolled-back erasure preserves typed drafts |
| Numeric bounds | Keep the Web safe-integer domain and guard additions/increments before commit; prove progression parity at supported boundaries |
| Theme | Branded light/dark palettes follow system appearance; no wallpaper-derived colors or extra theme preference; match splash and system bars |
| Badge and launcher identity | Fixed smooth badge geometry with one contrasting tint; preserve the whole approved launcher family including background gradients; flat app UI |
| Navigation | One task destination with Settings containing progression; no separate progression screen, dashboard or navigation rail |
| Add keyboard | Touch success hides the software keyboard; hardware entry keeps focus; failures retain input |
| Brand and package | MECHA//TODO in the launcher and app; Mecha Todo only where platform rules require a plain name, currently the Play title; keep stefankarger.mechatodo |
| Version and publisher | Initial version 1.0, versionCode 1; publisher Stefan Karger; new personal Play developer account |
| Market and language | Free, no purchases/ads; English app and store material; ages 13+; all supported distribution countries |
| Privacy/contact | Public policy at stefan-karger.de/mecha-todo/privacy, offline copy in Settings, support alias mecha-todo@stefan-karger.de |
| Reference evidence | Preserve the recorded newline/toolchain limitation; do not claim a clean untouched Web release gate or a native release pass |

Use the read-only Web reference for inherited behavior and approved geometry. The explicit native decisions here take precedence for the Android differences. The store and press brief follows this specification for badges, Settings progression, English-only scope, version 1.0, recovery claims and release identity. Its optional press/social concepts are outside V1 delivery. Asset READMEs describe prepared resources for the existing app module; product integration remains pending.

The user has confirmed shared understanding. This specification is reconciled into docs/IDEA.md, with dependency-ordered work in the implementation plan. Confirmation completes the design interview; it does not mean that application implementation, account creation, payment or publication has occurred.

## 14. Google Play and launch preparation

Policy details were checked against official sources on 2026-09-22 and 2026-09-23. Recheck them when submitting and use the actual Play Console requirements.

### Publisher and account path

The user supplied a Play Console screenshot showing that the old account was closed for inactivity on 2021-10-20 and that reactivation is unavailable for that account. This is not evidence of a policy termination. Q30 selects a new personal developer account. Google permits a new registration after dormant-account closure; do not promise reuse of the old Google login. [Enforcement process](https://support.google.com/googleplay/android-developer/answer/9899234?hl=en)

The owner registers and controls the new account, currently a US$25 one-time fee, and completes identity/contact verification. New personal accounts also require device verification using the Play Console app on an eligible non-rooted physical Android device running Android 10 or later. These are owner tasks; do not place identity documents, account credentials or signing secrets in repository files or interview notes. [Registration](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en), [device verification](https://support.google.com/googleplay/android-developer/answer/14316361?hl=en)

Use Play App Signing and an owner-controlled upload key. During release setup, confirm whether an appropriate key already exists before generating a new one. Keep any keystore and passwords outside version control and document owner-controlled recovery. A lost or unusable account/key blocks submission, not ordinary app development. Confirm the application ID/package registration before the first upload and keep it stable afterward.

| Requirement | Application-specific action |
| --- | --- |
| Target API | Current phone/tablet new-app and update requirement is API 36 or higher from 2026-08-31. Existing targetSdk 37 exceeds it; retain it and test its behavior changes. [Target API policy](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en) |
| Release artifact | Publish a signed Android App Bundle, configure Play App Signing, protect the upload key, and keep versionCode increasing. Freeze application ID before release. [App Bundles](https://developer.android.com/guide/app-bundle), [Play setup](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) |
| 16 KB devices | Inspect the final bundle for native libraries, including transitive ones, and test 16 KB compatibility. The current page states that API 35+ apps must support it and gives 2027-02-01 as the update enforcement date. Do not copy an older deadline into release plans. [Page-size guidance](https://developer.android.com/guide/practices/page-sizes) |
| Data safety | Complete the form using the final SDK/permission/backup audit. "No data collected or shared" is a proposed answer contingent on the implementation, not an automatic consequence of using Room. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) |
| Privacy policy | Publish the agreed URL, verify the support alias, and bundle readable policy text in Settings. Explain local data, both drafts, retained XP history, erasure, backup policy and developer contact. [User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en) |
| Console declarations | Complete content rating, target audience, ads, app access, Health and Financial features declarations truthfully, including the no-features answers where applicable. The app has no ads or login. Confirm account verification and distribution-country obligations. Target ages 13+ do not substitute for the actual country/age policy checks. [Health declaration](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en), [financial declaration](https://support.google.com/googleplay/android-developer/answer/13849271?hl=en), [target audience](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en) |
| Testing eligibility | The new personal account needs a closed test with at least 12 testers continuously opted in for 14 days, followed by a production-access application. Recruit real participants, collect feedback and record resulting changes. Passing the elapsed-day count alone does not guarantee production approval; the old account's age gives the new registration no exemption. [Testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB) |
| Listing text | Prefer MECHA//TODO where allowed. Android launcher labels accept it, but current Play metadata policy prohibits repeated special characters in titles, so use the user's authorized Mecha Todo fallback for the Play title. Limits are 30 characters for name, 80 for short description and 4,000 for full description. Remove outdated pixel-badge wording and unsupported privacy/medical claims. [Application label](https://developer.android.com/guide/topics/manifest/application-element#label), [metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842?hl=en), [listing limits](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en&rd=2) |
| Package registration | Verify the new package's registration and publisher identity in Play Console before submission. Play automatically registers new apps through its flow; no separate Android Developer Console account is needed for this distribution path. [Play registration](https://developer.android.com/developer-verification/guides/google-play-console) |
| Store artwork | Reuse the approved 512 by 512 Play icon. Produce a 1024 by 500 feature graphic and truthful screenshots. The brief's six portrait images are the chosen narrative, not a claim that Google universally requires exactly six. [Preview assets](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB) |

Keep the six-image narrative: focus, XP, rank, Active/Standby, momentum, privacy. Use real native UI and valid deterministic records. Include truthful light and dark presentation in the asset set, with native phone/tablet evidence appropriate to the selected supported devices. Keep clean originals and annotated exports outside runtime resources. Do not produce shipping screenshots from the current skeleton or leave developer fixture controls in the release. The feature graphic should complement the listing and avoid simply duplicating the adjacent app icon.

The approved icon is available. The native screenshots, 1024 by 500 feature graphic, final English listing, policy publication and support-alias activation remain deliverables with the choices settled above. Do not create optional press/social assets or claim these deliverables already exist.

"ADHD-friendly" can describe the interaction approach. Keep the app in productivity positioning and do not claim treatment, clinical benefit, dopamine effects, or guaranteed focus. The press brief is not evidence for such claims.

### External release prerequisites

| Owner | Task | Completion evidence |
| --- | --- | --- |
| Publisher | Register and verify the new personal account, verify an eligible physical device, and confirm package ownership | Console shows the account/device/package ready for the required testing/upload flow |
| Publisher | Activate mecha-todo@stefan-karger.de and publish the policy at the agreed URL | Test mail received; public English page loads without login and matches the bundled policy |
| Publisher with implementation support | Establish upload-key ownership and recovery; configure Play App Signing | Signed bundle accepted by the intended app entry; recovery details stored privately by the owner |
| Publisher and recruited testers | Run the required closed test, document use/feedback/fixes, then request production access | Console satisfies the test requirements and grants production access |
| Implementation owner | Complete native acceptance, manifest/dependency audit, release bundle and store assets | Recorded passing evidence and submission-ready artifacts, without developer fixtures or secrets |

These tasks have explicit owners and pass conditions. Their future completion is not an unresolved product decision and must not be described as already verified. Actual publication requires a separate user instruction.

## 15. Implementation order

1. Establish the build/test baseline and pin compatible stable Room/KSP/lifecycle/splash dependencies without changing the agreed build stack. Export native schema v1 and prove the selected nondeleting SQLite open path before feature work. Begin the owner's account and policy-hosting prerequisites in parallel with implementation when authorized.
2. Implement pure Kotlin rules with parity fixtures for text, rewards, progression, rank, capacity, clock bounds and the explicitly changed HUD hint contract.
3. Implement Room, the concrete repository, authoritative and optional-draft validation, safe startup, transactions, migration fixtures and confirmed erasure. Verify these through actual SQLite, including file preservation, before relying on UI behavior.
4. Add the task screen and ViewModel with consistent snapshots, both draft slots, guarded row actions, separate Undo feedback, stale read-only recovery and lifecycle restoration.
5. Integrate Settings, offline privacy text, accessibility, window/IME behavior, branded light/dark palettes, approved vectors, launcher branding and matching system splash resources. Review native screenshots against the selected identity and contrast requirements.
6. Complete device/failure/history testing, produce the native store assets, and verify declarations against the release bundle. Complete the closed test and production-access application as the Console requires. Prepare the submission handoff; do not publish automatically.

Each step should leave a buildable application and behavior-focused evidence. Nothing in this sequence requires extra Gradle modules, a DI framework, generalized navigation, or an extensible game engine.
