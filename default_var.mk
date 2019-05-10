UNAME := $(shell uname)
MAKEFILES_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
TEST_ARG +=
OBJ_DIR := .obj
DEP_DIR := .dep
TEST_SRCS := ./test.c
LD := gcc
PRE_TEST :=
BLACK_LIST_SRCS += cmake-build-debug/

ifeq ($(UNAME), Darwin)

PACKAGE_MANAGER_DIR = $(HOME)/.brew
PACKAGE_MANAGER = $(HOME)/.brew/bin/brew
PACKAGE_MANAGER_BIN = $(HOME)/.brew/bin
PACKAGE_MANAGER_LIB = $(HOME)/.brew/lib
PACKAGE_MANAGER_INC = $(HOME)/.brew/include
PACKAGE_MANAGER_INSTALL_ARGUMENT = install

SDL2_NAME = SDL2
SDL2_TTF_NAME = SDL2_ttf
SDL2_MIXER_NAME = SDL2_mixer
SDL2_IMAGE_NAME = SDL2_image

CMAKE = $(PACKAGE_MANAGER_BIN)/cmake

$(PACKAGE_MANAGER):
	git clone --depth=1 https://github.com/Homebrew/brew $(PACKAGE_MANAGER_DIR) && echo 'export PATH=$(PACKAGE_MANAGER_BIN):$(PATH)' >> $(HOME)/.zshrc && source $(HOME)/.zshrc && brew update

$(CMAKE):
	$(PACKAGE_MANAGER) install cmake

else ifeq ($(UNAME), Linux)
#If Linux and pacman is installed
ifneq ($(shell which pacman), )

PACKAGE_MANAGER = sudo $(shell which pacman)
PACKAGE_MANAGER_BIN = /usr/bin
PACKAGE_MANAGER_LIB = /usr/lib
PACKAGE_MANAGER_INC = /usr/include
PACKAGE_MANAGER_INSTALL_ARGUMENT = -S --needed

SDL2_NAME = sdl2
SDL2_TTF_NAME = sdl2_ttf
SDL2_MIXER_NAME = sdl2_mixer
SDL2_IMAGE_NAME = sdl2_image
SDL2_NET_NAME = sdl2_net

else ifneq ($(shell which apt-get), )

PACKAGE_MANAGER = sudo $(shell which apt-get)
PACKAGE_MANAGER_BIN = /usr/bin
PACKAGE_MANAGER_LIB = /usr/lib/x86_64-linux-gnu
PACKAGE_MANAGER_INC = /usr/include
PACKAGE_MANAGER_INSTALL_ARGUMENT = install

SDL2_NAME = libsdl2-dev
SDL2_TTF_NAME = libsdl2-ttf-dev
SDL2_MIXER_NAME = libsdl2-mixer-dev
SDL2_IMAGE_NAME = libsdl2-image-dev
SDL2_NET_NAME = libsdl2-net-dev

endif

else

$(warning "non darwin system aren't supported for now unless they have pacman installed")

endif

INC_DIR += inc $(PACKAGE_MANAGER_INC)
