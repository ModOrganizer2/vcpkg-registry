vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ModOrganizer2/modorganizer-esptk
    REF 227B67FA49A5A9A264CD52901E1A56347BBE90C6
    SHA512 8F635BF9CA940E07040C2C3A3A75666C4B12ACFE3D3B586ADD05FE8D548A18CF9B6224587303B1FC5709BA2FAE9F92EE74AAEFD2D5FD57F8BD567525BD787F2B
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "mo2-esptk" CONFIG_PATH "lib/cmake/mo2-esptk")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
