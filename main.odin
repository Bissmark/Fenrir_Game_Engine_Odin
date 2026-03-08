package fenrir

import "core:fmt"
import "core:log"
import Vulkan "vendor:vulkan"
import SDL "vendor:sdl3"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

Engine :: struct {
    window: ^SDL.Window,
    event: SDL.Event,
    instance: Vulkan.Instance,
    // appInfo: Vulkan.ApplicationInfo,
}
 
run :: proc(engine: ^Engine) {
    init_window(engine)
    init_vulkan(engine)
    main_loop(engine)
    cleanup(engine)
}

init_vulkan :: proc(engine: ^Engine) {
    create_instance(engine)
}

init_window :: proc(engine: ^Engine) {
    if !SDL.Init({.VIDEO}) {
        log.error("Failed to init SDL:", SDL.GetError())
    }

    engine.window = SDL.CreateWindow("Fenrir Game Engine", SCREEN_WIDTH, SCREEN_HEIGHT, {.VULKAN})
    if engine.window == nil {
        log.error("Failed to create window:", SDL.GetError())
    }
}

create_instance :: proc(engine: ^Engine) {
    Vulkan.load_proc_addresses_global(cast(rawptr)SDL.Vulkan_GetVkGetInstanceProcAddr())

    app_info := Vulkan.ApplicationInfo {
        sType = .APPLICATION_INFO,
        pApplicationName = "Engine",
        applicationVersion = Vulkan.MAKE_VERSION(1, 0, 0),
        pEngineName = "Fenrir",
        engineVersion = Vulkan.MAKE_VERSION(1, 0, 0),
        apiVersion = Vulkan.API_VERSION_1_0,
    }

    ext_count: u32
    extensions := SDL.Vulkan_GetInstanceExtensions(&ext_count)

    create_info := Vulkan.InstanceCreateInfo {
        sType = .INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        enabledExtensionCount = ext_count,
        ppEnabledExtensionNames = extensions,
        enabledLayerCount = 0,
    }

    result := Vulkan.CreateInstance(&create_info, nil, &engine.instance)
    if result != .SUCCESS {
        log.error("Failed to create instance!", SDL.GetError())
    } else {
        fmt.printf("Success!")
    }
}

main_loop :: proc(engine: ^Engine) {
    for {
        for SDL.PollEvent(&engine.event) {
            #partial switch engine.event.type {
                case .QUIT:
                    return
            }
        }

        SDL.Delay(16)
    }
}

cleanup :: proc(engine: ^Engine) {
    SDL.DestroyWindow(engine.window)
    SDL.Quit()
}

main :: proc() {
    fmt.printf("hello world\n")
    engine: Engine

    run(&engine)
}