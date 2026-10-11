# Offline-first — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Data layer** — "The entry points to the data layer are always
   repository classes"; "other layers in the hierarchy should not access
   data sources directly"; state holders "should never have a direct
   dependency on a data source"; "every repository should define a single
   source of truth"; "to provide offline support, use a local source of
   truth, such as a database"; expose suspend functions for one-shot
   operations, flows for notifications about data changes over time.
   https://developer.android.com/topic/architecture/data-layer

2. **Offline-first** — "The local data source is the canonical source of
   truth for the app"; reads are exposed as Flow (StateFlow + stateIn,
   collected with collectAsStateWithLifecycle); "write all updates to the
   local data source first so it notifies its consumers"; "the domain and
   UI layers of the app must never communicate directly with the network
   layer"; "an offline-first app must be able to perform read operations
   without network access"; sync via WorkManager (unique work,
   ExistingWorkPolicy.KEEP, Result.retry() with exponential backoff);
   conflict resolution: last-write-wins timestamps.
   https://developer.android.com/topic/architecture/data-layer/offline-first

3. **Room async queries** — "To prevent queries from blocking the UI,
   Room does not support database access on the main thread"; suspend
   functions for one-shot queries, Flow for observable queries
   (distinctUntilChanged caveat: observable queries re-run on any table
   row update).
   https://developer.android.com/training/data-storage/room/async-queries

4. **DataStore** — "Never create more than one instance of DataStore for
   a given file in the same process. Doing so can break all DataStore
   functionality. If there are multiple DataStores active for a given
   file in the same process, DataStore will throw
   IllegalStateException when reading or updating data"; "if you need to
   support large or complex datasets, partial updates, or referential
   integrity, consider using Room instead of DataStore"; "if you're using
   SharedPreferences to store data, consider migrating to DataStore
   instead."
   https://developer.android.com/topic/libraries/architecture/datastore

5. **Room migrations** — without a migration path Room throws
   IllegalStateException; `fallbackToDestructiveMigration()` warning:
   "Room permanently deletes all data from the app's database tables"
   when a migration is required but no path is defined; proper migrations
   are `Migration(startVersion, endVersion)` objects added via
   `addMigrations(...)`; targeted alternatives:
   `fallbackToDestructiveMigrationFrom` (specific broken versions),
   `fallbackToDestructiveMigrationOnDowngrade` (downgrades only).
   https://developer.android.com/training/data-storage/room/migrating-db-versions

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
