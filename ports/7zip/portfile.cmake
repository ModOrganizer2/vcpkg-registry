set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ip7z/7zip
    REF "${VERSION}"
    SHA512 9ce8acdbbb44045c5c9983db1093b6abc78439ee2b0ba57820a44a08d0787cb5ab34e25fd3ff33a93f274cc006684ce6013d4e98b47e7834318898e9d10d2259
    HEAD_REF main
)

vcpkg_download_distfile(
    CMAKEFILE_PATH
    URLS https://raw.githubusercontent.com/microsoft/vcpkg/a193e8fb4e45d82398e579bb439e58045c6d24b9/ports/7zip/CMakeLists.txt
    FILENAME CMakeLists.txt
    SHA512 0D19364E52CE437DA3559F5A1FEA1242F51B3954954DCA6B56C31871D043E9D48FBCBD2D4D8302DCBEF4A326ED11BCB9C98E4BD520C157ADBA09564CC26E0F1B
)

file(COPY "${CMAKEFILE_PATH}" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/DOC/License.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
