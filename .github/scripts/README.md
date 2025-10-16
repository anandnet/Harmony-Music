# GitHub Scripts

This directory contains utility scripts for managing the Harmony Music repository.

## close_search_issues.sh

This script closes all search-related issues that were fixed in version v1.12.1.

### Prerequisites

- GitHub CLI (`gh`) must be installed
- You must be authenticated with GitHub CLI (`gh auth login`)
- You must have appropriate permissions to close issues in the repository

### Usage

```bash
./.github/scripts/close_search_issues.sh
```

### What it does

1. Adds a comment to each search-related issue with:
   - Information that the issue has been fixed in v1.12.1
   - Direct download links for all platforms
   - Instructions to update to the latest version

2. Closes each issue with the reason "completed"

### Issues to be closed

The script will close the following search-related issues that were fixed in v1.12.1:
- #640, #643, #646, #648, #652, #653, #654, #655, #656, #657, #659, #660
- #661, #664, #665, #666, #667, #668, #669, #673, #677, #611

### Note

Issues related to feature requests or different bugs (not the main search bug fixed in v1.12.1) are intentionally excluded:
- #629 - Android Auto search (feature request)
- #391 - Search bar on results page (feature request)
- #558 - Include Artist in search (feature request)
- #636 - Top picks (feature request)
- #663 - Playback queue behavior (different bug)
- #631 - Loading issue (may be different from search bug)
- #650 - Workaround info (informational, not a bug report)
- #674 - Request for new release (meta issue about requesting the fix)
