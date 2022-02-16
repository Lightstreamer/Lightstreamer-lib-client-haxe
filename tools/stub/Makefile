.PHONY: android

SHELL = zsh

android:
	javac -sourcepath android -d bin/android android/**/*.java
	cd bin/android && jar cf android-stub.jar *
	cp bin/android/android-stub.jar ../../lib/android
	rm -rf bin