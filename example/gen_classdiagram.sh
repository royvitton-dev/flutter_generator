rm -rf gen
dart run build_runner clean
dart run build_runner build -config classdiagram --delete-conflicting-outputs  --verbose

