# ADR 005 — Official optional Rails integration

Status: accepted.

The Rails companion owns framework integration while `Document`, `Client` and `Artifact` remain Ruby objects. Railtie initialization supplies named clients, translations and explicit helpers. No Engine, application models, routes or persistence schema is installed.

Mapping is a plain application service. A generator creates a starting point but cannot infer a business invoice from arbitrary ActiveRecord columns. No model callbacks or automatic invoice generation on save are installed.

The error adapter maps semantic term identifiers to application attributes. Unmapped issues use `:base`. Active Storage receives an attachable hash; only the application's `attach` call persists data. Streaming/open reads avoid loading remote blobs without a core size check where the storage API permits it.

Notifications include operation metadata, not invoice XML or customer fields. ActiveSupport's automatic exception payload is suppressed; only error class is reported. Reinitialization does not duplicate subscribers or retain reloadable model classes.

An isolated dummy app exercises real Active Storage using an in-memory SQLite database and a private temporary storage directory. It never connects to the Advitam database.
