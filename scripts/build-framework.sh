#!/usr/bin/env bash

set -e

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OUTPUT_DIR=$( mktemp -d )
COMMON_SETUP="-project ${SCRIPT_DIR}/../Swifty360Player.xcodeproj -scheme Swifty360Player -configuration Release -quiet SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"

# macOS Catalyst
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS,variant=Mac Catalyst'

mkdir -p "${OUTPUT_DIR}/maccatalyst"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-maccatalyst/Swifty360Player.framework" "${OUTPUT_DIR}/maccatalyst"
rm -rf "${DERIVED_DATA_PATH}"

# iOS
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS'

mkdir -p "${OUTPUT_DIR}/iphoneos"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/Swifty360Player.framework" "${OUTPUT_DIR}/iphoneos"
rm -rf "${DERIVED_DATA_PATH}"

# iOS Simulator
DERIVED_DATA_PATH=$( mktemp -d )
xcrun xcodebuild build \
	$COMMON_SETUP \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS Simulator'

mkdir -p "${OUTPUT_DIR}/iphonesimulator"
cp -r "${DERIVED_DATA_PATH}/Build/Products/Release-iphonesimulator/Swifty360Player.framework" "${OUTPUT_DIR}/iphonesimulator"
rm -rf "${DERIVED_DATA_PATH}"

# XCFRAMEWORK
xcrun xcodebuild -create-xcframework \
	-framework "${OUTPUT_DIR}/iphoneos/Swifty360Player.framework" \
	-framework "${OUTPUT_DIR}/iphonesimulator/Swifty360Player.framework" \
	-framework "${OUTPUT_DIR}/maccatalyst/Swifty360Player.framework" \
	-output ${OUTPUT_DIR}/Swifty360Player.xcframework

ditto -c -k --keepParent ${OUTPUT_DIR}/Swifty360Player.xcframework Swifty360Player.xcframework.zip

echo "✔️ Swifty360Player.xcframework"

rm -rf ${OUTPUT_DIR}

cd ${BASE_PWD}
