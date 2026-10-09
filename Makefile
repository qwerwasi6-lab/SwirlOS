# netsurf/Makefile — builds /system/apps/netsurf.elf (NetSurf 3.11 + the
# SwirlOS platform layer) for the SwirlOS ring-3 slot 14.
#
# Everything under user/netsurf/<lib>/ is UNMODIFIED upstream source.
# The port-specific code lives in swirl/ (+ 4 tiny documented patches in
# netsurf/fb-frontend/gui.c, netsurf/content/fetch.c, libnsfb surface enum).
#
# Toolchain: host gcc -nostdinc + the libc shim (include/ + shim/).
#
# NOTE on include paths: each vendored library compiles with ONLY its own
# include dirs. hubbub and libcss both ship src/charset/detect.h - a flat
# -I list lets one shadow the other (this bit us in the first build).

CC      = gcc
LD      = ld
AR      = ar

BUILD   = build

# `all` must be the default goal: the foreach-emitted object rules
# appear textually before it, otherwise make picks the first object.
.DEFAULT_GOAL := all
N       = $(CURDIR)
NETSURF = $(N)/netsurf
FB      = $(NETSURF)/fb-frontend
GCCINC  = $(shell gcc -print-file-name=include)

# ---- CPU/ABI: ring-3 x86_64, SSE on (the kernel enables SSE at boot,
# same contract as the Calculator/3D/DOOM builds), small code model. ----
CPUFLAGS = -ffreestanding -fcommon -fno-pic -fno-pie -fno-stack-protector -fno-builtin \
	   -mno-red-zone -mcmodel=small -O2 -g \
	   -ffunction-sections -fdata-sections \
	   -fno-asynchronous-unwind-tables -fno-unwind-tables \
	   -MMD -MP
# NetSurf 3.11-era C predates GCC 14's new errors (implicit declarations,
# int-conversion...): these diagnostics are downgraded, not silenced.
WARN     = -w -std=gnu99 \
	   -Wno-error=implicit-function-declaration \
	   -Wno-error=int-conversion \
	   -Wno-error=incompatible-pointer-types \
	   -Wno-error=implicit-int \
	  

# ---- base include order: libc shim first, then gcc's freestanding headers,
# then the NetSurf public headers ----
BASE_INCS = -I$(N)/include -I$(GCCINC) -I$(NETSURF)/include -I$(N)

# ---- NetSurf build configuration (mirrors frontends/framebuffer/Makefile) ----
# NOTE: NDEBUG withheld for now - the post-NDEBUG rebuild broke the
# window repaint path; bisecting. (upstream defines it in releases)
DEFS  = -Dnsframebuffer -Dsmall -D__swirl__
DEFS += -DWITH_SWIRL_FETCHER -DWITH_NSLOG
DEFS += -DWITH_PNG -DWITH_JPEG -DWITH_GIF -DWITH_BMP -DWITH_UTF8PROC
DEFS += '-DNETSURF_UA_FORMAT_STRING="NetSurf/%d.%d (SwirlOS)"'
DEFS += '-DNETSURF_HOMEPAGE="https://en.wikipedia.org/wiki/Main_Page"'
DEFS += -DNETSURF_LOG_LEVEL=VERBOSE
DEFS += '-DNETSURF_BUILTIN_LOG_FILTER="level:VERBOSE"'
DEFS += '-DNETSURF_BUILTIN_VERBOSE_FILTER="level:INFO"'
DEFS += '-DNETSURF_FB_RESPATH="/system/netsurf/res/"'
DEFS += '-DNETSURF_FB_FONTPATH="/system/fonts/"'
DEFS += '-DNETSURF_FB_FONT_SANS_SERIF="sans_serif.ttf"'
DEFS += '-DNETSURF_FB_FONT_SANS_SERIF_BOLD="sans_serif_bold.ttf"'
DEFS += '-DNETSURF_FB_FONT_SANS_SERIF_ITALIC="sans_serif_italic.ttf"'
DEFS += '-DNETSURF_FB_FONT_SANS_SERIF_ITALIC_BOLD="sans_serif_italic_bold.ttf"'
DEFS += '-DNETSURF_FB_FONT_SERIF="serif.ttf"'
DEFS += '-DNETSURF_FB_FONT_SERIF_BOLD="serif_bold.ttf"'
DEFS += '-DNETSURF_FB_FONT_MONOSPACE="monospace.ttf"'
DEFS += '-DNETSURF_FB_FONT_MONOSPACE_BOLD="monospace_bold.ttf"'
DEFS += '-DNETSURF_FB_FONT_CURSIVE="sans_serif.ttf"'
DEFS += '-DNETSURF_FB_FONT_FANTASY="serif.ttf"'
DEFS += -DFB_USE_FREETYPE
DEFS += '-DMBEDTLS_CONFIG_FILE=<swirl/mbedtls_config_swirl.h>'
DEFS += $(DNS_SIM_DEFS)   # test hook: make DNS_SIM_DEFS="-DDNS_SIM_UDP_DEAD -DDNS_SIM_TCP_DEAD"
DEFS += -DFREE_STANDING

# per-library extra includes (scoped!)
LIBWAP_INCS  = -I$(N)/libwapcaplet/include
LPU_INCS     = -I$(N)/libparserutils/include -I$(N)/libparserutils/src
HUBBUB_INCS  = -I$(N)/libhubbub/include -I$(N)/libhubbub/src -I$(N)/libparserutils/include
LIBCSS_INCS  = -I$(N)/libcss/include -I$(N)/libcss/src -I$(N)/libwapcaplet/include -I$(N)/libparserutils/include
LIBDOM_INCS  = -I$(N)/libdom/include -I$(N)/libdom/src -I$(N)/libdom/src/bindings/hubbub -I$(N)/libwapcaplet/include \
	       -I$(N)/libparserutils/include -I$(N)/libhubbub/include
BMP_INCS     = -I$(N)/libnsbmp/include
GIF_INCS     = -I$(N)/libnsgif/include
NSUTILS_INCS = -I$(N)/libnsutils/include
# upstream generates the bison parser with --name-prefix=filter_ ; the
# checked-in parser still uses yyparse/yylex/yyerror, so rename them to
# the prefixed names the checked-in lexer and filter.c expect
NSLOG_INCS   = -I$(N)/libnslog/include -Dyyparse=filter_parse -Dyylex=filter_lex -Dyyerror=filter_error
UTF8_INCS    = -I$(N)/libutf8proc-2.4.0/include -I$(N)/libutf8proc-2.4.0/include/libutf8proc
NSFB_INCS    = -I$(N)/libnsfb/include -I$(N)/libnsfb/src -I$(NETSURF) -I$(N)/libnslog/include
FT_INCS      = -I$(N)/freetype/include -I$(N)/freetype/src -DFT2_BUILD_LIBRARY -DFT_CONFIG_OPTION_ERROR_STRINGS
ZLIB_INCS    = -I$(N)/zlib
PNG_INCS     = -I$(N)/libpng -I$(N)/zlib
JPG_INCS     = -I$(N)/jpeg
MBED_INCS    = -I$(N)/mbedtls/include -I$(N)
FBFRONT_INCS = -I$(FB) -I$(NETSURF) -I$(N)/libnslog/include -I$(N)/libnsutils/include -I$(N)/libnsfb/include -I$(N)/libwapcaplet/include \
	       -I$(N)/libcss/include -I$(N)/libdom/include -I$(N)/libhubbub/include \
	       -I$(N)/libparserutils/include -I$(N)/freetype/include

# =====================================================================
# source sets
# =====================================================================
LIBWAP_SRC  = $(wildcard $(N)/libwapcaplet/src/*.c)
LPU_SRC     = $(wildcard $(N)/libparserutils/src/*.c) $(wildcard $(N)/libparserutils/src/*/*.c) $(wildcard $(N)/libparserutils/src/*/*/*.c)
HUBBUB_SRC  = $(wildcard $(N)/libhubbub/src/*.c) $(wildcard $(N)/libhubbub/src/*/*.c)
LIBCSS_SRC  = $(wildcard $(N)/libcss/src/*.c) $(wildcard $(N)/libcss/src/*/*.c) $(wildcard $(N)/libcss/src/*/*/*.c)
LIBCSS_SRC := $(filter-out $(N)/libcss/src/parse/properties/css_property_parser_gen.c,$(LIBCSS_SRC))
LIBDOM_SRC  = $(wildcard $(N)/libdom/src/*.c) $(wildcard $(N)/libdom/src/*/*.c)
BMP_SRC     = $(wildcard $(N)/libnsbmp/src/*.c)
GIF_SRC     = $(wildcard $(N)/libnsgif/src/*.c)
NSUTILS_SRC = $(wildcard $(N)/libnsutils/src/*.c)
NSLOG_SRC   = $(wildcard $(N)/libnslog/src/*.c)
UTF8_SRC    = $(N)/libutf8proc-2.4.0/src/utf8proc.c

NSFB_SRC  = $(N)/libnsfb/src/libnsfb.c
# only the 32bpp ARGB8888 plotter path (32bpp-xrgb8888.c pulls in the
# common/generic templates; the other bpp files are templates only)
NSFB_SRC += $(N)/libnsfb/src/plot/api.c $(N)/libnsfb/src/plot/util.c
NSFB_SRC += $(N)/libnsfb/src/plot/generic.c
# exact upstream libnsfb plot/Makefile DIR_SOURCES (1bpp.c/24bpp.c are
# netsurf-frontend adapters, excluded upstream - see src/plot/Makefile)
NSFB_SRC += $(N)/libnsfb/src/plot/32bpp-xrgb8888.c \
	   $(N)/libnsfb/src/plot/32bpp-xbgr8888.c \
	   $(N)/libnsfb/src/plot/16bpp.c $(N)/libnsfb/src/plot/8bpp.c
NSFB_SRC += $(N)/libnsfb/src/surface/surface.c $(N)/libnsfb/src/surface/ram.c
NSFB_SRC += $(N)/libnsfb/src/cursor.c $(N)/libnsfb/src/palette.c $(N)/libnsfb/src/dump.c

# freetype base layer, exactly like upstream's CMakeLists/rule set:
# ftbase.c is a merged single object (advanc/calc/color/dbgmem/errors/
# fntfmt/gloadr/hash/lcdfil/mac/objs/outln/psprop/rfork/snames/stream/
# trigon/util), the rest are standalone. ftsystem.c is excluded - the
# shim provides FT allocations, file access goes through swirl stdio.
FT_BASE_STANDALONE = ftbbox.c ftbdf.c ftbitmap.c ftcid.c ftfstype.c \
                     ftgasp.c ftglyph.c ftgxval.c ftinit.c ftmm.c \
                     ftpatent.c ftpfr.c ftstroke.c ftsynth.c ftsystem.c \
                     fttype1.c ftwinfnt.c ftdebug.c
FT_SRC  = $(N)/freetype/src/base/ftbase.c \
	  $(addprefix $(N)/freetype/src/base/,$(FT_BASE_STANDALONE))
FT_SRC += $(N)/freetype/src/sfnt/sfnt.c
FT_SRC += $(N)/freetype/src/truetype/truetype.c
FT_SRC += $(N)/freetype/src/psaux/psaux.c
FT_SRC += $(N)/freetype/src/psnames/psnames.c
FT_SRC += $(N)/freetype/src/pshinter/pshinter.c
FT_SRC += $(N)/freetype/src/smooth/smooth.c
FT_SRC += $(N)/freetype/src/gzip/ftgzip.c
FT_SRC += $(N)/freetype/src/cache/ftcache.c

ZLIB_SRC = $(N)/zlib/adler32.c $(N)/zlib/crc32.c $(N)/zlib/inflate.c \
	   $(N)/zlib/inffast.c $(N)/zlib/inftrees.c $(N)/zlib/uncompr.c \
	   $(N)/zlib/compress.c $(N)/zlib/zutil.c \
	   $(N)/zlib/gzlib.c $(N)/zlib/gzread.c $(N)/zlib/gzwrite.c \
	   $(N)/zlib/gzclose.c $(N)/zlib/deflate.c $(N)/zlib/trees.c

PNG_SRC = $(wildcard $(N)/libpng/png*.c)

JPG_SRC = $(wildcard $(N)/jpeg/*.c)
JPG_SRC := $(filter-out $(N)/jpeg/jpegtran.c $(N)/jpeg/rdjpgcom.c $(N)/jpeg/ckconfig.c,$(JPG_SRC))

MBED_SRC = $(wildcard $(N)/mbedtls/library/*.c)
MBED_SRC := $(filter-out $(N)/mbedtls/library/psa_%.c,$(MBED_SRC))

NS_SRC  = $(wildcard $(NETSURF)/content/*.c)
NS_SRC += $(wildcard $(NETSURF)/content/fetchers/*.c)
NS_SRC += $(wildcard $(NETSURF)/content/fetchers/about/*.c)
NS_SRC += $(wildcard $(NETSURF)/content/fetchers/file/*.c)
NS_SRC += $(N)/netsurf/content/handlers/javascript/fetcher.c
NS_SRC += $(N)/netsurf/content/handlers/javascript/none/none.c
NS_SRC += $(wildcard $(NETSURF)/content/handlers/*.c)
NS_SRC += $(filter-out %jpegxl.c %webp.c %rsvg2.c %rsvg.c %rsvg246.c %nssprite.c %video.c %svg.c,$(wildcard $(NETSURF)/content/handlers/image/*.c))
NS_SRC += $(wildcard $(NETSURF)/content/handlers/css/*.c)
NS_SRC += $(wildcard $(NETSURF)/content/handlers/html/*.c)
NS_SRC += $(wildcard $(NETSURF)/content/handlers/text/*.c)
NS_SRC += $(wildcard $(NETSURF)/css/*.c)
NS_SRC += $(wildcard $(NETSURF)/utils/*.c)
NS_SRC += $(wildcard $(NETSURF)/utils/http/*.c)
NS_SRC += $(wildcard $(NETSURF)/utils/nsurl/*.c)
NS_SRC += $(wildcard $(NETSURF)/desktop/*.c)

FB_SRC  = $(wildcard $(FB)/*.c)
FB_SRC += $(wildcard $(FB)/fbtk/*.c)
FB_SRC += $(wildcard $(FB)/image_gen/*.c)

SW_SRC  = $(wildcard $(N)/swirl/*.c)
SW_SRC += $(wildcard $(N)/shim/*.c)

# =====================================================================
# rules
# =====================================================================
NSFLIB = $(BUILD)/libswirl_ns.a

define COMPILE
$(BUILD)/$(1).o: $(2)
	@mkdir -p $$(dir $$@)
	$(CC) $(CPUFLAGS) $(WARN) $(DEFS) $(BASE_INCS) $(3) -c $$< -o $$@
endef

# emit rules per group
$(foreach f,$(LIBWAP_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(LIBWAP_INCS))))
$(foreach f,$(LPU_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(LPU_INCS))))
$(foreach f,$(HUBBUB_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(HUBBUB_INCS))))
$(foreach f,$(LIBCSS_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(LIBCSS_INCS))))
$(foreach f,$(LIBDOM_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(LIBDOM_INCS))))
$(foreach f,$(BMP_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(BMP_INCS))))
$(foreach f,$(GIF_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(GIF_INCS))))
$(foreach f,$(NSUTILS_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(NSUTILS_INCS))))
$(foreach f,$(NSLOG_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(NSLOG_INCS))))
$(foreach f,$(UTF8_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(UTF8_INCS))))
$(foreach f,$(NSFB_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(NSFB_INCS))))
$(foreach f,$(FT_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(FT_INCS))))
$(foreach f,$(ZLIB_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(ZLIB_INCS))))
$(foreach f,$(PNG_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(PNG_INCS))))
$(foreach f,$(JPG_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(JPG_INCS))))
$(foreach f,$(MBED_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(MBED_INCS))))
NSFRONT_INCS = -I$(NETSURF) -I$(NETSURF)/content/handlers \
	       -I$(N)/libnslog/include \
	       -I$(N)/libnsbmp/include -I$(N)/libnsgif/include -I$(N)/libnsutils/include \
	       -I$(N)/libwapcaplet/include -I$(N)/libparserutils/include \
	       -I$(N)/libhubbub/include -I$(N)/libcss/include -I$(N)/libdom/include \
	       -I$(N)/libnsutils/include -I$(N)/libnslog/include \
	       -I$(N)/libutf8proc-2.4.0/include -I$(N)/libutf8proc-2.4.0/include/libutf8proc \
	       -I$(N)/freetype/include -I$(N)/mbedtls/include \
	       -I$(N)/jpeg -I$(N)/libpng -I$(N)/zlib
$(foreach f,$(NS_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(NSFRONT_INCS))))
$(foreach f,$(FB_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(FBFRONT_INCS))))
SW_INCS = -I$(N)/../lib -I$(N)/libnslog/include -I$(N)/libnsfb/include -I$(N)/libnsfb/src -I$(N)/mbedtls/include \
	  -I$(NETSURF) -I$(N)/libwapcaplet/include -I$(N)/libparserutils/include \
	  -I$(N)/libcss/include -I$(N)/libdom/include -I$(N)/libhubbub/include \
	  -I$(N)/libnsutils/include -I$(N)/libnslog/include -I$(N)/libutf8proc-2.4.0/include \
	  -I$(N)/freetype/include
$(foreach f,$(SW_SRC),$(eval $(call COMPILE,$(patsubst $(N)/%.c,%,$(f)),$(f),$(SW_INCS))))

NSOBJS  = $(patsubst $(N)/%.c,$(BUILD)/%.o,$(filter %.c,$(LIBWAP_SRC) $(LPU_SRC) $(HUBBUB_SRC) $(LIBCSS_SRC) $(LIBDOM_SRC) $(BMP_SRC) $(GIF_SRC) $(NSUTILS_SRC) $(NSLOG_SRC) $(UTF8_SRC) $(NSFB_SRC) $(FT_SRC) $(ZLIB_SRC) $(PNG_SRC) $(JPG_SRC) $(MBED_SRC) $(NS_SRC) $(FB_SRC) $(SW_SRC)))


$(NSFLIB): $(N)/../lib/sys.c $(N)/shim/crt0_ns.S $(N)/shim/swirl_setjmp.S
	@mkdir -p $(BUILD)/lib $(BUILD)/shim
	$(CC) $(CPUFLAGS) $(WARN) $(DEFS) $(BASE_INCS) -c $(N)/../lib/sys.c -o $(BUILD)/lib/sys.o
	$(CC) -g -c $(N)/shim/swirl_setjmp.S -o $(BUILD)/shim/swirl_setjmp.o
	$(CC) -g -c $(N)/shim/crt0_ns.S -o $(BUILD)/lib/crt0_ns.o
	$(AR) rcs $@ $(BUILD)/lib/sys.o $(BUILD)/lib/crt0_ns.o $(BUILD)/shim/swirl_setjmp.o

$(BUILD)/netsurf.elf: $(NSOBJS) $(NSFLIB) $(N)/netsurf.ld
	$(LD) -T $(N)/netsurf.ld --gc-sections --build-id=none -o $@ $(NSOBJS) $(NSFLIB)
	@echo "netsurf: $@"

all: $(BUILD)/netsurf.elf

clean:
	rm -rf $(BUILD)

.PHONY: all clean
-include $(shell find $(BUILD) -name '*.d' 2>/dev/null)
