
#include <SDL.h>
#include "common.h"
#include "game.h"

int main() {

    void* memory;
    setup(&memory);

    GameState* gameState = (GameState*) memory;

    if (*gameState == GameState_Uninitialized)
        return 1;

    while (true) {

        loop(memory);

        if (*gameState == GameState_Quiting)
            return 0;
    }

    return 0;
}
