ARG_TEST +=
OBJ_DIR := .obj
TEST_SRCS := test.c
CFLAGS += -Iinc
LD := gcc
PRE_TEST :=
BLACK_LIST_DIR += cmake-build-debug/
