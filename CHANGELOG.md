## 1.12.0
* Redesigned Album & Playlist screen
* Added Basic Interface for Android Auto #496 #492 #427 #111
* Import/export functionality for playlists by @ani-sh-arma
* Android splash screen implemention for all devices by @girish54321
* (Windows)-TitleBar Color implementation
* Fixed Album,Single loading issue in Artist acreen #509
* Fixed Miniplayer in landscape mode #462
* Fixed playlist add ui overflow #500
* Fixed restoration of downloaded songs #552
* Fixed Chinease language issue #548
* Fixed trigger dynamic mode for offline songs #537
* Fixed screen freeze issue in Android #348 #492

## 1.11.2
* Fixed rendering issue in Android (happening due to flutter upgrade)

## 1.11.1
* Fixed Missing playlist content #437
* Fixed - Album original tracks are not available in album #439,#440 and #299
* Added right click support for opening song context menu #431
* Added option to enable/disable auto opening of player full screen #273
* Added More tags for album songs #404,#293
* Player screen enhancement (Android) #432
* Changed icon style and app font
* Made pause play button animated
* Updgraded AGP
* Replaced Device Equalizer & SDKInt package with binding generated with jnigen (Tried to fix Equalizer in Android)

## 1.11.0
* Fixed Stream issues
* Added feature to restore settings to default
* Fixed: Android swipe gesture navigation cause half-way drag on player page #367
* Updated language data

## 1.10.4
* Fixed stream issues
* Fixed cross platform data restore issue

## 1.10.3
* Fixed Song is not playable due to server restriction!
* Added option to swipe to queue item removal and queue clear 
* Desktop Full Screen player (Will open on clicking song title in mini player)
* Automatically download favorite songs #164 (Enable it from settings)
* Redirect to home before exiting 
* Enabled download option for fav playlist
* Fixed Can't capitalize letters in playlist titles
* Fixed Last song in queue is covered on Android
* Fixed search button height in Android
* Fixed opening of album from song when album is already bookmarked

## 1.10.2
* Fixed Song is not playable due to server restriction!
* Added hl code #298

## 1.10.1
* Improved song loading time (Android)
* Added slide gesture to song tile for playing next song by @DarkNinja15
* Optional feature: Gesture based player (Android)
* Prettified title on Windows app #279 (Windows)
* Fixed art img size
* Feature: Queue loop #234
* Fixed Stop music on task clear not working #268 (Android)
* Transparent bottom #177 (Android)
* Added null check on genID from Db #278
* Enable loading on Buffering #170
* Fixed AppImage don't play (Linux)


## 1.10.0
Fixes:
* fix: allow use of qt window decorations by @Merrit
* fix: system tray causing crash on linux by @Merrit
* Fixed Won't load big playlists #222
* Fixed tab ui mismatch issue #239
* Fixed griditem overlap in library playlist section #239
* Fixed song restarts from beginning when radio is enabled #223
* Fixed - Repeatative entries from Recently played can be removed #261
* Changes in downloader & Fixed issue - Audio from videos will not download #264

Features:
* Poweramp support #82
* Enabled backup and restore feature for Android #90 #250
* Made App landscape mode compatible #218 #115
* Added support for direct opening of YTM links #242
* Added song info for current song #201
* Added option to view lyrics in desktop mode #226
* Added play/pause feature using spacebar #249
* Added scrollbars for horizontal contents for desktops #249
* Added button to minimize full screen player #249
* Added shuffle mode #174 #252
* Added searchbar in homescreen for desktops #249
* Added loudness normalization feature (Android) #15 #243
* Added app version info & customized settings screen #254
* Added feature to browse content using url via search #203

## 1.9.2
* Fixed Showing Black screen #197
* Fixed loading of deeplink playlist #198
* Fixed broken things #210,#209,#198
* Backup & restore feature for Windows by @encryptionstudio


## 1.9.1
* Added volume slider for desktop app #169
* Added open in youtube/youtube music option #189
* fixed list widget size issue android
* fixed queue rearrange issue android #165
* Ucommented audiotags implementation for Auditag #163
* Fixed song removal issue #162
* Fixed Small Thumbnail issue #158 & #183
* Fixed Album & playlist stuck on exception #192
* Fixed Enabled/disabled color of toggles are misleading #178
* Fixed RP playlist song order & added option for deletion #179


## 1.9.0
* Added Windows and linux platform support #136
* Added feature to rearrange local playlist, add multiple songs to plalist, delete multiple songs #153
* Added feature to export downloaded files to external storage #157
* Added feature to restore last playback session #121
* Added feature to cached home content data #133
* Added feature to remove song from downloads from bottom sheet #143
* Added option to disable transition animation #150
* Loading indicator added in play/pause button #134
* Fixed HM is categorized as browser #142
* Used isolate to fetch song url #133
* Fixed songs are not in the correct order in offline/bookmarked album #132
* added artist name in downloaded filename to resolve issue #152
* Added system tray support for desktops and provided option for background playing

## 1.8.0
* Added feature to switch to Bottom Navigation Bar (Major Change) #95 #58
* Synced Lyrics feature added #66 #116 #98 (Data provided by lrclib.net)
* Added x button to clear search query #92
* Added Search history #128
* Sleep Timer feature added #118 #109
* Added feature to ensure offline availability of bookmarked Album/playlists #113
* Highlight for now playing song in playlists #97
* Changes made for remember last session selection for loop mode #127
* Added functionality to remove invalid char from file name to fix issue #129
* Downloaded thumbnail support for downloaded song
* Added option to set no of homescreen content (approx)
* Fixed app flagged as TROJEN in virustotal #122
* Fixed song album id issue for songs in album
* Fixed playlist sort issue
* Fixed null album issue
* Improved app animation #83
* fixed thumbnail url issue
* New language support Interlingua, Esperanto and updated other langs thanks to @softinterlingua, @Kjev666, @maboroshin, @trunars, @gallegonovato, @nexiRS, @WaldiSt, @MattSolo451, @


## 1.7.0
* Added feature to download whole playlist/album #79 & #100
* Added Replay on previous feature #101
* Fixed Result tab alignment & playlist screen intial flickr
* Fixed piped custom instance issue #103
* Fixed (increased) Lockscreen's album art image quality #96
* Translation completed Azerbaijani,Indonesian,Japanese,Portuguese,Chinese and some correction in other lang translation. Thanks to @Qaz-6,@Hada45,@maboroshin,@S4r4h-O,@raymond-nee,@siggi1984,@PonyJohnny,@MattSolo451,@hoabuiyt

## 1.6.0
* App language support #21 #54
* Selective song download feature #40
* Fixed - Songs can not be deleted from the cached/offline #68
* Changed app font
* Fixed - Offline playlist rename/delete issue

## 1.5.0
* Added search feature where required - Feature requested in #45 
* Fixed - loop song does not work #49
* Fixed - screen mismatching issue #57
* Fixed - Home page not loading #59
* Fixed - Some songs are not playing, it remains paused #60 
* Fixed type #62 & made test more brighter #61

## 1.4.0
* Piped playlist integration - Feature requested in #28 
* Option added  in settings to stop music on app cleared from ram/task #30
* Fixed full song name in playlists #32
* Fixed not appearing all songs in bookmarked platlist #37
* Fixed - not able to scroll till the last song #44 

## 1.3.2
* Patch version for issue #34
* Upgarded packages & update kotlin version

## 1.3.1
* Android Auto support
* Fixed Artist content

## 1.3.0
* App Link/Deep link support
* Miniplayer progressbar fixed 
* Home Content list changed from column to listView

## 1.2.0
* Discover content selecter added in settings
* Equalizer support added
* Lyrics support added
* images resolution changes done
* App new version notifier added
* Hide Search FAB from settings
* Internal client error 403 handled using workaround

## 1.1.0

* Radio feature added
* Search/(Artist-song/videos) list continuation added
* List sorting feature added
* PlayNext option added
* Bug Fixes

## 1.0.1

* Some Network Exceptions handled
* Ignore battery enable option for notification issues
* Some Minor changes & bug fixes

## 1.0.0

* initial release.