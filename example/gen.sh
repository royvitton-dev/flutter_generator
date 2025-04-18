#!/bin/bash
config_name="$1"

rm -rf gen
rm -rf test
dart run build_runner clean

command=""
if [ "$config_name" == "class" ]; then
  echo "build : class\n"
  command=--build-filter "gen/class/**.class.md"
  build_command="dart run build_runner build --build-filter "gen/class/**.class.md" --delete-conflicting-outputs --verbose"
elif [ "$config_name" == "sequence" ]; then
  echo "build : sequence\n"
  command=--build-filter "gen/sequence/**.seq.md"
  # build_command="dart run build_runner build "$command" --delete-conflicting-outputs --verbose"
  build_command="dart run build_runner build --build-filter "gen/sequence/**.seq.md" --delete-conflicting-outputs --verbose"
elif [ "$config_name" == "testcode" ]; then
  echo "build : testcode\n"
  command=--build-filter "test/**_test.dart"
  build_command="dart run build_runner build --build-filter "test/**_test.dart" --delete-conflicting-outputs --verbose"
  dart run build_runner build --build-filter "lib/**_test.dart" --delete-conflicting-outputs --verbose
  # build_command="dart run build_runner build "$command" --delete-conflicting-outputs --verbose"
elif [ "$config_name" == "" ]; then
  echo "build : class, sequence, testcode\n"
  
  build_command="dart run build_runner build --delete-conflicting-outputs --verbose"
else
  echo "\n입력 파마메터 오류, 사용 가능한 입력 파라메터: class, sequence, testcode\n"
  exit 1
fi

# build_command="dart run build_runner build "$command" --delete-conflicting-outputs --verbose"
# echo $build_command
# dart run build_runner build $command --delete-conflicting-outputs --verbose
$build_command