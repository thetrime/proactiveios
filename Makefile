# You must specify a profile if you want to deploy to the device
include developer.profile
# This should set the variables DEVELOPER_PROFILE and TEAM_MEMBER_ID. Working these out is not trivial unfortunately :(

# You probably also need a valid provisioning profile. Generating this is a real PITA and the free ones now only last a week
# This also requires ios-deploy to be installed
# And you also need to create an ent.plist file to describe the entitlements. I dont know how to specify this in a generic way though.  I have my team-identifier and <team-identifier + "." + BUNDLE_ID, truncated to 29 characters(!?) > as the application-identifier
# You can test in the simulator without any of that stuff though.

# These are things to configure per-project
DEVICE_TYPE=iPhone 5S
DISPLAY_NAME=ProactiveTest
APP_NAME=proactive
BUNDLE_ID=com.trime.${APP_NAME}
TARGET=device
XCODE_BASE=/Applications/Xcode.app/Contents

ifeq ($(TARGET),simulator)
SDKROOT=$(XCODE_BASE)/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
SIMULATOR=$(XCODE_BASE)/Developer/Applications/Simulator.app/Contents/MacOS/Simulator
CFLAGS=-g -mios-simulator-version-min=6.1 -isysroot ${SDKROOT} -I${SDKROOT}/usr/include/
else
SDKROOT=$(XCODE_BASE)/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
CFLAGS=-arch arm64 -pipe -no-cpp-precomp -isysroot ${SDKROOT} -mios-version-min=6.1 -I${SDKROOT}/usr/include/
endif


FRAMEWORKS=$(SDKROOT)/System/Library/Frameworks/


all: ${APP_NAME}.app ${APP_NAME}.app/main ${APP_NAME}.app/Info.plist

${APP_NAME}.app:
	@mkdir $@

${APP_NAME}.app/main: src/main.m
	clang $(CFLAGS) -F$(FRAMEWORKS) -o ${APP_NAME}.app/main src/main.m -framework Foundation -framework UIKit

${APP_NAME}.app/Info.plist: Makefile
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n	<key>CFBundleDisplayName</key>\n	<string>${DISPLAY_NAME}</string>\n	<key>CFBundleExecutable</key>\n	<string>main</string>\n	<key>CFBundleIdentifier</key>\n	<string>${BUNDLE_ID}</string>\n	<key>CFBundleName</key>\n	<string>${APP_NAME}</string>\n	<key>CFBundleVersion</key>\n	<string>1.0</string>\n	<key>LSRequiresIPhoneOS</key>\n	<true/>\n	<key>UILaunchStoryboardName</key>\n	<string>LaunchScreen</string>        \n	<key>UISupportedInterfaceOrientations</key>\n	<array>\n		<string>UIInterfaceOrientationPortrait</string>\n		<string>UIInterfaceOrientationLandscapeLeft</string>\n		<string>UIInterfaceOrientationLandscapeRight</string>\n	</array>\n</dict>\n</plist>' > $@

Entitlements.plist: Makefile
	@echo '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n	<key>application-identifier</key>\n	<string>${TEAM_MEMBER_ID}.${BUNDLE_ID}</string>\n</dict>\n</plist>' > $@


clean:
	rm -rf ${APP_NAME}.app

run:	${APP_NAME}.app/main ${APP_NAME}.app/Info.plist
	xcrun instruments -w "$(DEVICE_TYPE)" || true
	xcrun simctl install booted ${APP_NAME}.app
	xcrun simctl launch booted ${BUNDLE_ID}

deploy:	${APP_NAME}.ipa
	ios-deploy --bundle $<

${APP_NAME}.ipa: ${APP_NAME}.app ${APP_NAME}.app/main ${APP_NAME}.app/Info.plist Entitlements.plist
	codesign --force --sign "${DEVELOPER_PROFILE}" --entitlements Entitlements.plist ${APP_NAME}.app
	xcrun -sdk iphoneos PackageApplication  ${APP_NAME}.app -o /tmp/${APP_NAME}.ipa 
	mv /tmp/${APP_NAME}.ipa $@


