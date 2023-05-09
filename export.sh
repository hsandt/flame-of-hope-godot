#!/usr/bin/env bash

title="Flame of Hope Godot"
all_platforms=(windows macos linux html5)

usage() {
  echo "Export game for Windows, macOS, Linux and HTML5 with specified version."
  echo "Usage: export.sh VERSION TARGET

ARGUMENTS
  VERSION               Version number, without the 'v'. Ex: '3.1.2'
  TARGET                Target platform: 'windows', 'macos', 'linux', 'html5' or 'all'
"
}

if [[ $# -ne 2 ]]; then
  echo "Wrong number of arguments: found $#, expected 2."
  echo "Passed arguments: $@"
  usage
  exit 1
fi

version=$1
target=$2

if [[ "$target" != "all" ]]; then 
  # check if target is valid, i.e. target is in $platforms array
  valid_target=false

  for platform in ${all_platforms[*]}; do
    if [[ "$target" == "$platform" ]]; then
      valid_target=true
      break
    fi
  done
fi

if [[ "$valid_target" == false ]]; then
  echo "Invalid target: '$target'."
  usage
  exit 1
fi

export_release() {
  preset="$1"
  folder="$2"
  target="$3"

  # Remove any existing folder to avoid leftover files if title changed since
  rm -rf "$folder/"
  echo "$folder"

  mkdir -p "$folder"
  godot3.5.2_stable --no-window --export --quiet "$preset" "$folder/$target"
}

export_platform_release() {
  version="$1"
  platform="$2"

  case "$platform" in
    windows )
      preset="Windows Desktop"
      platform_titlecase="Windows"
      target="${title}.exe"
      ;;
    linux )
      preset="Linux/X11"
      platform_titlecase="Linux"
      target="${title}.x86_64"
      ;;
    macos )
      preset="Mac OSX"
      platform_titlecase="macOS"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        target="${title}.dmg"
      else
        target="${title}.zip"
      fi
      ;;
    html5 )
      preset="HTML5"
      platform_titlecase="HTML5"
      target="index.html"
      ;;
    * )
      echo "Invalid platform: '$platform'"
      usage
      exit 1
      ;;
  esac

  version_folder="Export/v$version"
  subfolder="$title v$version - $platform_titlecase"
  folder_path="$version_folder/$title v$version - $platform_titlecase"
  echo "version_folder: $version_folder"
  echo "subfolder: $subfolder"
  echo "folder_path: $folder_path"
  echo "true folder: v$version/$folder_path"

  echo "Exporting for $platform..."
  export_release "$preset" "$folder_path" "$target"

  # Enter the version folder, which is the parent folder of the platform subfolders
  # This is important to zip subfolders without copying the whole hierarchy from cwd
  # See https://superuser.com/questions/119649/avoid-unwanted-path-in-zip-file/119661#119661
  # It's optional for macOS where we only copy a file
  pushd "$version_folder"

    if [[ "$platform" == "macos" ]]; then
      # For OSX, Godot already zips the .app, so we just copy it to the outside folder
      # and rename it to full name with version and platformer, so all zips are in the
      # same folder with the same naming convention, ready for the next step
      #(copy to Drive and/or upload to itch.io)
      echo "Copying zip to outside folder"
      cp "${subfolder}/${title}.zip" "${subfolder}.zip"
    else
      echo "Zipping..."
      zip_path="${subfolder}.zip"
      # delete existing one to be safe
      rm -f "$zip_path"
      zip -r "$zip_path" "$subfolder"
    fi

  popd
}

if [[ "$target" == "all" ]]; then
  platforms=("${all_platforms[*]}")
else
  platforms="$target"
fi
for platform in ${platforms[@]}; do
  echo "Exporting for $platform..."
  export_platform_release "$version" "$platform"
done
