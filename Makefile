pigeon: # Generates the typesafe bridge between host and flutter
	flutter pub run pigeon \
	--input lib/src/HostApisDefinition.dart \
	--dart_out lib/src/HostApis.dart \
	--objc_header_out ios/Classes/HostApis.h \
	--objc_source_out ios/Classes/HostApis.m \
	--java_out ./android/src/main/java/com/gianlucaparadise/flutter_cast_framework/HostApis.java \
	--java_package "com.gianlucaparadise.flutter_cast_framework"