#!/bin/bash

# Script to close search-related issues that were fixed in v1.12.1
# This script uses GitHub CLI (gh) to close issues and add a comment

# List of search-related issue numbers that were fixed in v1.12.1
SEARCH_ISSUES=(
    640  # Search for a song is not working
    643  # Search doesn't work
    646  # Search not working.
    648  # Song Search not working please update your applications
    652  # The search bar for music not working, please fix it. Thankyouuu!
    653  # Search bar is not working
    654  # Cant search new songs
    655  # Search Feature not working in app
    656  # Search bar not working please fix it
    657  # Search Functionality
    659  # SEARCH BAR
    660  # Search bar is not working
    661  # Music search aint working
    664  # Music search ki behn chud gayi
    665  # Search option is not working
    666  # Search option is not working.
    667  # Best music player BUT search engine not working please update. Thank you
    668  # **Bug Type** Search Option not working
    669  # Bug
    673  # Bug, want a update to solve search engine problem and notification pop up problem
    677  # unable to search any songs, its just keep loading for Android and windows both
    611  # When I search for songs it only keeps loading.
)

# The comment to add to each issue
COMMENT="Thank you for reporting this issue! 

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

Closing this issue as it has been resolved in v1.12.1."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Please run 'gh auth login' first."
    exit 1
fi

echo "Starting to close search-related issues..."
echo ""

# Counter for closed issues
closed_count=0
failed_count=0

# Loop through each issue and close it with a comment
for issue_num in "${SEARCH_ISSUES[@]}"; do
    echo "Processing issue #${issue_num}..."
    
    # Add comment to the issue
    if gh issue comment "${issue_num}" --body "${COMMENT}" --repo anandnet/Harmony-Music; then
        echo "  ✓ Comment added to issue #${issue_num}"
        
        # Close the issue
        if gh issue close "${issue_num}" --reason completed --repo anandnet/Harmony-Music; then
            echo "  ✓ Issue #${issue_num} closed successfully"
            ((closed_count++))
        else
            echo "  ✗ Failed to close issue #${issue_num}"
            ((failed_count++))
        fi
    else
        echo "  ✗ Failed to add comment to issue #${issue_num}"
        ((failed_count++))
    fi
    
    echo ""
    
    # Add a small delay to avoid rate limiting
    sleep 1
done

echo "================================================"
echo "Summary:"
echo "  Successfully closed: ${closed_count} issues"
echo "  Failed: ${failed_count} issues"
echo "================================================"

if [ ${failed_count} -eq 0 ]; then
    echo "All search-related issues have been closed successfully!"
    exit 0
else
    echo "Some issues could not be closed. Please review the output above."
    exit 1
fi
