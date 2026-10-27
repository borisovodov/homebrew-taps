# homebrew-taps

Personal Homebrew tap for applications I distribute through Homebrew. It is
a complete cask tap; install the tap, then any cask from it:

```sh
brew tap borisovodov/taps
brew trust borisovodov/taps   # Homebrew 7+: third-party taps are untrusted by default
brew install --cask <cask>
```

## Casks

| Cask | Description | Homepage |
|---|---|---|
| [doru](Casks/doru.rb) | Local-first genealogy for the AI era | https://doru.family |

Dóru's cask installs the signed and notarized macOS dmg (Apple Silicon,
macOS 13 or later) and the AppImage on Linux (x86_64 and arm64). The app has
no self-update mechanism (`auto_updates false`), so Homebrew is the update
channel: each release bumps `version` and the `sha256` entries in
`Casks/doru.rb` (the `livecheck` block tracks the GitHub releases). The cask
uses Homebrew 7 cask DSL (`on_system_conditional`, `app_image`); older
Homebrew versions cannot parse it. On Linux the cask also writes the desktop
entry and icon, and registers the `.doru`/`.gdz` MIME types (`.ged` files use
the `text/vnd.familysearch.gedcom` type that ships with shared-mime-info), so
file managers associate Dóru with all three extensions.

## Updates

The `update-casks.yml` workflow checks for new releases of the tracked
projects every four hours and commits cask updates (version and sha256
entries) directly to `main` — no manual bumps needed. The version and the
three hashes come from one unauthenticated GitHub API call (release assets
expose their sha256 as `digest`), so the bot needs no secrets and downloads
nothing. It can also be triggered manually (workflow_dispatch).
