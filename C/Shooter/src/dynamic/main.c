
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#define fn(name, ret, args) ret(name)(args)

typedef fn(GameInit, void*, void*);
typedef fn(GameLoad, void, void*);
typedef fn(GameLoop, int, void*);

typedef struct GameCode {
    void*  code;
    time_t lastWriteTime;

    GameInit* init;
    GameLoad* load;
    GameLoop* loop;
} GameCode;

time_t lastWriteTime(char const* path) {

    struct stat stats = {0};
    if (stat(path, &stats) != 0) return 0;

    return stats.st_mtimespec.tv_sec;
}

void loadGameCode(GameCode* game, char const* path) {

    game->code = dlopen(path, RTLD_LAZY | RTLD_GLOBAL | RTLD_NODELETE);

    if (game->code == NULL) {
        printf("Failed to load dl: %s\n", dlerror());
        return;
    }
    game->init = (GameInit*) dlsym(game->code, "init");
    game->load = (GameLoad*) dlsym(game->code, "load");
    game->loop = (GameLoop*) dlsym(game->code, "loop");

    game->lastWriteTime = lastWriteTime(path);
}

void unloadGameCode(GameCode* game) {

    dlclose(game->code);
    game->code = NULL;
    game->init = NULL;
    game->load = NULL;
    game->loop = NULL;
}

int main(int argc, char** argv) {

    GameCode    game;
    char const* gameCodePath = "libStarJumper.dylib";
    loadGameCode(&game, gameCodePath);

    if (!game.init) {
        printf("Failed to find 'launch' symbol\n");
        return 1;
    }

    void* memory = NULL;

    memory = game.init(memory);
    if (memory == NULL) {
        printf("Init call indicated failure\n");
        exit(1);
    }

    if (!game.load) {
        printf("Failed to find 'load' symbol\n");
        return 1;
    }

    game.load(memory);

    int shouldQuit = 0;
    while (!shouldQuit) {

        time_t newWriteTime = lastWriteTime(gameCodePath);
        if (newWriteTime != game.lastWriteTime) {
            printf("Code change detected. Reloading.\n");
            unloadGameCode(&game);
            usleep(2500);
            loadGameCode(&game, gameCodePath);
            usleep(100);
            if (game.load) game.load(memory);
        }

        if (game.loop) shouldQuit = game.loop(memory);
    }

    printf("Terminating.\n");
    return 0;
}
