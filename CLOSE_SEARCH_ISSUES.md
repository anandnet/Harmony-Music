# Closing Search-Related Issues - Instructions for Maintainer

## ⚠️ ACTION REQUIRED

This document provides instructions for closing 23 search-related issues that were fixed in v1.12.1.

## Background

Version v1.12.1 was released on October 16, 2025, which fixes the search functionality issue that many users reported. Users need to be notified to update to this version.

## Issues to Close

The following 23 issues are related to the search bug that was fixed in v1.12.1 and should be closed:

| Issue # | Title |
|---------|-------|
| #640 | Search for a song is not working |
| #643 | Search doesn't work |
| #646 | Search not working. |
| #648 | Song Search not working please update your applications |
| #652 | The search bar for music not working, please fix it. Thankyouuu! |
| #653 | Search bar is not working |
| #654 | Cant search new songs |
| #655 | Search Feature not working in app |
| #656 | Search bar not working please fix it |
| #657 | Search Functionality |
| #659 | SEARCH BAR |
| #660 | Search bar is not working |
| #661 | Music search aint working |
| #664 | Music search ki behn chud gayi |
| #665 | Search option is not working |
| #666 | Search option is not working. |
| #667 | Best music player BUT search engine not working please update. Thank you |
| #668 | **Bug Type** Search Option not working |
| #669 | Bug |
| #673 | Bug, want a update to solve search engine problem and notification pop up problem |
| #677 | unable to search any songs, its just keep loading for Android and windows both |
| #611 | When I search for songs it only keeps loading. |

## Issues NOT to Close

The following issues are related to search but are NOT the same bug that was fixed in v1.12.1:

- **#629** - [Android Auto] Missing Song Search Functionality (feature request for Android Auto)
- **#391** - search bar on "Search results" or persistent floating Search button (UI enhancement)
- **#558** - Include Artist/Description in search (feature request)
- **#636** - Top picks (feature request about recommendations)
- **#663** - NEVER EVER use replace playback queue as default option! (different bug)
- **#631** - Song only loading when clicked (may be related but needs verification)
- **#650** - Temporary method for search (workaround info, not a bug report)
- **#674** - Release a new version including the search bar fix (meta issue requesting the release)

## How to Close Issues

### Option 1: Using the provided script (Recommended)

Run the automated script:

```bash
./.github/scripts/close_search_issues.sh
```

This will:
1. Add a comment to each issue with information about v1.12.1 and download links
2. Close each issue with the reason "completed"

### Option 2: Manual closure

For each issue listed above, add this comment:

```markdown
Thank you for reporting this issue! 

The search functionality issue has been fixed in version **v1.12.1**. Please update to the latest version from the [releases page](https://github.com/anandnet/Harmony-Music/releases/tag/v1.12.1).

**Download Links:**
- **Android (Universal APK):** [harmonymusic-1.12.1-release.apk](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1-release.apk)
- **Android (ARM64):** [harmonymusic-1.12.1-arm64-v8a-release.apk](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1-arm64-v8a-release.apk)
- **Android (ARMv7):** [harmonymusic-1.12.1-armeabi-v7a-release.apk](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1-armeabi-v7a-release.apk)
- **Windows:** [harmonymusic-1.12.1.exe](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1.exe)
- **Linux (Debian):** [harmonymusic-1.12.1+26-linux.deb](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1%2B26-linux.deb)
- **Linux (AppImage):** [harmonymusic-1.12.1+26-linux.AppImage](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1%2B26-linux.AppImage)
- **Linux (RPM):** [harmonymusic-1.12.1+26-linux.rpm](https://github.com/anandnet/Harmony-Music/releases/download/v1.12.1/harmonymusic-1.12.1%2B26-linux.rpm)

If the issue persists after updating, please feel free to reopen this issue or create a new one with details about your setup.

Closing this issue as it has been resolved in v1.12.1.
```

Then close the issue with the reason "completed".

## Verification

After closing, verify that:
1. All 23 issues listed above are closed
2. Each has a comment directing users to v1.12.1
3. Issues that should NOT be closed remain open
