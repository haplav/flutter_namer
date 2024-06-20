# Flutter Namer
A random generator of funny names consisting of English word pairs. Written in Dart/Flutter.

The latest commit is deployed automatically as a web app at https://haplav.github.io/flutter_namer/, so you can easily play around with it.
Have fun!

## Acknowledgement
* This is my first Flutter app based on [this cool tutorial](https://codelabs.developers.google.com/codelabs/flutter-codelab-first).
  - Thanks Filip Hracek!
* This app also has all the features of Filip's [extended version](https://dartpad.dev/?id=e7076b40fb17a0fa899f9f7a154a02e8).
  - I figured them out by myself, as seen in the commit history.

## Additional features
(not covered in the tutorial and extended version)
* persistance using the [path_provider](https://pub.dev/packages/path_provider) package (desktop/mobile app) or browser local storage (web)
* switching between pages by horizontal swiping
* Bin section for unliked item management (Restore / Delete permanently)
* Delete all / Restore all links in Favorites
* icon overlays with numbers of items in the given section
* button for history list purge
* cool animation of the history list purge
* toast messages
* logging
* separation into multiple source files
