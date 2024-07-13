vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ModOrganizer2/modorganizer-lootcli
    REF 01cf866ab59c1f3faf7f2b7406819d1eec69e70d
    SHA512 D1D4012C6106827D1BF423A27812CDDB8833426932B9F859C2E61A0A6AF643729D90B02F39D415E60F7CC6D56F0E7918E219440547FD63F9A95DB49031BAF619
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "mo2-lootcli-header" CONFIG_PATH "lib/cmake/mo2-lootcli-header")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
