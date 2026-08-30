# Building this APK with only an Android phone (no computer)

You don't need a computer. GitHub will build the APK for you on its own
cloud servers. You just need to get this project's files into a GitHub
repository once, using your phone's browser. GitHub Actions (already set
up in `.github/workflows/build-apk.yml`) then builds debug + release APKs
automatically and lets you download them.

## Step 1: Create a free GitHub account
Open github.com in your phone's browser and sign up (if you don't already
have an account).

## Step 2: Create a new empty repository
- Tap the "+" icon → "New repository"
- Name it anything, e.g. `video-editor-mvp`
- Leave it empty (don't add a README) → Create repository

## Step 3: Get this project's files into that repository
The files are nested in folders (like `android/app/src/main/kotlin/...`),
so uploading them one by one through GitHub's web uploader is impractical.
Use **GitHub Codespaces** instead - it's a full Linux environment with a
terminal, running in your phone's browser, completely free for this
(personal accounts get 60 free hours/month, this only needs a few minutes):

1. On your new repo's page, tap the green "Code" button → "Codespaces" tab
   → "Create codespace on main"
2. Wait for it to load (it opens a VS Code-like editor in your browser)
3. In the file explorer panel (left side), tap the "..." menu → "Upload..."
   and pick the `video_editor_mvp_fixed.zip` file from your phone
   (the one I gave you). This uploads just that one zip file.
4. Open the built-in Terminal (menu → Terminal → New Terminal, or the
   hamburger menu → Terminal) and run:
   ```
   unzip video_editor_mvp_fixed.zip
   mv fixed/* fixed/.[!.]* . 2>/dev/null
   rmdir fixed
   git add -A
   git commit -m "Add fixed video editor project"
   git push
   ```
   (If `mv` complains about "fixed/.[!.]*" matching nothing, ignore that
   one error - it just means there were no hidden dotfiles to move.)

## Step 4: Watch the build run
- Go to your repository's page → "Actions" tab
- You'll see "Build Android APK" running (started automatically by your
  push). It takes a few minutes.
- Tap into the run once it finishes (green checkmark = success).

## Step 5: Download the APK
- Scroll down on that run's page to "Artifacts"
- Tap `app-debug-apk` (or `app-release-apk`) to download it as a .zip
- Unzip it on your phone (most phone file managers can do this, or use
  an app like "Files by Google" / "ZArchiver")
- You'll have `app-debug.apk` - tap it to install (you may need to allow
  "install from unknown sources" for your browser/files app once)

## If the Actions build fails
Tap into the failed step in the Actions log to read the error, and send
me that exact error text - I can fix the project source and you just
repeat Step 3 (upload the corrected files, commit, push) to rebuild.

## Alternative: Termux (if you prefer a dedicated terminal app)
Install Termux from F-Droid (not the outdated Play Store version), then:
```
pkg install git unzip -y
termux-setup-storage
cd storage/downloads
unzip video_editor_mvp_fixed.zip
cd fixed
git init && git add -A && git commit -m "Initial"
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```
GitHub will ask for a Personal Access Token instead of a password when
pushing - generate one at github.com → Settings → Developer settings →
Personal access tokens (use it in place of your password when prompted).
