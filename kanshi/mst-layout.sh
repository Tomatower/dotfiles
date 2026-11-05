#!/bin/sh
# ~/.config/kanshi/mst-layout.sh: position MST screens by stable port path
#
#

# TO find nthe mapping:
# 1. find the MST-Adresses:
# drm_info -j | jq -r '.[].connectors[] | select(.properties.PATH) | "DP-\(.encoder_id) \(.properties.PATH.data // .properties.PATH.value)"'
#
# then plug them here
#
# for p in mst:3-1 mst:3-2 mst:3-3; do
#  id=$(drm_info -j | jq -r --arg p "$p" '.[].connectors[] | select((.properties.PATH.data // .properties.PATH.value) == $p) | .id')
#  echo "$p -> $(grep -l "^$id\$" /sys/class/drm/card*-*/connector_id)"
#done

LEFT="mst:3-2"
RIGHT="mst:3-3"

name_for() {  # $1 = MST port path -> sway output name
  id=$(drm_info -j | jq -r --arg p "$1" \
    '.[].connectors[] | select((.properties.PATH.data // .properties.PATH.value) == $p) | .id')
  [ -n "$id" ] || return
  for f in /sys/class/drm/card*-*/connector_id; do
    [ "$(cat "$f")" = "$id" ] && { n=$(basename "$(dirname "$f")"); echo "${n#card*-}"; }
  done
}
width() { swaymsg -t get_outputs | jq -r --arg n "$1" '.[] | select(.name == $n) | .rect.width'; }

x=0
for out in "$(name_for $LEFT)" eDP-1 "$(name_for $RIGHT)"; do
  [ -n "$out" ] || continue
  swaymsg output "$out" position "$x" 0
  x=$((x + $(width "$out")))
done
