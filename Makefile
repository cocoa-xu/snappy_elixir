PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_SO = $(PRIV_DIR)/nif.so
C_SRC = $(shell pwd)/c_src
ifdef CMAKE_TOOLCHAIN_FILE
	CMAKE_CONFIGURE_FLAGS=-D CMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)"
endif

# snappy
SNAPPY_USE_GIT_HEAD ?= false
SNAPPY_GIT_REPO ?= "https://github.com/google/snappy.git"
SNAPPY_VER ?= 1.1.9
ifneq ($(SNAPPY_USE_GIT_HEAD), false)
	SNAPPY_VER=$(SNAPPY_USE_GIT_BRANCH)
endif
SNAPPY_CACHE_DIR = $(shell pwd)/3rd_party/cache
SNAPPY_SOURCE_ZIP = $(SNAPPY_CACHE_DIR)/snappy-$(SNAPPY_VER).zip
SNAPPY_ROOT_DIR = $(shell pwd)/3rd_party/snappy
SNAPPY_DIR = $(SNAPPY_ROOT_DIR)/snappy-$(SNAPPY_VER)
CMAKE_SNAPPY_BUILD_DIR = $(MIX_APP_PATH)/cmake_snappy_$(SNAPPY_VER)
CMAKE_SNAPPY_OPTIONS ?= ""

.DEFAULT_GLOBAL := build

build: $(NIF_SO)

$(NIF_SO):
	@ mkdir -p $(PRIV_DIR)
	@ mkdir -p $(CMAKE_SNAPPY_BUILD_DIR)
	@ cd "$(CMAKE_SNAPPY_BUILD_DIR)" && \
		{ cmake -D SNAPPY_DIR="$(SNAPPY_DIR)" \
			-D C_SRC="$(C_SRC)" \
	  		-D PRIV_DIR="$(PRIV_DIR)" \
	  		-D ERTS_INCLUDE_DIR="$(ERTS_INCLUDE_DIR)" \
	  		-D SNAPPY_PREFER_PRECOMPILED="$(SNAPPY_PREFER_PRECOMPILED)" \
	  		-D SNAPPY_PRECOMPILED_VERSION="$(SNAPPY_PRECOMPILED_VERSION)" \
	  		-D SNAPPY_PRECOMPILED_CACHE_DIR="$(SNAPPY_PRECOMPILED_CACHE_DIR)" \
	  		-D SNAPPY_BUILD_TESTS=OFF \
	  		-D SNAPPY_BUILD_BENCHMARKS=OFF \
	  		$(CMAKE_CONFIGURE_FLAGS) \
	  		$(CMAKE_SNAPPY_OPTIONS) \
	  		"$(shell pwd)" && \
	  	 make "$(MAKE_BUILD_FLAGS)" \
	  	 || { echo "\033[0;31mincomplete build of snappy found in '$(CMAKE_SNAPPY_BUILD_DIR)', please delete that directory and retry\033[0m" && exit 1 ; } ; } \
	&& if [ "$(SNAPPY_PREFER_PRECOMPILED)" != "true" ]; then \
		cp "$(CMAKE_SNAPPY_BUILD_DIR)/nif.so" "$(NIF_SO)" ; \
	fi
