include(ExternalProject)
include(GNUInstallDirs)

if(NOT EVMC_ROOT)
        ExternalProject_Add(evmc
                PREFIX ${CMAKE_SOURCE_DIR}/deps
                DOWNLOAD_NO_PROGRESS 1
                DOWNLOAD_NAME evmc-31a0f283.tar.gz
                URL https://github.com/FISCO-BCOS/evmc/archive/31a0f2837ba00879f0e2a506828760bfbbdbd1c8.tar.gz
                URL_HASH SHA256=5029c94de03d2c1b69da93f7d993db71e353e547c0a81b4ef31fe0d348b1b596
                # GIT_REPOSITORY https://github.com/FISCO-BCOS/evmc.git
                # GIT_TAG 31a0f2837ba00879f0e2a506828760bfbbdbd1c8
                CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
                BUILD_IN_SOURCE 1
                LOG_CONFIGURE 1
                LOG_BUILD 1
                LOG_INSTALL 1
                BUILD_BYPRODUCTS <INSTALL_DIR>/lib/libevmc-instructions.a <INSTALL_DIR>/lib/libevmc-loader.a
        )

        ExternalProject_Get_Property(evmc INSTALL_DIR)

        set(EVMC_INCLUDE_DIRS ${INSTALL_DIR}/include)
        file(MAKE_DIRECTORY ${EVMC_INCLUDE_DIRS})  # Must exist.
        set(EVMC_LOADER_LIBRARIES ${INSTALL_DIR}/lib/libevmc-loader.a)
        set(EVMC_INSTRUCTIONS_LIBRARIES ${INSTALL_DIR}/lib/libevmc-instructions.a)
else()
        set(EVMC_INCLUDE_DIRS ${EVMC_ROOT}/include)
        set(EVMC_LOADER_LIBRARIES ${EVMC_ROOT}/lib/libevmc-loader.a)
        set(EVMC_INSTRUCTIONS_LIBRARIES ${EVMC_ROOT}/lib/libevmc-instructions.a)
endif()

add_library(EVMC::Loader STATIC IMPORTED)
set_property(TARGET EVMC::Loader PROPERTY IMPORTED_LOCATION ${EVMC_LOADER_LIBRARIES})
set_property(TARGET EVMC::Loader PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${EVMC_INCLUDE_DIRS})

add_library(EVMC::Instructions STATIC IMPORTED)
set_property(TARGET EVMC::Instructions PROPERTY IMPORTED_LOCATION ${EVMC_INSTRUCTIONS_LIBRARIES})
set_property(TARGET EVMC::Instructions PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${EVMC_INCLUDE_DIRS})

add_library(EVMC INTERFACE IMPORTED)
set_property(TARGET EVMC PROPERTY INTERFACE_LINK_LIBRARIES ${EVMC_INSTRUCTIONS_LIBRARIES} ${EVMC_LOADER_LIBRARIES})
set_property(TARGET EVMC PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${EVMC_INCLUDE_DIRS})
add_dependencies(EVMC evmc)
