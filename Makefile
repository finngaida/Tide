TARGET = tide
LIB_NAME = $(TARGET)
PKG_NAME = $(TARGET)

PREFIX ?= /usr/local

UNAME := $(shell uname)

.PHONY: install package

all:	libtide.a

SRCS=$(wildcard Tide/*.c)
HDRS=$(wildcard Tide/*.h)

libtide.a:	$(SRCS)
	clang -c -fPIC $(SRCS)
ifeq ($(UNAME), Linux) # build for linux
	ar -rcs lib$(LIB_NAME).a *.o
endif
ifeq ($(UNAME), Darwin) # build for darwin
	libtool -dynamic *.o -o lib$(LIB_NAME).dylib -lSystem -macosx_version_min 10.11
endif
	rm *.o

install:	libtide.a
	mkdir -p $(TARGET)/usr/local/lib
	mkdir -p $(TARGET)/usr/local/include/$(TARGET)
	cp $(HDRS) $(TARGET)/usr/local/include/$(TARGET)
ifeq ($(UNAME), Darwin)
	# copy .dylib
	cp lib$(LIB_NAME).dylib $(TARGET)/usr/local/lib/
endif
ifeq ($(UNAME), Linux)
	# copy .a
	cp lib$(LIB_NAME).a $(TARGET)/usr/local/lib/
endif
	mkdir -p $(PREFIX)
	cp -r $(TARGET)/usr/local/* $(PREFIX)/

package:
ifeq ($(UNAME), Linux)
	mkdir -p $(TARGET)/DEBIAN
	mkdir -p $(TARGET)/usr/local/lib
	mkdir -p $(TARGET)/usr/local/include/$(TARGET)
	cp *.h $(TARGET)/usr/local/include/$(TARGET)
	cp lib$(LIB_NAME).a $(TARGET)/usr/local/lib/
	touch $(TARGET)/DEBIAN/control
	echo "Package: $(PKG_NAME)" >> $(TARGET)/DEBIAN/control
	echo "Version: 0.1.0" >> $(TARGET)/DEBIAN/control
	echo "Section: custom" >> $(TARGET)/DEBIAN/control
	echo "Priority: optional" >> $(TARGET)/DEBIAN/control
	echo "Architecture: all" >> $(TARGET)/DEBIAN/control
	echo "Essential: no" >> $(TARGET)/DEBIAN/control
	echo "Installed-Size: 4772" >> $(TARGET)/DEBIAN/control
	echo "Maintainer: zewo.io" >> $(TARGET)/DEBIAN/control
	echo "Description: $(TARGET)" >> $(TARGET)/DEBIAN/control
	dpkg-deb --build $(TARGET)
	rm -rf $(TARGET)
endif
