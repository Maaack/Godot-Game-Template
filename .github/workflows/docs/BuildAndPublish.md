## How to Build and Publish my game using Github CICD?

## How to trigger the CICD?

When you’re ready to publish a new version of your game, create a **GitHub release** tied to a version tag on the `main` branch. This helps track updates, distribute builds, and communicate changes to players or testers. This will trigger CICD, which will **build your game** in the cloud and **publish it** to itch.io (if setup).

1. Ensure all desired changes are merged into the `main` branch. This is the version that'll get build and published.
2. On Github, go to Release, then **draft a new release** ([here is a step by step guide](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository#creating-a-release)). Create a new tag on you `main` branch using [semantic versioning](https://semver.org/):
   - x.0.0 — Major Release. Large updates or milestones (e.g., new game systems, overhauled visuals, major gameplay changes). Example: v1.0.0 for the full launch.
   - x.y.0 — Minor Update. New content or features that expand gameplay but remain backward-compatible. Example: v1.1.0 for new levels or mechanics.
   - x.y.z — Patch / Hotfix. Small updates, bug fixes, performance improvements, or balancing tweaks. Example: v1.1.3 for fixing a crash or visual glitch.
3. Publish the release. This will trigger CICD. Monitor its execution in the Actions tab on Github.

## Setup your game build

### 1. Adapt the `build-and-publish.yml` file

**Edit your game's name:** Change the `EXPORT_NAME`, `ITCH_USERNAME` and `ITCH_GAME` to fit your own.

```
EXPORT_NAME: your-game
# NOTE: If your `project.godot` is at the repository root, set `PROJECT_PATH` to "."
# If it's in a subdirectory, set it to the subdirectory name (e.g., "your-game")
PROJECT_PATH: .
ITCH_USERNAME: your-username
ITCH_GAME: your-game
```

**Edit Godot version:** By default, the workflow file is made for Godot 4.5. If you're using a different version, replace `GODOT_VERSION: 4.5` at the beginning of the file and all instances of `image: barichello/godot-ci:4.5` with your version. This workflow file uses [godot-ci](https://github.com/abarichello/godot-ci?tab=readme-ov-file) to build your game, so make sure the Godot version you're referring to is [available on Docker](https://hub.docker.com/r/barichello/godot-ci/tags)

### 2. MacOS specifics

#### MacOS Bundle name

In Godot, go to Project > Export... and then select MacOS.

You'll see that you have a field called "Bundle name" with default value `com.game.maaack-templaate`. Change this to be your game name.

#### MacOS Notarization

By default, your built game on MacOS will be flagged as dangerous and players will need to allow its execution by going into.

To avoid this, you need to notarize it, i.e. tell Apple who you are and what is your binary.

For that, you'll need first to create an Apple developer account (99USD/year). Then, you'll need to adapt the Export configuration of MacOS [using this guide](https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_macos.html#if-you-have-an-apple-developer-id-certificate-and-exporting-from-linux-or-windows) to add **rcodesign** notarization and your Apple tokens.

## Setup Itch.io publication

### 1. Adapt the `build-and-publish.yml` file

```
ITCH_USERNAME: your-username
ITCH_GAME: your-game
```

### 2. Create a `BUTLER_API_KEY` Github secret

1. Install [butler.](https://itch.io/docs/butler/installing.html) This is the official CLI tool for itch.io

2. Unzip and make sure the bin is executable

```bash
chmod +x butler
```

3. Run

```bash
butler login
```

Login in the browser and allow butler to access your account.

![Authorize butler](./authorize_butler.png)

The login flow will conclude with something like this:

```
Authenticated successfully! Saving key in /Users/username/Library/Application Support/itch/butler_creds...
```

4. Get your butler API key by reading the content of this file. Beware of spaces in the filepath! This will show you a 40 characters string which is your butler API key.

```bash
cat "/Users/username/Library/Application Support/itch/butler_creds"
```

**Warning:** the butler API key is secret. Do not share it with anyone and **do not** commit it to your repository and **do not** add it directly to the workflow file.

5. Create a new github secret for your repository [by following this guide](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets). Call the secret `BUTLER_API_KEY` and inside, paste the result of the previous step.

### 3. Create a new Github release.
