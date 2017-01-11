
#include "inputManager.h"
#include "gb.h"
#include <SDL.h>

void setInputState(ButtonState* newState, b32 isDown) {
    if (newState->endedDown != isDown) {
        newState->endedDown = isDown;
        newState->halfTransitionCount += 1;
    }
}

// TODO(vdka): Read key configuration form file, also support for controllers
void readInput(PlayerInput* input, b32* shouldQuit) {

    input->wasEvent = false;
    SDL_Event e;
    while (SDL_PollEvent(&e)) {

        if (e.type == SDL_QUIT) {
            *shouldQuit = true;
            return;
        }

        input->wasEvent = true;

        SDL_Keycode key = e.key.keysym.sym;

        b32 isDown = e.key.type == SDL_KEYDOWN;

        // Process keyboard input
        if (key == SDLK_w) setInputState(&input->moveUp, isDown);
        if (key == SDLK_s) setInputState(&input->moveDown, isDown);
        if (key == SDLK_a) setInputState(&input->moveLeft, isDown);
        if (key == SDLK_d) setInputState(&input->moveRight, isDown);
        if (key == SDLK_q) setInputState(&input->switchLeft, isDown);
        if (key == SDLK_e) setInputState(&input->switchRight, isDown);
        if (key == SDLK_r) setInputState(&input->reload, isDown);
        if (key == SDLK_t) setInputState(&input->chat, isDown);
        if (key == SDLK_LSHIFT) setInputState(&input->sprint, isDown);
        //        if (key == SDLK_ESCAPE) input->shouldQuit = true; // TODO(vdka): Go to menu

        // Process Mouse input
        if (e.button.button == 1)
            setInputState(&input->shoot, e.button.type == SDL_MOUSEBUTTONDOWN);
        if (e.button.button == 3) setInputState(&input->aim, e.button.type == SDL_MOUSEBUTTONDOWN);
    }
    SDL_GetMouseState(&input->mouseX, &input->mouseY);
}
