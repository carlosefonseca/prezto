#!/usr/bin/env bash

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Finds the latest installed version of aapt and runs it as if it was on the path.
alias aapt=$ANDROID_HOME/build-tools/$(ls -1 $ANDROID_HOME/build-tools | tail -n 1)/aapt

# Downloads the APK for a package name. Does not support app bundles.
# adbpullpkg com.google.android.chrome
function adbpullpkg {
  adb pull $(adb shell pm path $1 | tr '\r' '\n' | perl -pe 's/package:(\W+)[\s\n]*/\1/g' ) $1.apk
  mv $1.apk $(aapt dump badging $1.apk | head -n 1 | perl -pe "s/.*name='([a-z\.]+?)' versionCode='(\d+)?' .*/\1-\2.apk/")
}

# Launches the app with the package name.
# adblaunch com.guestu.app
function adblaunch {
  adb shell monkey -p "$1" 1
}

# Launches the app with the package name and waits for a debugger to attach.
# adblaunchD com.guestu.app
function adblaunchD {
  PKG=$(adb shell pm dump $1 | grep android.intent.action.MAIN -A 1 | head -n 2 | tail -n 1 | tr '\r' ' ' | perl -pe 's/\s+\w+ (\S+).*/\1/') 
  echo "adb shell am start -n \"$PKG\" -D"
  adb shell am start -n "$PKG" -D
}

# Restarts the app with the package name.
# adbrestart com.guestu.app
function adbrestart {
  adb shell am force-stop $1 > /dev/null
  adb shell am force-close $1 > /dev/null
  adblaunch $1
}

# Lists all devices packages, except some manufacter apps.
alias adblp='adb shell pm list packages | sort | egrep -v "(qualcomm|qti|e:android|com.zte)" | sed "s/package://" | tr -d "\r"'

# Uninstalls all apps containing the specified text in the package name.
# adbuninstall com.guest
function adbuninstall {
  for f in $(adblp | grep $1); do echo $f && adb uninstall $f; done
}

# Simulates keyboard input, entering the specified text
# adbtype "blah blah blah"
adbtype() {
  adb shell input keyboard text "$(perl -p -e 's/([&;])/\\\1/g' <<< $1)"
}

# Simulates the press of enter
alias adbtypeEnter="adb shell input keyevent event_code 66"

# Renames an APK to be package.name-build[-DEBUG].apk
function nameapk {
  mv $1 $(n $1)
}

# Generates a name for an APK in the format package.name-build[-DEBUG].apk
function _nameapk {
  AA=$(aapt dump badging $1)
  if [[ $AA =~ .*application-debuggable.* ]]
  then
    D="-DEBUG"
  else
    D=""
  fi
  echo $(head -n 1 <<< $AA | perl -pe "s/.*name='([\w\d\.]+?)' versionCode='(\d+)?' .*/\1-\2$D.apk/") 
}


# Outputs a timestamp in the format YYYY-MM-DD_HH:mm:ss
function _timestamp {
  date +"%F_%H.%M.%S"
}

# Takes a screenshot of the device and saves as a file in the current dir
function adbscreen {
  if [ -z ANDROID_SERIAL ]; then
    A="screen-$(_timestamp).png"
  else
    A="screen-$(_timestamp)-$ANDROID_SERIAL.png"
  fi

  if (( $(adb shell getprop ro.build.version.sdk|tr -d '\r') > 23 )); then
    adb shell screencap -p  > $A
  else
    adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > $A
  fi
  echo "$A"
}

# Takes a screenshot of the device and opens it.
adbscreenopen() {
  open $(adbscreen) 
}

# Helps find device settings by showing you what a toggle changed.
# Dumps all the settings of the device into a folder,
# asks you the change the setting you need,
# dumps all the settings to another folder and opens a diff of the folders.
function adbfindsetting {
  mkdir /tmp/a
  mkdir /tmp/b
  adb shell settings list secure >! /tmp/a/settingsSecure.txt
  adb shell settings list system >! /tmp/a/settingsSystem.txt
  adb shell settings list global >! /tmp/a/settingsGlobal.txt

  echo "Current settings state dumped. Change the desired setting and press Enter"
  read

  adb shell settings list secure >! /tmp/b/settingsSecure.txt
  adb shell settings list system >! /tmp/b/settingsSystem.txt
  adb shell settings list global >! /tmp/b/settingsGlobal.txt

  if hash ksdiff 2>/dev/null; then
    ksdiff -w /tmp/a /tmp/b # Kaleidoscope
  else
    opendiff /tmp/a /tmp/b # Xcode's FileMerge
    echo "Press Enter to delete the dumps"
    read
  fi

  rm -rf /tmp/a /tmp/b
}

adbanimations() {
  if [ $# -eq 0 ]; then
    echo "Usage:"
    echo " $0 0   # disable animations"
    echo " $0 1   # enable animations"
  else
    adball shell settings put global window_animation_scale $1
    adball shell settings put global transition_animation_scale $1
    adball shell settings put global animator_duration_scale $1
  fi
}

export SET_ANDROID_PATH=${0:h}/setAndroid.rb

# runs an adb command on all devices
# ex: adball install -r somefile.apk
function adball {
    adb devices | grep -v List | grep device | perl -p -e 's/(\w+)\s.*/\1/' | xargs -I § adb -s § "$@"
}

setandroid() {
  # print device list
  $SET_ANDROID_PATH
  # get device count
  n=$($SET_ANDROID_PATH simple | wc -l)
  if [ $n -eq 1 ]; then
    # if only one device, does not ask user
    number=1
  else
    # if more than one device, ask the user for which one
    read "?Device: " number
  fi

  # if is number and within range
  if [[ "$number" =~ ^[0-9]+$ ]] && [ "$number" -ge 1 -a "$number" -le $n ]; then
    # obtains the device id, stores in env
    export ANDROID_SERIAL=$($SET_ANDROID_PATH ${number})
    # obtains the device model, stores in env
    export ANDROID_MODEL=$($SET_ANDROID_PATH model)
    # prints the current env
    env | grep ANDROID_SERIAL --color=never
    return 0
  fi
  echo "invalid"
  return 1
}


function prepareLatestApk {
  file=$(gfind . -name "*.apk" -printf '%Ts\t%p\n' | sort -nr | cut -f2 | head -n 1)
  pushd $(dirname $file)
  
  # nameapk
  new_file=$(n $file)
  mv $file $new_file
  
  open -R $new_file
  popd
}
