#!/usr/bin/env bash

title="Flame of Hope Godot"
platforms=(windows osx linux html5)

usage() {
  echo "Export game for Windows, OSX, Linux and HTML5 with specified version."
  echo "Usage: export.sh VERSION

ARGUMENTS
  VERSION               Version number, without the 'v'. Ex: '3.1.2'
"
}

if [[ $# -ne 1 ]]; then
  echo "Wrong number of arguments: found $#, expected 1."
  echo "Passed arguments: $@"
  usage
  exit 1
fi

version=$1

export_release() {
  preset="$1"
  version_folder="$2"
  target="$3"

  mkdir -p "Export/$version_folder"
  godot --no-window --export "$preset" "Export/$version_folder/$target"
}

export_platform_release() {
  version="$1"
  platform="$2"

  case "$platform" in
    windows )
      preset="Windows Desktop"
      folder="Windows"
      target="${title}.exe"
      ;;
    linux )
      preset="Linux/X11"
      folder="Linux"
      target="${title}.x86_64"
      ;;
    osx )
      preset="Mac OSX"
      folder="OSX"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        target="${title}.dmg"
      else
        target="${title}.zip"
      fi
      ;;
    html5 )
      preset="HTML5"
      folder="HTML5"
      target="index.html"
      ;;
  esac

  export_release "$preset" "v$version/$folder" "$target"
}

for platform in ${platforms[*]}; do
  echo "Exporting for $platform..."
  export_platform_release "$version" "$platform"
done
