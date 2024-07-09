vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF "v${VERSION}"
    SHA512 d8f36a3d65a43d8c64900e46137827aadb05559948b2f5a389bea16ed1bfac07d113ee11cf47970913298d6c37400355fe6895cda8fa6dcf6abd9da0d8f199e9
    HEAD_REF v1.x
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPDLOG_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPDLOG_FMT_EXTERNAL=OFF
        -DSPDLOG_USE_STD_FORMAT=ON
        -DSPDLOG_INSTALL=ON
        -DSPDLOG_BUILD_SHARED=${SPDLOG_BUILD_SHARED}
        -DSPDLOG_WCHAR_FILENAMES=OFF
        -DSPDLOG_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/spdlog)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# add support for integration other than cmake
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
    "// #define SPDLOG_USE_STD_FORMAT"
    "#ifndef SPDLOG_USE_STD_FORMAT\n#define SPDLOG_USE_STD_FORMAT\n#endif"
)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
    "// #define SPDLOG_WCHAR_TO_UTF8_SUPPORT"
    "#ifndef SPDLOG_WCHAR_TO_UTF8_SUPPORT\n#define SPDLOG_WCHAR_TO_UTF8_SUPPORT\n#endif"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
