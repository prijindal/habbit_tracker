#!/bin/sh
set -e

curl -sL https://firebase.tools | bash

echo "$FIREBASE_SERVICE_ACCOUNT_HABBIT_TRACKER_PRIJINDAL" > google-application-credentials.json

cat google-application-credentials.json

env GOOGLE_APPLICATION_CREDENTIALS="google-application-credentials.json" flutterfire configure -y \
  --platforms=android,ios,macos,web,linux,windows \
  --ios-bundle-id=com.prijindal.habbit-tracker \
  --macos-bundle-id=com.prijindal.habbit-tracker \
  --web-app-id=1:739292996360:web:5c24f4c3b47c73559e82bd \
  --android-package-name=com.prijindal.habbit_tracker