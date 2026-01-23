# Apple Platforms

Mac / iOS / iPadOS / iEtcOS as we see fit.

The Mac/AppKit version is the primary one for editing, and where new
features are tried first.

Other apps (and platforms) (will) tend to either treat a generated Borkle 
document as read-only, or give some powered exoskeleton on top of it.

# Progress

bootstrapping basic data structures.  This loads and stores from a fixed
place in the file system, shows bubbles in a table, and lets you enter new
bubbles via a crude form.

![](assets/bubbles-1.gif)

Some refaxoring, also dynamically resizes the row height as the tableview resizes..

![](assets/bubbles-2.gif)

Adding a search field and a table of tags

![](assets/bubbles-3.gif)
