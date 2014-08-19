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
ogg := $(instdir)/bin/ogg
vorbis := $(instdir)/bin/vorbis
theora := $(instdir)/bin/theora
vpx := $(instdir)/bin/vpx
flac := $(instdir)/bin/flac
CFG_PKG_CONFIG_PATH := $(instdir)/lib/pkgconfig
CFG_LDFLAGS := -L$(instdir)/lib
CFG_CPPFLAGS := -I$(instdir)/include
CFG_PATH := $(instdir)/bin

# Default build target
default: $(vlc)

# Define build dependencies
$(vlc): vlc-2.1.5.tar.xz $(ffmpeg)
$(ffmpeg): ffmpeg-2.3.3.tar.bz2 $(x264) $(fdk) $(mad) $(a52) $(ogg) $(vorbis) $(theora) $(vpx) $(flac)
$(x264): last_x264.tar.bz2 $(yasm)
$(fdk): fdk-aac-master.zip
$(yasm): yasm-1.3.0.tar.gz
$(mad): libmad-0.15.1b.tar.gz
$(a52): a52dec-0.7.4.tar.gz
$(ogg): libogg-1.3.2.tar.xz
$(vorbis): libvorbis-1.3.4.tar.xz
$(theora): libtheora-1.1.1.tar.bz2
$(vpx): libvpx-v1.3.0.tar.bz2
$(flac): flac-1.3.0.tar.xz

# Define extraction directories
$(vlc): extdir := vlc-2.1.5
$(ffmpeg): extdir := ffmpeg-2.3.3
$(x264): extdir := x264-snapshot-20140817-2245
$(fdk): extdir := fdk-aac-master
$(yasm): extdir := yasm-1.3.0
$(mad): extdir := libmad-0.15.1b
$(a52): extdir := a52dec-0.7.4
$(ogg): extdir := libogg-1.3.2
$(vorbis): extdir := libvorbis-1.3.4
$(theora): extdir := libtheora-1.1.1
$(vpx): extdir := libvpx-v1.3.0
$(flac): extdir := flac-1.3.0

# Define configure parameters
$(vlc): conf := ./configure --disable-lua --without-kde-solid
$(ffmpeg): conf := ./configure --enable-shared --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libx264
$(x264): conf := ./configure --disable-opencl --enable-static --enable-shared
$(fdk): conf := ./autogen.sh && ./configure
$(yasm): conf := ./configure
$(mad): conf := CFLAGS="-Wall -g -O -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2" ./configure
$(a52): conf := CFLAGS=-fPIC ./configure
$(ogg): conf := ./configure
$(vorbis): conf := ./configure
$(theora): conf := ./configure
$(vpx): conf := ./configure
$(flac): conf := ./configure

%:
	tar xvf $< || unzip $<
	cd $(extdir) && PATH="$(CFG_PATH):$$PATH" LDFLAGS=$(CFG_LDFLAGS) CPPFLAGS=$(CFG_CPPFLAGS) PKG_CONFIG_PATH=$(CFG_PKG_CONFIG_PATH) $(conf) --prefix=$(instdir)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir) -j1 install

clean:
	rm -rf `find . -mindepth 1 -maxdepth 1 -type d -not -path ./.git`
