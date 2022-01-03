.PHONY: pigeon deploy-receiver open-android open-ios run-all

pigeon: # Generates the typesafe bridge between host and flutter
	flutter pub run pigeon \
	--input pigeon/PlatformBridgeApisDefinition.dart \
	--dart_out lib/src/PlatformBridgeApis.dart \
	--objc_header_out ios/Classes/PlatformBridgeApis.h \
	--objc_source_out ios/Classes/PlatformBridgeApis.m \
	--java_out ./android/src/main/java/com/gianlucaparadise/flutter_cast_framework/PlatformBridgeApis.java \
	--java_package "com.gianlucaparadise.flutter_cast_framework"

deploy-receiver:
	surge receiver

open-android:
	studio example/android

open-ios:
	open example/ios/Runner.xcworkspace

run-all:
	cd example && flutter run -d all

docs:
	flutter pub run dartdoc --output docs/api