# Define variables
rootdir := $(shell pwd)
instdir := $(rootdir)/buildDir
vlc := $(instdir)/bin/vlc
ffmpeg := $(instdir)/bin/ffmpeg
x264 := $(instdir)/bin/x264
x265 := $(instdir)/bin/x265
fdk := $(instdir)/lib/libfdk-aac.a
yasm := $(instdir)/bin/yasm
mad := $(instdir)/lib/libmad.a
a52 := $(instdir)/bin/a52dec
ogg := $(instdir)/lib/libogg.a
vorbis := $(instdir)/lib/libvorbis.a
theora := $(instdir)/lib/libtheora.a
vpx := $(instdir)/bin/vpxenc
flac := $(instdir)/bin/flac
CFG_PKG_CONFIG_PATH := $(instdir)/lib/pkgconfig
CFG_LDFLAGS := -L$(instdir)/lib
CFG_CPPFLAGS := -I$(instdir)/include
CFG_PATH := $(instdir)/bin
all := $(vlc) $(ffmpeg) $(x264) $(x265) $(fdk) $(mad) $(a52) $(vorbis) $(theora) $(vpx) $(flac) $(yasm) $(ogg)

# Default build target
default: $(all)

# Define build dependencies
$(vlc): vlc-2.2.8.tar.xz $(ffmpeg)
$(ffmpeg): ffmpeg-2.3.3.tar.bz2 $(x264) $(x265) $(fdk) $(mad) $(a52) $(vorbis) $(theora) $(vpx) $(flac)
$(x264): last_x264.tar.bz2 $(yasm)
$(x265): x265_2.6.tar.gz $(yasm)
$(fdk): fdk-aac-master.zip
$(yasm): yasm-1.3.0.tar.gz
$(mad): libmad-0.15.1b.tar.gz
$(a52): a52dec-0.7.4.tar.gz
$(ogg): libogg-1.3.2.tar.xz
$(vorbis): libvorbis-1.3.4.tar.xz $(ogg)
$(theora): libtheora-1.1.1.tar.bz2 $(ogg)
$(vpx): libvpx-v1.3.0.tar.bz2 $(yasm)
$(flac): flac-1.3.0.tar.xz

# Define extraction directories
$(vlc): extdir := vlc-2.2.8
$(ffmpeg): extdir := ffmpeg-2.3.3
$(x264): extdir := x264-snapshot-20140817-2245
$(x265): extdir := x265_v2.6
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
$(vlc): conf := ./configure --disable-lua --without-kde-solid --prefix=$(instdir)
$(ffmpeg): conf := ./configure --enable-shared --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libx264 --enable-libvorbis --enable-libvpx --enable-libx265 --prefix=$(instdir)
$(x264): conf := ./configure --disable-opencl --enable-static --enable-shared --prefix=$(instdir)
$(x265): conf := cmake -DCMAKE_INSTALL_PREFIX:PATH=$(instdir) source
$(fdk): conf := ./autogen.sh && ./configure --prefix=$(instdir)
$(yasm): conf := ./configure --prefix=$(instdir)
$(mad): conf := CFLAGS="-Wall -g -O -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2" ./configure --prefix=$(instdir)
$(a52): conf := CFLAGS=-fPIC ./configure --prefix=$(instdir)
$(ogg): conf := ./configure --prefix=$(instdir)
$(vorbis): conf := ./configure --prefix=$(instdir)
$(theora): conf := ./configure --prefix=$(instdir)
$(vpx): conf := ./configure --enable-shared --prefix=$(instdir)
$(flac): conf := ./configure --prefix=$(instdir)

$(all):
	tar xvf $< || unzip $<
	cd $(extdir) && PATH="$(CFG_PATH):$$PATH" LDFLAGS=$(CFG_LDFLAGS) CPPFLAGS=$(CFG_CPPFLAGS) PKG_CONFIG_PATH=$(CFG_PKG_CONFIG_PATH) $(conf)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir)
	PATH="$(CFG_PATH):$$PATH" $(MAKE) -C $(extdir) -j1 install

clean:
	rm -rf `find . -mindepth 1 -maxdepth 1 -type d -not -path ./.git`
