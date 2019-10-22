#add defines to CFLAGS based on os and architecture, set $(OS) to WINDOWS/LINUX/OSX

ifeq ($(OS),Windows_NT)
CFLAGS += -D WIN32
OS := WINDOWS
ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
CFLAGS += -D AMD64
else
ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
CFLAGS += -D AMD64
endif
ifeq ($(PROCESSOR_ARCHITECTURE),x86)
CFLAGS += -D IA32
endif
endif
else
UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
OS := LINUX
CFLAGS += -D LINUX
endif
ifeq ($(UNAME),Darwin)
OS := OSX
CFLAGS += -D OSX
endif
UNAME_P := $(shell uname -p)
ifeq ($(UNAME_P),x86_64)
CFLAGS += -D AMD64
endif
ifneq ($(filter %86,$(UNAME_P)),)
CFLAGS += -D IA32
endif
ifneq ($(filter arm%,$(UNAME_P)),)
CFLAGS += -D ARM
endif
endif
