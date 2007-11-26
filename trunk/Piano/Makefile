CC=/usr/local/arm-apple-darwin/bin/gcc
CXX=/usr/local/arm-apple-darwin/bin/g++
CFLAGS=-fsigned-char -I/usr/local/arm-apple-darwin/arm-apple-darwin/include/includes -I/usr/local/arm-apple-darwin/arm-apple-darwin/include/includes/UIKit/ -O3
LDFLAGS=-Wl,-syslibroot,/usr/local/arm-apple-darwin/heavenly -lobjc -ObjC -framework CoreFoundation -framework Foundation -framework UIKit -framework CoreGraphics -framework GraphicsServices -framework Celestial -framework CoreAudio -framework AudioToolbox
LD=$(CC)
APPNAME=Piano

all:	App

App:	main.o App.o SplashView.o TonePlayer.o
		$(LD) $(LDFLAGS) -o $@ $^
		cp App bundle/

%.o:	%.m %.h
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

package: App
	find bundle -type f -name .DS_Store -print0 | xargs -0 rm
	mv bundle $(APPNAME).app
	zip -9r $(APPNAME).zip $(APPNAME).app
	mv $(APPNAME).app bundle

clean:
		rm -f *.o App

