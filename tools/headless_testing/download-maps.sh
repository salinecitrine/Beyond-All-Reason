#!/bin/bash

engine/*/pr-downloader --filesystem-writepath "$BAR_ROOT" --download-map "Full Metal Plate 1.5"

for map_name in "$@"; do
    engine/*/pr-downloader --filesystem-writepath "$BAR_ROOT" --download-map "$map_name"
done
