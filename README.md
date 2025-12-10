<div align="center">

# ❗**This repository is no longer maintained.**

</div>

<img src="https://github.com/anandnet/Harmony-Music/blob/main/cover.png" width="1200" >

# Harmony Music
A cross-platform app for music streaming made with Flutter (Android, Windows, Linux).

# Features
* Ability to play songs from YouTube/YouTube Music.
* Song caching while playing.
* Radio feature support.
* Background music playback.
* Playlist creation & bookmark support.
* Artist & Album bookmark support.
* Import songs, playlists, albums, and artists via sharing from YouTube/YouTube Music.
* Streaming quality control.
* Song downloading support.
* Multi-language support.
* Skip silence feature.
* Dynamic theme.
* Flexibility to switch between bottom & side navigation bar.
* Equalizer support.
* Android Auto support.
* Synced & plain lyrics support.
* Sleep timer.
* No advertisements.
* No login required.
* Piped playlist integration.

# Download
* Please choose one source for the Android APK. You won't be able to update from a cross-build APK source.
* **Arch Linux** users may install it from the **AUR** by installing the **`harmonymusic`** package:
  ```sh
  yay -S harmonymusic
  ```
<a href="https://github.com/anandnet/Harmony-Music/releases/latest"><img src="https://github.com/anandnet/Harmony-Music/blob/main/don_github.png" width="250"></a> 
<a href="https://f-droid.org/packages/com.anandnet.harmonymusic"><img src="https://github.com/anandnet/Harmony-Music/blob/main/down_fdroid.png" width="250"></a>

# Translation
<a href="https://hosted.weblate.org/engage/harmony-music/">
<img src="https://hosted.weblate.org/widget/harmony-music/project-translations/multi-auto.svg" alt="Translation status" />
</a>

You can also help us with translation. Click the status image or <a href="https://hosted.weblate.org/projects/harmony-music/project-translations/">here</a> to go to Weblate.

# Troubleshooting
* If you are facing notification control issues or music playback is stopped due to system optimization, please enable the "Ignore battery optimization" option from settings.

# License
```
Harmony Music is free software licensed under GPL v3.0 with the following conditions:

- A copied/modified version of this software cannot be used for 'non-free' or profit purposes.
- You cannot publish a copied/modified version of this app on a closed-source app repository
  like the Play Store/App Store.
```

# Disclaimer
```
This project was created for learning purposes, and learning is the main intention.
This project is not sponsored, affiliated with, funded, authorized, or endorsed by any content provider.
Any song, content, or trademark used in this app is the intellectual property of its respective owners.
Harmony Music is not responsible for any copyright infringement or other intellectual property rights violations 
that may result from the use of songs and other content available through this app.

This software is released "as-is" without any warranty, responsibility, or liability.
In no event shall the author of this software be liable for any special, consequential,
incidental, or indirect damages whatsoever (including, without limitation, any 
other financial loss) arising out of the inability to use this product, even if
the author of this software is aware of the possibility of such damages or defects.
```

# Learning References & Credits
<a href="https://docs.flutter.dev/">Flutter documentation</a> - The best guide to learning cross-platform UI/app development.<br/>
<a href="https://suragch.medium.com/">Suragch</a>'s articles related to Just Audio, state management, and architectural styles.<br/>
<a href="https://github.com/sigma67">sigma67</a>'s unofficial YouTube Music API project.<br/>
App UI inspired by <a href="https://github.com/vfsfitvnm">vfsfitvnm</a>'s ViMusic.<br/>
Synced lyrics provided by <a href="https://lrclib.net">LRCLIB</a>.<br/>
<a href="https://piped.video">Piped</a> for playlists.

#### Major Packages Used
* **just_audio**: ^0.9.40 - Audio player for Android.
* **media_kit**: ^1.1.9 - Audio player for Linux and Windows.
* **audio_service**: ^0.18.15 - Manages background music & platform audio services.
* **get**: ^4.6.6 - High-performance state management, intelligent dependency injection, and route management.
* **youtube_explode_dart**: ^2.0.2 - Third-party package to provide song URLs.
* **hive**: ^2.2.3 - Offline database used.
* **hive_flutter**: ^1.1.0 - Flutter adapter for Hive.
