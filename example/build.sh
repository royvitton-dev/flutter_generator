rm -rf gen
rm -rf test
dart run build_runner clean

dart run build_runner build --delete-conflicting-outputs  --verbose

cat ./gen/sequence/util/login.seq.md

