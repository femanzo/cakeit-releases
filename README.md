# CakeIt releases

Public Windows demo installers and release notes for CakeIt.

Download published installers from the Releases page. Source code is maintained in a separate private repository.

Builds are published only on the project owner's request, after validation. Each release should include its version, release notes and SHA-256 checksums.
# Automatic site publication

Players should download **CakeIt-Setup.exe** only. Starting with 0.2.1, it installs Cake It! Launcher, which checks for updates when opened and uses binary delta patches when available. No itch.io account or client is required. The unused local AI model is no longer distributed. Existing demo keys continue working.

Packaging code and launcher source live in the private game repository; follow its `Docs/DISTRIBUTION.md`. Build with the previous verified full package to generate the new delta. Upload the installer, one new full `.nupkg`, the delta (after the initial release), `releases.win.json`, `assets.win.json`, and SHA256 manifest to a draft. Run **Actions → Verify incremental installer** with the draft tag, then publish only after success. Installation is per-user; saves live outside the replaceable install directory.

The previous Inno **Build Windows installer** workflow is disabled. Its scripts and old release assets remain for historical compatibility. Do not use that workflow for new builds. Players on the old installer must install 0.2.1 once to adopt incremental updates; their old installation is not deleted automatically.

Publishing a stable GitHub release runs `.github/workflows/publish-site.yml`.
The workflow authenticates to CakeIt with a short-lived GitHub OIDC token; no site admin password or long-lived secret is stored here.

Every release must include `SHA256SUMS.txt` with SHA256 digests matching GitHub's uploaded assets. Incremental releases include exactly one new full package and the verified Windows update feed. Previous public full packages/deltas must remain available to clients that skip versions. Full-package fallback remains available when a delta cannot be used.

The site registers the release once, makes it available to existing valid demo keys, and sends one update notice to each non-withdrawn player with a sent, non-revoked invitation. It does not create keys. Paused/deleted releases are not reactivated. Older releases do not replace newer downloads or send late announcements.

Use **Actions → Publish demo to CakeIt site → Run workflow** with the published tag to register an existing release or resume a failed run. A successful run includes notification totals. Ambiguous email delivery older than 23 hours requires manual review to prevent duplicate emails. No periodic polling or Codex tokens are needed.
