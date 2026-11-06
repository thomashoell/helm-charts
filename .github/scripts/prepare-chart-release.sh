#!/usr/bin/env bash
# Called by semantic-release (@semantic-release/exec prepareCmd) in the chart directory.
#   $1: next chart version
# - sets "version" in Chart.yaml
# - syncs "appVersion" from the image tag in values.yaml, which Dependabot keeps up to date.
#   Default path is .image.tag; charts can override it with the Chart.yaml annotation
#   thomashoell.github.io/app-version-from (e.g. ".server.image.tag").
set -euo pipefail

version="$1"
sed -i -E "s/^version:.*/version: ${version}/" Chart.yaml

path=$(yq '.annotations."thomashoell.github.io/app-version-from" // ".image.tag"' Chart.yaml)
tag=$(yq "${path} // \"\"" values.yaml)

if [[ -z "$tag" ]]; then
  echo "No image tag at ${path} in values.yaml, appVersion left unchanged"
  exit 0
fi

sed -i -E "s/^appVersion:.*/appVersion: \"${tag}\"/" Chart.yaml
echo "version: ${version}, appVersion: ${tag} (from ${path})"
