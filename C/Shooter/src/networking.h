
#ifndef networking_h
#define networking_h

#include "common.h"
#include <SDL.h>
#include <SDL_net.h>

inline UDPsocket openBroadcastPort(u16 port) {

    UDPsocket socket = SDLNet_UDP_Open(port);

    return socket;
}

#endif /* networking_h */
