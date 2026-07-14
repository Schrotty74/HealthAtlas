# HealthAtlas release workflow

HealthAtlas follows the AppAtlas model: `dev` is the local working branch,
`beta` is the local test snapshot, and `main` is the local final source.

## Dev

- Use the single Xcode scheme **HealthAtlas Dev** for daily development.
- Dev remains local. Its own preferences and application-support area are
  cleared before every build.

## Beta from Dev

- Run `bash Scripts/create-beta-from-dev.sh` while checked out on `dev`.
- The script makes a local `beta` commit from the current non-ignored Dev
  source with an isolated temporary index, so it does not modify Dev's staging
  area or copy any app data.
- It builds the Beta configuration and creates a local, ad-hoc-signed app,
  ZIP, DMG and SHA-256 files. The app is in
  `dist/releases/beta/<version>/`; the distributable files are in
  `Backup/releases/beta/<version>/`.

## Final from Beta

- Run `bash Scripts/publish-beta-as-final.sh` from a clean worktree.
- The script fast-forwards local `main` from `beta`, then builds the Final
  configuration in `.build/final/DerivedData/`.
- It stops on a divergent history instead of mixing source states.

## Local folder layout

`Scripts/prepare-build-layout.sh` creates the AppAtlas-style layout only under
the HealthAtlas repository: `.build/dev`, `.build/beta`, `.build/final`,
`Backup/`, and `dist/`. These folders are ignored by Git. The Beta package
script writes only locally to these ignored folders and never includes imported
health data.

No script pushes to GitHub or creates a GitHub release. The local package is
ad-hoc signed because no Apple Developer account is available; Gatekeeper is
therefore expected for testers.
