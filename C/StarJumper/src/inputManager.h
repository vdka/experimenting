
#ifndef inputManager_H
#define inputManager_H

#include "gb.h"

#define MAX_CONTROLLER_COUNT 1

struct ButtonState {

    i32 halfTransitionCount;
    b32 endedDown;
};

#define BUTTON_COUNT 14

struct Entity;
struct PlayerInput {

    b32 isConnected;
    b32 isAnalog;
    b32 wasEvent;
    f32 stickAverageX;
    f32 stickAverageY;
    i32 mouseX, mouseY;

    Entity* target;

    union {
        ButtonState buttons[BUTTON_COUNT - 1];

        struct {
            ButtonState shoot;    // <rmb>
            ButtonState aim;      // <lmb>
            ButtonState interact; // <space>
            ButtonState sprint;   // <lshift>

            ButtonState moveUp;    // 'w'
            ButtonState moveDown;  // 's'
            ButtonState moveLeft;  // 'a'
            ButtonState moveRight; // 'd'

            ButtonState switchLeft;  // 'q'
            ButtonState switchRight; // 'e'
            ButtonState reload;      // 'r'

            ButtonState chat; // 't'
            ButtonState menu; // <esc>

            // NOTE: Additions go above this line.
            ButtonState Terminator;
        };
    };
};

inline b32 wasPressed(ButtonState state) {

    b32 result = ((state.halfTransitionCount > 1) ||
                  ((state.halfTransitionCount == 1) && (state.endedDown)));
    return result;
}

inline b32 isDown(ButtonState state) {

    b32 result = state.endedDown;
    return result;
}

void readInput(PlayerInput* input, b32* shouldQuit);

#endif
