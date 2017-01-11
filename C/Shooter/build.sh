#!/bin/bash

set -e

SDL_LIB="$(sdl2-config --libs) -lSDL2_ttf -lSDL2_gpu -framework OpenGL"
SDL_CFLAGS="$(sdl2-config --cflags)"
WARNINGS="-Wall -Wno-missing-braces -Wno-narrowing -Wno-unused-function"

# Build the shared library
clang++ -std=c++11 src/*.cpp $WARNINGS $SDL_CFLAGS -o main -std=c++11 $SDL_LIB $OTHERLINKS
