#!/bin/bash

set -e

SDL_LIB="$(sdl2-config --libs) -lSDL2_image -lSDL2_ttf -lSDL2_gpu -framework OpenGL"
SDL_CFLAGS="$(sdl2-config --cflags)"
WARNINGS="-Wall -Wno-missing-braces -Wno-write-strings -Wno-narrowing -Wno-unused-function"

OTHERLINKS="-lm"

# Build the shared library
clang src/*.cpp $WARNINGS $SDL_CFLAGS -dynamiclib -o libStarJumper.dylib -std=c++11 $SDL_LIB $OTHERLINKS

# Build the executable
clang -o main src/dynamic/*.c
