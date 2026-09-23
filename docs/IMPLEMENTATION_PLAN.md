# MECHA//TODO native Android implementation plan

Status: ready for implementation, based on the design confirmed on 2026-09-23. Implementation has not started. No native acceptance gate is marked as passed by this document.

Build the application described in [IDEA.md](IDEA.md), then prepare it for Google Play submission. That specification is the behavior contract. The [local specification](../.scratch/native-v1-design/spec.md) and [decision log](../.scratch/native-v1-design/decision-log.md) preserve the thirty-question interview and final confirmation. Actual publication is a separate action.

## 1. Scope and working rules

The deliverable is a tested native task application with exact-once XP, Active/Standby/Completed, editing, deletion and Undo, durable unfinished input, Settings, local erasure, automatic branded light/dark appearance, and the approved identity. It includes a signed release candidate, English Play material, privacy/support readiness, and evidence for the required submission checks.

The application is free, has no ads or purchases, and targets teenagers and adults. It has no account, backend, synchronization, analytics, reminders, import/export, app backup or device transfer. The publisher uses a new personal Play developer account. Optional press kits, social campaigns and a marketing website are outside delivery.

- Preserve `stefankarger.mechatodo`, minSdk 26, compileSdk/targetSdk 37, initial versionName `1.0` and versionCode `1`. Subsequent uploaded builds need increasing version codes.
- Keep one `:app` module, one task-screen ViewModel, one concrete repository, Room, pure rule functions and manual dependency injection. Follow [KISS_GUIDELINES.md](KISS_GUIDELINES.md).
- Treat [_reference/mecha-todo](../_reference/mecha-todo/) as read-only. Run reference tooling only in a disposable copy outside that directory. Port behavior and geometry, not browser architecture.
- Apply the explicit Android differences in IDEA sections 3, 4, 8, 9, 10 and 13. In particular, LINK and upcoming COMBO coexist; system appearance selects the branded palettes; update metadata tolerates clock rollback.
- Keep issues and tickets in `.scratch/` if later requested. This plan defines delivery phases; it does not publish tickets to an external tracker.
- Update each phase's evidence as implementation proceeds. A planned test or an unavailable device is not a passing result.

No product decision remains open from the interview. Dependency compatibility, device behavior and Play eligibility still require implementation evidence. Resolve those checks within the approved contract. If evidence makes that contract impossible, record the conflict before changing product behavior.

## 2. Starting point and dependency order

The app currently renders the Android template. It has no product repository, Room schema, ViewModel, task UI or native parity tests. Backup is enabled, launcher resources are templates, and the Compose theme permits wallpaper colors. Prepared launcher and splash assets exist under `docs/assets/` but are not integrated.

The existing stack is AGP 9.4.1, Gradle 9.6.0, Kotlin Compose plugin 2.2.10 and Compose BOM 2026.02.01. The daemon uses Java 25; application Java compatibility is 11. Independently versioned AndroidX libraries need compatibility review when required dependencies are added. This plan does not claim that the current stack or a future dependency selection has passed a clean build.

| Phase | Result | Prerequisites | Owner |
| --- | --- | --- | --- |
| 01 | Build and test foundation | None | Implementer |
| 02 | Pure rules with reference parity | 01 | Implementer |
| 03 | Protected Room opening and schema | 01; domain validators from 02 before its exit | Implementer |
| 04 | Transactional repository and consistent reads | 02, 03 | Implementer |
| 05 | Screen state, drafts, lifecycle and Undo | 04 | Implementer |
| 06 | Native task interaction | 05 | Implementer |
| 07 | Settings, theme, accessibility and identity | 06 | Implementer |
| 08 | Device, failure and release-candidate acceptance | 07 | Implementer, with physical-device support from owner |
| 09 | Store assets, closed test and submission handoff | 08 plus external prerequisites | Implementer and publisher |

Rule work and storage preparation can overlap after phase 01. Asset conversion and policy drafting can begin before phase 07, but their acceptance depends on the integrated app. Owner account and support-page work can proceed alongside development. The closed-test clock starts when eligible testers opt into the required test, not when account registration begins.

Each phase leaves a buildable app and tests for its actual behavior. Do not postpone transaction, corruption or state-machine tests until the final device pass.

## 3. Phase 01: establish the build and test foundation

Work in the version catalog, app Gradle configuration, application container and relevant test source sets.

1. Record the starting revision, toolchain and existing build results. Keep existing unrelated workspace changes intact.
2. Select and pin compatible stable Room runtime/compiler/testing, KSP, lifecycle ViewModel/Compose, coroutine-test and core-splashscreen dependencies. Align older Activity/Core/lifecycle/test dependencies where compatibility requires it. Check official release notes and prove resolution with the existing AGP Kotlin configuration; do not add a second Kotlin Android plugin.
3. Establish the shallow `domain/`, `data/`, `ui/` and `ui/theme/` packages only as files become necessary. Add the process-owned container and a manual ViewModel factory when their first consumers exist.
4. Configure Room schema export to `app/schemas/` and make exported schemas available to instrumented tests. Use the existing JVM, Android and Compose test source sets.
5. Provide controllable clocks, timezones, IDs and elapsed time for behavior tests. Use ordinary constructor arguments and test fixtures, without a general test framework or production service interfaces.
6. Create `docs/release-checklist.md` during implementation. Map IDEA acceptance areas to test names, commands, artifact versions and actual device configurations. Create local run evidence under `.scratch/native-v1-design/verification/` without task content, credentials or identity documents.

Exit when a clean debug build, unit-test task and Android lint run succeed; a configured emulator runs the instrumented test runner; and selected dependencies work together. Record any pre-existing failure before changing code. Do not mark an emulator or API as covered merely because it is installed.

## 4. Phase 02: implement pure rules and reference parity

Implement small Kotlin functions under `domain/`. Use IDEA sections 3 and 4 and the reference domain/config files as the contract.

- Implement the exact ECMAScript whitespace set, code-point count, 1 through 280 limit and unchanged validation messages. Keep raw invalid input and preserve Unicode composition. Duplicate task text is valid.
- Implement status/order rules, soft Active capacity, reward eligibility, the V1 award components, retained XP and safe arithmetic. Completion promotion includes a completed Standby task; startup, edit, reopen and Undo do not backfill.
- Implement the progression curve, JavaScript-compatible rounding, bracketing and binary search across the supported safe-integer range. Use Long for reachable levels as well as persisted quantities. Guard intermediate thresholds beyond Long without clamping search to stored XP limits.
- Implement the rank/designation/pip tables, final Zulu milestone and feedback priority. Do not persist derived identity or progress.
- Implement strict day keys, transaction-time calendar inputs, DST-safe yesterday, clock bounds and clamped update metadata. Stored day keys remain immutable.
- Implement independent LINK and one-away COMBO display rules. Use maximum daily ordinal, including valid gaps, rather than today's task count.

Commit deterministic golden fixtures with source revision and generation instructions. Generate them from the read-only reference or a disposable copy using its pinned toolchain where available. Preserve the earlier newline/toolchain limitation recorded in IDEA; do not present that historical run as a clean release certification.

Exit tests cover all whitespace/code-point boundaries; reward ordinals 1, 5, 10, 15, 20 and beyond; ordinal gaps; LINK with timezone/DST changes; rank/designation boundaries; capacity growth; high reachable levels; the maximum supported XP; and just-below/at/above progression thresholds. Include invalid clocks and exhausted counters/XP without classifying trusted existing history as corrupt.

## 5. Phase 03: establish protected storage

Implement the five-table schema, DAO, validation and narrowly scoped framework SQLite open-helper adapter under `data/`. This phase must pass before task features rely on storage.

1. Create `mecha-todo.db`, schema version 1, with `todos`, `completion_awards`, `app_meta`, `composer_draft` and `edit_draft` exactly as specified. Add the required unique/order indexes. Export the actual Room schema.
2. Keep one valid metadata row and zero or one row per draft slot. Do not add an award-to-todo foreign key, cascading history deletion, award upsert, or an edit-draft foreign key that removes unresolved text.
3. Inspect every authoritative value's raw SQLite storage class before Room typed mapping or SUM/MAX. Then validate normalized values, safe bounds, uniqueness, day keys, award totals, supported rules, counters and cross-record relationships. Validate optional drafts independently after authoritative trust is established.
4. Before automatic creation, distinguish a new dataset from an existing empty, foreign or damaged file. Never replace missing metadata in an existing dataset. Run `quick_check` and complete streaming domain validation off the main thread.
5. Prove that the selected open-helper preserves files on corruption, failed opening and unknown schema/rules. Override the deleting corruption default and disable data-loss recovery. Preserve Room's normal creation/migration callbacks. Do not catch an exception and silently open a different database.
6. Place the database and sidecars in the supported app-private no-backup location. Disable application backup and configure both older backup rules and newer cloud/transfer exclusions. Verify the actual path used by Room and by confirmed erasure.
7. Add Opening, Ready and LocalDataProblem outcomes. Retry inspects the same storage. Diagnostics contain categories only, without records or SQL arguments.

Use actual file-backed Room/SQLite tests for valid restart; malformed authoritative values beyond the first page; REAL/TEXT/BLOB type mismatches; valid affinity-converted integers; malformed and missing-target drafts; absent/duplicate metadata; existing empty/foreign files; physical corruption; and unsupported versions. Inspect file preservation before and after failed opening without requiring byte identity where SQLite legitimately manages its journal.

Commit a native v1 fixture with orphaned awards and reopened rewarded tasks. There is no Web schema import or native v0 migration. Use test-only migration scenarios to prove rollback and preservation, then add production migration paths only when a released native schema changes. Validate transformed authoritative values inside any migration transaction.

Exit when the real open path preserves data in all failure fixtures, authoritative validation cannot be bypassed by numeric coercion, optional logical draft problems stay nonblocking, and schema export/reopen tests pass on supported SQLite configurations. Backup XML review alone does not close the transport verification in phase 08.

## 6. Phase 04: implement repository transactions

Keep one concrete `TodoRepository`. Use suspending Room transactions and SQL constraints as the authority; a local mutex only coordinates process-local writes, reset and connection lifetime.

- Implement Add, Save, desired completion state, reopen, delete and exact-snapshot Undo with the transaction contents in IDEA section 6. Repeated desired-state requests are unchanged results. Missing-target edits never recreate tasks.
- Insert an award once, preserve it through all ordinary task actions, allocate daily ordinals from their maximum and compute promotions using committed XP. Sample time and timezone after waiting for the writer. Return before/after progression from the committing transaction.
- Guard additions and counters before commit. Clamp updatedAt without altering actual completion/award instants. Retry a real uniqueness race only by bounded re-execution of the whole transaction.
- Read Active rows, counts, requested history prefixes, XP and day indicators in one consistent read transaction. Publish one snapshot after Room invalidation. Draft changes alone must not trigger complete task snapshots.
- Load 20 plus one history rows, preserve each visible prefix limit across mutations, and query collapsed history only when needed. Exactly 20 rows produce no load-more control.
- Return committed outcomes separately from refresh results. A known saved write followed by a failed read enters a labelled stale read-only state, with Retry and confirmed erase available. Consume submitted input in the later state layer; never suggest repeating a successful Add.
- Implement healthy erasure as one transaction across all five tables. Implement confirmed erasure of unreadable storage against the exact configured file and sidecars after closing handles. Validate the current clock before destruction. Report partial file-reset failure accurately.
- Introduce a small dataset-session identity and commit-order identity for ephemeral work. Full reopen/reset invalidates prior Undo and queued work. Never persist a command replay system.

Exit with file-backed tests for rollback at transaction stages, immutable awards, retained XP, ordering, promotion, exact Undo, ID/order conflicts, two contending repository connections, calendar changes while waiting for the writer, safe-limit refusal and consistent snapshots. Inject a read failure after a known commit, a reset rollback and a reset commit followed by failed refresh. A fake DAO alone cannot establish these guarantees.

## 7. Phase 05: coordinate screen state, drafts and Undo

Implement `TodoViewModel` with lifecycle-aware StateFlow collection and small Compose saveable presentation values. Keep task data and arbitrary text out of saved-instance-state bundles.

1. Load the last committed composer/edit drafts after startup validation. Restore an edit against the task's current state. Preserve missing-target or malformed saved text with an explicit discard action; never recreate the target.
2. Serialize draft persistence, coalesce obsolete queued text and avoid indefinite postponement during continuous typing. Attempt a best-effort background flush. Use slot/task/session ownership and generations to prevent stale writes after Add, Save, Cancel or erase.
3. Let valid Add/Save succeed from in-memory input despite earlier draft-save failure. Clear a matching valid draft atomically with the task mutation, even when its stored text lags. Preserve protected malformed/unresolved records, including in the submitted slot.
4. Consume a known successful Add's composer or Save's editor even when refresh fails. Preserve unrelated input. Suspend all task/draft writes while the snapshot is stale. A committed erase immediately clears old visible data and both drafts; rollback retains current typing.
5. Honor Cancel/Discard in memory if durable clearing fails, permit the requested continuation and show the agreed persistent warning. Ordinary cancellation of a different memory-only editor must not delete a protected saved record.
6. Coordinate changed-editor Save/Discard/Keep editing decisions. Save then completion/deletion has two distinct results. Failed validation, save or subsequent refresh cancels continuation; process restart never replays it.
7. Implement the newest successful deletion offer by commit order, with an accessibility-adjusted 5-second base and one elapsedRealtime deadline. Start when the committed outcome becomes an offer, including in the background. A timely tap fixes eligibility before the writer wait; consume the offer before restore.
8. Keep deletion/Undo separate from the latest ordinary status. Ordinary status has no queue and cannot reset Undo. Rotation keeps the deadline; background time counts; process restart, task finish, full reopen and reset discard it.
9. Refresh daily indicators after mutation, on foreground entry, on clock/timezone/date changes and at the next local midnight while visible. Use no service, alarm permission or persistent scheduler.

Exit with controlled coroutine tests for out-of-order result delivery, expiry, foreground return, eligible Undo waiting on a writer, one-time feedback, draft races, failed discard, protected slots and stale recovery. Use real Room integration for draft/task atomicity and reset races. Reserve actual process-death proof for device tests; Activity recreation alone is insufficient.

## 8. Phase 06: build the task interaction

Use one task destination, a compact progression HUD, one LazyColumn with stable task keys, and a composer/feedback area. Follow IDEA section 9 for the detailed action and layout contract.

- Render Active, Standby and Completed with the agreed defaults, counts, empty states and explicit load-more controls. Wrap long text. Keep all controls available without relying on swipe or long press.
- Add one inline editor with visible Save/Cancel, composition-aware IME Done and hardware Enter, and Escape cancellation. Blur, Settings and section collapse preserve it. Back dismisses the IME first, then applies the changed-edit guard.
- Restore a valid unfinished edit by opening its current section, fetching enough history and scrolling it into view. Do not automatically open the IME. A restored Settings overlay stays above it.
- Implement touch Add dismissal and hardware-entry focus retention according to the initiating input. Preserve input/focus on failure. Paste and multilingual composition must reach normalization intact.
- Show immediate per-row completion feedback while the write runs, without optimistic XP, counts or promotion. Coordinate conflicting actions on that row and keep unrelated rows usable. Honor disabled animations for the short visual hold.
- Render Opening, LocalDataProblem, stale read-only content, persistent draft warnings, validation and committed feedback explicitly. Keep Undo labelled with the deletion it restores.
- Keep a centered single column on wide windows. In short windows or with a large IME, allow the hierarchy to scroll so all actions remain reachable. Do not force portrait or reduce text size to preserve a fixed composition.
- Configure repeated launches to reuse one app task per OS profile. Verify this with launches and window changes, not just a singleton repository.

Exit with Compose tests for complete task workflows, guarded editing, sections/pagination, focus after row removal, validation, failure recovery, restored deep editors and both input paths. Capture initial native states for review against the reference. Do not use these unfinished captures as store assets.

## 9. Phase 07: integrate Settings, appearance and identity

Complete the approved visual and platform behavior in IDEA sections 9 through 11.

1. Put progression, current/next identity, versions, device-local data information, the offline privacy policy, support address and confirmed erasure in Settings. Use a full-window presentation on compact windows and an opaque constrained dialog on larger ones. Preserve overlay/focus/Back order without a second ViewModel or navigation framework.
2. Implement the specified light/dark semantic palette and automatic system appearance. Remove wallpaper-derived dynamic colors and add no theme preference. Preserve input and Undo across a mode change. Check actual foreground/fill, border/focus, error and disabled-state contrast.
3. Bundle licensed JetBrains Mono with its license and system script/emoji fallback. Convert the nine fixed approved badge geometries to native vectors and render pips. Preserve smooth fractional geometry and use one contrasting tint per mode.
4. Integrate the [launcher resources](assets/appicon/README.md), including full-color background gradients and themed monochrome art. Replace all template icon and roundIcon references. Use `MECHA//TODO` as the launcher label; the Play title uses `Mecha Todo` under current metadata policy.
5. Integrate the [system splash resources](assets/splash/README.md) before `super.onCreate`. Match the splash, ordinary window, system icons and first Compose background in light and dark modes. Keep the colored helmet. Show Opening for slow validation rather than extending a brand timer.
6. Keep edge-to-edge and adjustResize, with one owner for each system/cutout/caption/IME inset. Check gesture and three-button navigation without duplicate bottom padding.
7. Supply 48 dp minimum targets, independent row-action semantics, heading/disclosure states, progress semantics, visible keyboard focus and polite one-time announcements. Hide duplicate badge/decorative separator speech. Verify controls remain reachable at 200% font scale and enlarged display size.
8. Write the final English policy and data-loss copy from actual implementation behavior. Bundle it offline. Link the public policy and support address through user actions without appending task data. Keep website/support handling distinct from the app's device-local behavior.

Exit with native visual comparisons for all badge families, long designations, both themes, normal/error/confirmation states and launcher masks. Verify Settings/erase flows and reduced animations. Run the local launcher consistency script when integrating assets; do not regenerate approved art without a concrete correction.

## 10. Phase 08: complete acceptance on devices and failure fixtures

Populate the full verification matrix from IDEA section 12. Record actual OS builds, sizes and devices, not only broad labels such as "tablet tested".

| Configuration | Required evidence |
| --- | --- |
| API 26 phone | Minimum install/startup, file-backed Room, splash compatibility, narrow UI, offline cold start |
| API 30 phone | Older backup path, process death, IME, navigation modes, both appearances |
| API 31 phone | System splash boundary, newer backup/transfer exclusions, theme transitions |
| API 37 phone | Target behavior, predictive Back where available, repeated launches, complete task and Settings flows |
| Tablet/resizable windows | At least 600 dp and 840 dp widths, orientation changes, caption bars, mouse/keyboard and narrow split-screen |
| Foldable | Fold/unfold continuity for text, editor, scroll and the original Undo deadline |
| 16 KB environment | Final artifact/native-library inspection and install/run result on a real or emulated 16 KB configuration |
| Physical device | TalkBack, Switch Access, real composing IME, launcher/splash and release smoke test |
| Backup and transfer transports | Actual attempts showing tasks, awards and both drafts absent after backup/reinstall/restore/transfer |

Test real process death before commit, after commit before feedback, during draft persistence and after cancellation. Compare same-task restoration with a fresh task. Confirm no award, pending action, destructive confirmation or Undo offer replays.

Exercise file-backed fixtures containing 1,000 todos/10,000 retained awards and 10,000 todos/100,000 retained awards. Include orphan awards, rewarded open tasks and deep history. Record validation/startup, transaction, refresh and memory measurements on named configurations. Require no ANR, crash or out-of-memory failure. Stream validation and keep only queried UI prefixes; optimize measured problems before adding caches or Paging.

Run both themes, 200% font scale, enlarged display size, long/mixed-direction tasks, long identities, disabled animations and short windows with an IME. Controls may require scrolling but must remain reachable. Inspect actual focus and TalkBack announcements as well as automated semantics.

Audit the merged release manifest, dependencies, packaged assets and logs. Verify no analytics/crash SDK, unexpected permissions, runtime font downloads, task-content diagnostics, developer fixture controls or signing secrets. Audit backup separately from network permissions. Verify release resource linking and the same Room opening behavior in the release variant.

Exit only when required evidence passes for the release candidate. Record defects and rerun affected checks after fixes. Missing mandatory configurations remain release blockers with named owners. Do not repeat an already passing suite without a relevant change or unresolved concern.

## 11. Phase 09: prepare the store submission

Use [IDEA section 14](IDEA.md#14-google-play-and-launch-preparation) for the verified policy baseline and official links. Recheck the actual Console and current official requirements at submission time. Policies and account approval are external facts, not guarantees made by this plan.

- Produce a signed Android App Bundle with an owner-controlled upload key and Play App Signing. Confirm package ownership before the first upload. Keep keystores, passwords, identity documents and recovery details out of the repository.
- Retain versionName `1.0` for the launch candidate; increase versionCode for each uploaded replacement as required. Record which code, build revision and signing identity the acceptance evidence covers.
- Prepare the approved 512 by 512 icon, a 1024 by 500 feature graphic and six English phone screenshots covering focus, XP, rank, Active/Standby, momentum and privacy. Include truthful light/dark presentation and tablet material appropriate to the supported listing. Six is the chosen narrative, not a universal Play minimum.
- Capture real native UI from valid deterministic records. Keep clean captures and annotated exports outside runtime resources. Derive levels/ranks from actual awards; do not use impossible debug states for store images.
- Prepare the title `Mecha Todo`, short/full descriptions, screenshot alt text and `1.0` release notes. Preserve `MECHA//TODO` in allowed display contexts. Avoid pixel/procedural badge wording, a separate progression-screen claim and medical benefit claims.
- Prepare Data safety, privacy, content rating, target audience, ads, app access, Health and Financial features declarations from the audited release. Set the selected age groups to 13-15, 16-17 and 18-and-over; content rating remains a separate questionnaire. Use all countries the verified account permits.
- Publish and verify the agreed English privacy page and support alias through the owner. Confirm that the page loads without login and matches the bundled text. No marketing website is required.
- Support the publisher's required closed test, record feedback and resulting fixes, and rerun affected acceptance checks. Apply for production access after Console eligibility is met. Production access is not automatic after fourteen days.
- Assemble the submission handoff with artifact hashes, version/revision, required test results, declarations, store assets and remaining Console actions. Stop before actual publication unless separately instructed.

Create final store files during this phase under `docs/release-assets/1.0/`, with `play-store/`, clean captures, annotated exports and a manifest of source build/configuration. Keep release evidence in `docs/release-checklist.md` and local detailed run notes. These are planned output locations, not claims that assets or passing evidence exist today.

The [store and press brief](MECHA_TODO_APP_STORE_PRESS_IDEA.md) supplies screenshot composition and copy ideas. Its optional press/social sections do not add release gates.

## 12. Owner-controlled release prerequisites

| Prerequisite | When it can start | Evidence needed to close it |
| --- | --- | --- |
| New personal Play account | Alongside implementation | Owner completes registration, current fee, identity/contact verification and eligible physical-device verification; Console permits the testing/upload flow |
| Package ownership and signing | Before the first upload | Correct app entry and stable application ID; accepted signed bundle; private owner-controlled key/recovery arrangements |
| Privacy page | Draft alongside implementation, finalize against release | `https://stefan-karger.de/mecha-todo/privacy` is public, English and consistent with the bundled policy |
| Support alias | Alongside implementation | Test mail to `mecha-todo@stefan-karger.de` reaches the owner's inbox |
| Closed test | After an eligible candidate and testers are ready | At least 12 participants remain continuously opted in for 14 days under the current requirement; real use/feedback/fixes are recorded |
| Production access | After the required test | Console grants the requested production access; elapsed time alone does not close this gate |
| Distribution declarations | Before submission | Account/country obligations and all required app declarations are complete for the final release |

The old account's inactivity closure does not make it available for this release or exempt the new account from testing. Owner-controlled account work is recorded as an external prerequisite; the implementer must not register accounts, pay fees or transmit identity documents merely because this plan lists them.

## 13. Verification commands and evidence

Run commands from the repository root with the configured toolchain. Confirm available tasks during phase 01 and record the exact command used. Use focused tests while implementing; complete the required suites at the corresponding acceptance gates.

```powershell
.\gradlew.bat :app:assembleDebug :app:testDebugUnitTest :app:lintDebug
```

With the intended emulator or device connected and selected:

```powershell
.\gradlew.bat :app:connectedDebugAndroidTest
```

After the owner has supplied private release signing configuration:

```powershell
.\gradlew.bat :app:lintRelease :app:bundleRelease
```

An unsigned bundle build does not establish signing readiness. Test installation from the final bundle through the appropriate bundle/Play testing flow as well as debug installation. Record any instrumentation task variant or device selection used; aggregate connected-device results must remain attributable to their configurations.

| Contract area | Primary proof | Delivery gate |
| --- | --- | --- |
| Text, rewards, progression, ranks, capacity and calendar | Golden fixtures and pure Kotlin boundary tests | 02 |
| Raw types, core/draft validation, preservation and schema | Real SQLite file/open/migration fixtures | 03 |
| Exact-once award, atomic promotion, ordering and concurrency | File-backed transactional and competing-connection tests | 04 |
| Commit/read separation and accurate erasure | Injected post-commit read failure, rollback and reset failure tests | 04, 05 |
| Draft ownership, protected slots, races and failed discard | Controlled scheduling plus actual Room integration | 05 |
| Undo deadline, commit order, expiry and process lifetime | Clock-controlled tests and device lifecycle cases | 05, 08 |
| Input, editing guards, restoration, pagination and feedback | Compose interaction tests and physical IME checks | 06, 08 |
| Theme, geometry, accessibility, insets and splash | Native visual/state tests and named device review | 07, 08 |
| No backup/transfer and offline/privacy behavior | Manifest/transport audit and offline release smoke test | 08 |
| Deep history, target/min API and 16 KB compatibility | Measured fixture runs and artifact/device evidence | 08 |
| Publisher, signing, store material and production eligibility | Owner/Console evidence and submission artifact manifest | 09 |

The implementation is complete for this scope when all application gates pass, required assets and declarations are ready, the owner-controlled submission prerequisites are satisfied, and the handoff identifies the exact candidate. If an external prerequisite remains incomplete, report the app's actual readiness and the named release blocker. Do not describe the app as published or the submission as accepted before those events occur.
