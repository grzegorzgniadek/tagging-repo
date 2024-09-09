#! /usr/bin/bash

# !!! FILE NEEDED FOR GITHUB VERSIONING !!!

VERSION_ONLY=false
OLD_VERSION="no"
HOTFIX=false
VERSION=""

while [[ $# -gt 0 ]]; do
  case $1 in
  "-v" | "--version")
    shift
    OLD_VERSION="$1"
    ;;
  "-q")
    VERSION_ONLY=true
    ;;
  "-h")
    HOTFIX=true
    ;;
  esac
  shift
done

COMMIT=$(git show -s --format=%B)
COMMIT=${COMMIT,,}

MAJOR_MATCH="(major|breaking)[:|\/|\(]"
MINOR_MATCH="feat[:|\/|\(]"
PATCH_MATCH="fix[:|\/|\(]"

[[ $OLD_VERSION == "no" ]] && OLD_VERSION=$(git describe --tags --abbrev=0)
[[ $OLD_VERSION =~ "-" ]] && HOTFIX=true
OLD_VERSION=$(sed 's:^v::' <<<"$OLD_VERSION")

if [[ $HOTFIX == "true" ]]; then
  BASE=$(sed 's:-.*$::g' <<<"$OLD_VERSION")

  [[ $OLD_VERSION =~ "-" ]] &&
    HOTFIX=$(sed 's:^.*-::g' <<<"$OLD_VERSION") ||
    HOTFIX=0

  HOTFIX=$((HOTFIX + 1))
  VERSION="v$BASE-$HOTFIX"

else
  MAJOR=$(sed 's:\.[0-9]*\.[0-9]*$::g' <<<"$OLD_VERSION")
  MINOR=$(sed 's:^[0-9]*\.::;s:\.[0-9]*$::g' <<<"$OLD_VERSION")
  PATCH=$(sed 's:^[0-9]*\.[0-9]*\.::g' <<<"$OLD_VERSION")

  if [[ $COMMIT =~ $MAJOR_MATCH ]]; then
    MAJOR=$((MAJOR + 1))
    MINOR="0"
    PATCH="0"

  elif [[ $COMMIT =~ $MINOR_MATCH ]]; then
    MINOR=$((MINOR + 1))
    PATCH="0"

  elif [[ $COMMIT =~ $PATCH_MATCH ]]; then
    PATCH=$((PATCH + 1))

  else
    PATCH=$((PATCH + 1))
  fi

  VERSION="v$MAJOR.$MINOR.$PATCH"
fi

[[ $VERSION_ONLY == "true" ]] && echo "$VERSION"

[[ ! $VERSION_ONLY == "true" ]] && echo "Old version: v$OLD_VERSION"
[[ ! $VERSION_ONLY == "true" ]] && echo "New version: $VERSION"
exit 0