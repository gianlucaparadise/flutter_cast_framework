pigeon: # Generates the typesafe bridge between host and flutter
	flutter pub run pigeon \
	--input lib/src/PlatformBridgeApisDefinition.dart \
	--dart_out lib/src/PlatformBridgeApis.dart \
	--objc_header_out ios/Classes/PlatformBridgeApis.h \
	--objc_source_out ios/Classes/PlatformBridgeApis.m \
	--java_out ./android/src/main/java/com/gianlucaparadise/flutter_cast_framework/PlatformBridgeApis.java \
	--java_package "com.gianlucaparadise.flutter_cast_framework"

deploy-receiver:
	surge receiver