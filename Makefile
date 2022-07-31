.PHONY: pigeon deploy-receiver open-android open-ios run-all

pigeon: # Generate the typesafe bridge between host and flutter
	flutter pub run pigeon \
	--input pigeon/PlatformBridgeApisDefinition.dart \
	--dart_out lib/src/PlatformBridgeApis.dart \
	--objc_header_out ios/Classes/PlatformBridgeApis.h \
	--objc_source_out ios/Classes/PlatformBridgeApis.m \
	--java_out ./android/src/main/java/com/gianlucaparadise/flutter_cast_framework/PlatformBridgeApis.java \
	--java_package "com.gianlucaparadise.flutter_cast_framework"

deploy-receiver: # Deploy the example receiver
	surge receiver

open-android: # Open Android Studio with the correct project configuration
	studio example/android

open-ios: # Open XCode with the correct project configuration
	open example/ios/Runner.xcworkspace

run-all: # Run on all devices
	cd example && flutter run -d all

docs: # Generate documentation
	flutter pub run dartdoc --output doc/api