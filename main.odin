package fenrir

import "core:fmt"
import "core:log"
import "core:strings"
import Vulkan "vendor:vulkan"
import SDL "vendor:sdl3"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

VALIDATION_LAYERS := []cstring{"VK_LAYER_KHRONOS_validation"}

when ODIN_DEBUG {
    ENABLE_VALIDATION_LAYERS :: true
} else {
    ENABLE_VALIDATION_LAYERS :: false
}

Engine :: struct {
    window: ^SDL.Window,
    event: SDL.Event,
    instance: Vulkan.Instance,
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
        log.error("Failed to init SDL:\n", SDL.GetError())
    }

    engine.window = SDL.CreateWindow("Fenrir Game Engine", SCREEN_WIDTH, SCREEN_HEIGHT, {.VULKAN})
    if engine.window == nil {
        log.error("Failed to create window:\n", SDL.GetError())
    }
}

create_instance :: proc(engine: ^Engine) {
    if ENABLE_VALIDATION_LAYERS && !check_validation_layer_support() {
        log.error("Validation layers requested, but not available!\n")
    }

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

    if ENABLE_VALIDATION_LAYERS {
        create_info.enabledLayerCount = u32(len(VALIDATION_LAYERS))
        create_info.ppEnabledLayerNames = raw_data(VALIDATION_LAYERS)
    } else {
        create_info.enabledLayerCount = 0
    }

    result := Vulkan.CreateInstance(&create_info, nil, &engine.instance)
    if result != .SUCCESS {
        log.error("Failed to create instance!\n", SDL.GetError())
    } else {
        fmt.printf("Success!\n")
    }
}

check_validation_layer_support :: proc() -> bool {
    layer_count: u32
    Vulkan.EnumerateInstanceLayerProperties(&layer_count, nil)

    available_layers := make([]Vulkan.LayerProperties, layer_count)
    defer delete(available_layers)
    Vulkan.EnumerateInstanceLayerProperties(&layer_count, raw_data(available_layers))

    for layer_name in VALIDATION_LAYERS {
        layer_found: bool
        
        for &layer_properties in available_layers {
            if layer_name == cstring(&layer_properties.layerName[0]) {
                layer_found = true
                break
            }
        }

        if !layer_found {
            return false
        }
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

        SDL.Delay(16)
    }
}

cleanup :: proc(engine: ^Engine) {
    Vulkan.DestroyInstance(engine.instance, nil)
    SDL.DestroyWindow(engine.window)
    SDL.Quit()
}

main :: proc() {
    fmt.printf("hello world\n")
    engine: Engine

    run(&engine)
}