package fenrir

import "core:fmt"
import "core:log"
import Vulkan "vendor:vulkan"
import SDL "vendor:sdl3"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

Engine :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,
}
 
run :: proc(engine: ^Engine) {
    init_vulkan()
    init_window(engine)
    main_loop(engine)
    cleanup()
}

init_vulkan :: proc() {

}

init_window :: proc(engine: ^Engine) -> bool {
    engine.window = SDL.CreateWindow("Fenrir Game Engine", SCREEN_WIDTH, SCREEN_HEIGHT, {})
    if engine.window == nil {
        log.error("Failed to create window:", SDL.GetError())
        return false
    }

    return true
}

main_loop :: proc(engine: ^Engine) {
    for {
        for SDL.PollEvent(&engine.event) {
            #partial switch engine.event.type {
                case .QUIT:
                    return
            }
        }

        SDL.SetRenderDrawColor(engine.renderer, 0, 0, 0, 255)
        SDL.RenderClear(engine.renderer)

        SDL.RenderPresent(engine.renderer)
        SDL.Delay(16)
    }
}

cleanup :: proc() {

}

main :: proc() {
    fmt.printf("hello world")
    engine: Engine

    run(&engine)
}