# autosms

A automatic SMS sender/receiver and calendar reader Flutter project.

## Build and release on Android

**Release the app bundle on Android Studio** as I am not using the Flutter `key.properties` files since I don't want to store them in plain text.

### Icons

Run the following commands to set up the icons. Review the flutter icon configuration section (`flutter_launcher_icons`) in the `pubspec.yaml` file if anything need to be updated.

```cmd
flutter pub get
dart run flutter_launcher_icons
```
