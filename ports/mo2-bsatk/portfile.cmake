vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ModOrganizer2/modorganizer-bsatk
    REF "${VERSION}"
    SHA512 70FD9335D896AC9DE843E6DC031277AD7D35FD3334BBD5C877BEDEBCAA0FEACE12B284D68CB20E574B78262EDFEF84701368C20C5FA84EF0E15277EC202AF25D
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME "mo2-bsatk" CONFIG_PATH "lib/cmake/mo2-bsatk")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
