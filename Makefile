# Define variables
rootdir := $(shell pwd)
instdir := $(rootdir)/buildDir
vlc := $(instdir)/bin/vlc
ffmpeg := $(instdir)/bin/ffmpeg
x264 := $(instdir)/bin/x264
fdk := $(instdir)/lib/libfdk-aac.a
yasm := $(instdir)/bin/yasm
mad := $(instdir)/lib/libmad.a
a52 := $(instdir)/bin/a52dec
CFG_PKG_CONFIG_PATH := $(instdir)/lib/pkgconfig
CFG_LDFLAGS := -L$(instdir)/lib
CFG_CPPFLAGS := -I$(instdir)/include
CFG_PATH := $(instdir)/bin

# Default build target
default: $(vlc)

# Define build dependencies
$(vlc): vlc-2.1.5.tar.xz $(ffmpeg) $(x264) $(fdk) $(yasm) $(mad) $(a52)
$(ffmpeg): ffmpeg-2.3.3.tar.bz2 $(x264) $(fdk) $(yasm)
$(x264): last_x264.tar.bz2 $(yasm)
$(fdk): fdk-aac-master.zip
$(yasm): yasm-1.3.0.tar.gz
$(mad): libmad-0.15.1b.tar.gz
$(a52): a52dec-0.7.4.tar.gz

# Define extraction directories
$(vlc): extdir := vlc-2.1.5
$(ffmpeg): extdir := ffmpeg-2.3.3
$(x264): extdir := x264-snapshot-20140817-2245
$(fdk): extdir := fdk-aac-master
$(yasm): extdir := yasm-1.3.0
$(mad): extdir := libmad-0.15.1b
$(a52): extdir := a52dec-0.7.4

# Define configure parameters
$(vlc): conf := ./configure --disable-lua
$(vlc): instdir := $(instdir) && sed "s|soliddatadir = /usr/share/kde4/apps//solid/actions|soliddatadir = $(instdir)/share/kde4/apps/solid/actions|"<share/Makefile >tempfile && mv tempfile share/Makefile
$(ffmpeg): conf := ./configure --enable-shared --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libx264
$(x264): conf := ./configure --disable-opencl --enable-static --enable-shared
$(fdk): conf := ./autogen.sh && ./configure
$(yasm): conf := ./configure
$(mad): conf := CFLAGS="-Wall -g -O -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2" ./configure
$(a52): conf := CFLAGS=-fPIC ./configure

$(vlc) $(ffmpeg) $(x264) $(fdk) $(yasm) $(mad) $(a52):
	tar xvf $< || unzip $<
	cd $(extdir) && PATH="$(CFG_PATH):$$PATH" LDFLAGS=$(CFG_LDFLAGS) CPPFLAGS=$(CFG_CPPFLAGS) PKG_CONFIG_PATH=$(CFG_PKG_CONFIG_PATH) $(conf) --prefix=$(instdir)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir) -j1 install

clean:
	rm -rf `find . -mindepth 1 -maxdepth 1 -type d -not -path ./.git`
