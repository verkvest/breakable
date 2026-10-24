# Clinkwell

Portrait brick-breaker for iPhone and Android. Drag anywhere to move the paddle, tap to launch the ball.

Clinkwell is a Godot 4.7 port of [Breakable](https://github.com/didier-v/breakable) by Didier Vandekerckhove (MIT). The original title is not used. Bundle id on both stores: `es.verkvest.clinkwell`.

Godot **4.7.2**, Mobile renderer, with an OpenGL fallback. The playfield is a 720×1280 viewport that expands to the phone’s aspect ratio and stays inside the safe area.

## Play

- Drag a finger (or the mouse) sideways to move the paddle.
- Tap, or press Space, to launch. Tap again to fire a stored bonus such as Sticky.
- Pause is the button at the top of the court.

Open the project in Godot 4.7.2, or from a terminal:

```bash
godot --path .
```

## Credits

The in-game Credits screen and `THIRD_PARTY_LICENSES.txt` list Breakable (MIT), the cfxr sound effects, Nunito (SIL Open Font License), and the Godot Engine (MIT). Ricasso Regular shipped with the original project without a license and is not included.

## Export

`export_presets.cfg` has three presets:

| Preset | Output |
| --- | --- |
| iOS | Xcode project (`application/export_project_only`), team `38PT254HDZ` |
| Android APK | Gradle APK, `targetSdk` 36, `minSdk` 24 |
| Android AAB | Gradle App Bundle, same SDK levels |

Icons for every iOS slot and the Android launcher densities are in `icons/`. Regenerate them with `python3 tools/generate_icons.py`.

GitHub Actions:

- `ios-testflight` exports the Xcode project on macOS, archives it, signs with the App Store Connect API key, and uploads to TestFlight. Build number is `github.run_number`. `ITSAppUsesNonExemptEncryption` is false. The workflow registers the bundle id if it is missing. It cannot create the App Store Connect app record; if upload fails only for that reason, the log says so.
- `android` builds a release AAB and APK when `ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, and `ANDROID_KEY_ALIAS` are set, otherwise a debug-signed APK. It also uploads phone-viewport screenshots of the menu and a game.
