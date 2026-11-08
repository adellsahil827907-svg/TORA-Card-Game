
name: Build TORA APK

on:
  workflow_dispatch:
  push:
    paths:
      - 'lib/main.dart'
      - 'TORA_Sahil_Fixed.zip'
      - '.github/workflows/build-apk.yml'

jobs:
  build:
    name: Build TORA Android APK
    runs-on: ubuntu-24.04

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Check project files
        run: |
          test -f TORA_Sahil_Fixed.zip
          test -f lib/main.dart

      - name: Extract TORA project
        run: |
          mkdir source
          unzip -q TORA_Sahil_Fixed.zip -d source

      - name: Create Android project
        run: |
          flutter create --platforms=android --project-name tora_app project
          cp -r source/TORA_Flutter_Starter/lib project/
          cp source/TORA_Flutter_Starter/pubspec.yaml project/

      - name: Fix Gradle download
        working-directory: project
        run: |
          sed -i 's#^distributionUrl=.*#distributionUrl=https\\://downloads.gradle.org/distributions/gradle-9.3.1-bin.zip#' android/gradle/wrapper/gradle-wrapper.properties

      - name: Apply TORA code
        run: |
          cp lib/main.dart project/lib/main.dart

      - name: Install dependencies
        working-directory: project
        run: flutter pub get

      - name: Build release APK
        working-directory: project
        run: |
          for attempt in 1 2 3; do
            flutter build apk --release && exit 0
            echo "Build attempt $attempt failed. Retrying..."
            sleep 15
          done
          exit 1

      - name: Upload TORA APK
        uses: actions/upload-artifact@v4
        with:
          name: TORA-APK
          path: project/build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error
