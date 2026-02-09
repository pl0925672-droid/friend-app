# 📱 Download Friend App APK

## ✅ APK is Being Built!

GitHub Actions is now **automatically building your APK** every time you push code.

---

## 📥 Where to Download APK

### 1️⃣ From GitHub Actions (Latest Build)

**Fastest way - Get the latest APK:**

1. Go to: **https://github.com/pl0925672-droid/friend-app/actions**
2. Click on **"Build & Release APK"** workflow
3. Click the latest run (green checkmark ✅)
4. Scroll down to **"Artifacts"** section
5. Download **friend-app-apk.zip** 
6. Extract and install on your Android phone

**APK File:** `friend-app-release-unsigned.apk`

---

### 2️⃣ From GitHub Releases (Stable Versions)

**For tagged releases with auto-generated pages:**

Create a release tag and GitHub will automatically upload the APK:

```bash
# Create a version tag
git tag v1.0.0
git push origin v1.0.0
```

Then go to: **https://github.com/pl0925672-droid/friend-app/releases**

The APK will be auto-attached to the release! 🚀

---

## 📲 How to Install APK on Android

### Method 1: Direct Download & Install
1. Download APK file to your phone
2. Open file manager → Find the APK
3. Tap to install
4. Grant permissions if prompted
5. Open **Friend App** 🎉

### Method 2: Using ADB (Developers)
```bash
adb install friend-app-release-unsigned.apk
```

### Method 3: Through Computer
1. Download APK to computer
2. Connect Android phone via USB
3. Run: `adb install path/to/apk`

---

## ⚙️ Workflow Details

**The GitHub Actions workflow automatically:**
- ✅ Builds web assets from `public/` folder
- ✅ Wraps them with Capacitor (Android native wrapper)
- ✅ Compiles Java code to APK
- ✅ Uploads APK as artifact
- ✅ Creates releases with APK attached

**Triggers:**
- 🔄 Every push to `main` branch
- 📌 On workflow_dispatch (manual trigger)
- 🏷️ On version tags (v1.0.0, v2.0.0, etc)

---

## 🔐 Signing APK (Production)

The current APK is **unsigned** (for testing). For app store release:

1. Generate keystore:
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. Add to GitHub Secrets:
   - `KEYSTORE_FILE` (base64 encoded)
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`

3. Update workflow to sign APK

---

## 📊 Troubleshooting

### APK not appearing in artifacts?
- Check workflow status: https://github.com/pl0925672-droid/friend-app/actions
- Look for red ❌ (build failed)
- Check logs for errors

### Would not install on phone?
- Enable "Unknown Sources" in phone settings
- Clear app cache: Settings → Apps → Friend → Clear Cache
- Try uninstalling old version first

### App crashes after install?
- Check browser console (F12) for JS errors
- Make sure backend API is running
- Verify CORS configuration matches your domain

---

## 🚀 Getting New APK

**To get updated APK after code changes:**

1. Make changes to code
2. Commit: `git add -A && git commit -m "message"`
3. Push: `git push origin main`
4. Wait 3-5 minutes ⏳
5. Download new APK from Actions → Artifacts

**Done!** Your Android app is updated! 📱

---

## 📱 Test on Physical Device

1. Download APK to Android phone
2. Install as instructed above
3. Open Friend App
4. Sign up / Login
5. Start tracking activities! 🎯

---

## 💡 Pro Tips

**For faster iteration:**
- Use **GitHub Codespaces** to code and test
- Push to `main` for automatic APK generation
- Test in Android Emulator first (if available)
- Use source maps for debugging

**Monitor builds:**
- Watch: https://github.com/pl0925672-droid/friend-app/actions
- Get notifications for failed builds
- Check build logs for errors

---

## Need Help?

If APK doesn't build:
1. Check GitHub Actions logs
2. Verify all files are present
3. Check for Java/Gradle errors
4. Message me for debugging! 💬

**Happy building! 🎉**
