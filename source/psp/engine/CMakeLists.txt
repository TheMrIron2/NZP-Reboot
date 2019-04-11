#CMake File for NZ:P Reboot


cmake_minimum_required(VERSION 3.7)
set(CMAKE_CXX_STANDARD 14)
project (NZPReboot)

       #Default Files for build
       set (PSP_COMMON psp/battery.cpp psp/cd.cpp psp/clipping.cpp psp/fnmatch.cpp psp/gethost.cpp psp/input.cpp psp/math.cpp psp/module.cpp psp/mp3.c psp/Random.cpp psp/sound.cpp psp/system.cpp)
       set (PSP_NETWORK psp/network_infrastructure.cpp psp/network_psp.cpp psp/network.cpp)
       set (PSP_MAIN psp/main.cpp)
       set (PSP_VIDEO psp/wad3.cpp psp/clipping.cpp psp/vram.cpp psp/video_hardware.cpp psp/video_hardware_decals_QMB.cpp psp/video_hardware_draw.cpp psp/video_hardware_dxtn.cpp psp/video_hardware_entity_fragment.cpp)
       set (PSP_VIDEO2 psp/video_hardware_fog.cpp psp/video_hardware_fullbright.cpp psp/video_hardware_hlmdl.cpp psp/video_hardware_images.cpp psp/video_hardware_light.cpp psp/video_hardware_main.cpp psp/video_hardware_mesh.cpp)
       set (PSP_VIDEO3 psp/video_hardware_mhex2.cpp psp/video_hardware_misc.cpp psp/video_hardware_model.cpp psp/video_hardware_part.cpp psp/video_hardware_QMB.cpp psp/video_hardware_resample.cpp psp/video_hardware_screen.cpp psp/video_hardware_surface.cpp psp/video_hardware_warp.cpp)

       set (PSP_FILES ${PSP_COMMON} ${PSP_NETWORK} ${PSP_VIDEO} ${PSP_VIDEO2} ${PSP_VIDEO2} ${PSP_VIDEO3} ${PSP_MAIN})

       	add_definitions("-DNDEBUG  -march=allegrex -O2 -msingle-float -mfix-r4000")
       	add_compile_options(-DPSP_LARGE_MEMORY=1 -DPSP_FW_VERSION=661)

       	include_directories(${PROJECT_SOURCE_DIR}/Config/Release)
       	add_library(pspkubridge STATIC IMPORTED)
       set_property(TARGET pspkubridge PROPERTY IMPORTED_LOCATION ${PROJECT_SOURCE_DIR}/psp/m33libs/libpspkubridge.a)
       	add_executable(nzp.elf ${PSP_FILES})
       	set_target_properties(nzp.elf PROPERTIES LINK_FLAGS "-specs=${PSPSDK}/lib/prxspecs -Wl,-q,-T${PSPSDK}/lib/linkfile.prx ${PSPSDK}/lib/prxexports.o -L${PSPSDK}/lib")
       	target_include_directories(nzp.elf PUBLIC /usr/local/pspdev/psp/sdk/include )
       	target_link_libraries(nzp.elf -lstdc++ -lpsppower -lpspgu -lpspaudiolib -lpspaudio -lpsprtc -lpng -lz -lc -lg -lm -lpspfpu pspkubridge ${PSPSDK_LIBS})
