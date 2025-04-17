rm -rf test
dart run build_runner clean

dart run build_runner build -config testcode --delete-conflicting-outputs  --verbose

