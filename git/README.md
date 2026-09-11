# Git Scripts

This directory contains scripts for interacting with Git and managing remote branches.

## Find Remote Branches Containing String

The script `find-remote-branches-containing-string_original.sh` is a tool to find branches that contain specific content.

### Description
This script fetches and prunes all remote-tracking references, enumerates every known remote branch, skips symbolic HEAD references, and searches the current contents of each branch for the literal string `SCN2`. For every branch containing at least one match in a non-binary file, it prints the branch name without the remote name prefix.

### Usage
You can run the script from the `git/` directory.

```bash
./find-remote-branches-containing-string_original.sh
```
