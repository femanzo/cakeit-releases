# CakeIt releases

Public Windows demo installers and release notes for CakeIt.

Download published installers from the Releases page. Source code is maintained in a separate private repository.

Builds are published only on the project owner's request, after validation. Each release should include its version, release notes and SHA-256 checksums.
# Automatic site publication

Publishing a stable GitHub release runs `.github/workflows/publish-site.yml`.
The workflow authenticates to CakeIt with a short-lived GitHub OIDC token; no site admin password or long-lived secret is stored here.

Every release must contain a Windows `.zip`, `.exe`, `.msi`, or complete numbered `.zip.001` sequence, plus `SHA256SUMS.txt` with SHA256 digests matching GitHub's uploaded asset digests. Split archives must also include `Extract-CakeIt.cmd` and the combined ZIP checksum. Upload all files to a draft, then publish.

The site registers the release once, makes it available to existing valid demo keys, and sends one update notice to each non-withdrawn player with a sent, non-revoked invitation. It does not create keys. Paused/deleted releases are not reactivated. Older releases do not replace newer downloads or send late announcements.

Use **Actions → Publish demo to CakeIt site → Run workflow** with the published tag to register an existing release or resume a failed run. A successful run includes notification totals. Ambiguous email delivery older than 23 hours requires manual review to prevent duplicate emails. No periodic polling or Codex tokens are needed.
