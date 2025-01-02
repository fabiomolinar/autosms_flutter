# autosms

A automatic SMS sender/receiver and calendar reader Flutter project.

## Build and release on Android

### Icons

Run the following commands to set up the icons. Review the flutter icon configuration section (`flutter_launcher_icons`) in the `pubspec.yaml` file if anything need to be updated.

```cmd
flutter pub get
dart run flutter_launcher_icons
```

## Other notes

### keytool

To use keytool, I need to call it from where it was installed: `"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"`. A command would look like this: `"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore ./upload-keystore.jks -alias upload`.