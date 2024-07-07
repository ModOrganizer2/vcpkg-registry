vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ModOrganizer2/libbsarch/releases/download/${VERSION}/libbsarch-${VERSION}-release-x64.7z"
    FILENAME "libbsarch-${VERSION}-release-x64.7z"
    SHA512 d7b523c37080f2cb6de993419431c1658fe3e51dabd5ad3d60a9b1dc651534f606d1d312e4c51c53fb41fb9bc33e2660cd72f3e2d4558bb7598ae7280b2e3fc1
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL
    ${SOURCE_PATH}/utils
    ${SOURCE_PATH}/base_types.hpp
    ${SOURCE_PATH}/base_types.hpp
    ${SOURCE_PATH}/bs_archive_auto.hpp
    ${SOURCE_PATH}/bs_archive_entries.h
    ${SOURCE_PATH}/bs_archive.h
    ${SOURCE_PATH}/libbsarch.h
    ${SOURCE_PATH}/libbsarch.hpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/libbsarch.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL
    ${SOURCE_PATH}/libbsarch.lib
    ${SOURCE_PATH}/libbsarch.pdb
    ${SOURCE_PATH}/libbsarch_OOP.lib
    ${SOURCE_PATH}/libbsarch_OOP.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ModOrganizer2/libbsarch/releases/download/${VERSION}/libbsarch-${VERSION}-debug-x64.7z"
    FILENAME "libbsarch-${VERSION}-release-x64.7z"
    SHA512 B3FFAD6DC84FDB9C707C62C83EC91E9DB008BB6FD03DDAA0B5C3DD9BD5E5F13DF39B6A6529D04461114313B9CA9B2A5428E16F000E71243EF2922123B3582402
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH_DEBUG
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/libbsarch.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL
    ${SOURCE_PATH}/libbsarch.lib
    ${SOURCE_PATH}/libbsarch.pdb
    ${SOURCE_PATH}/libbsarch_OOP.lib
    ${SOURCE_PATH}/libbsarch_OOP.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

# dds.h is not part of DirectXTex
vcpkg_download_distfile(ARCHIVE
    URLS "https://raw.githubusercontent.com/microsoft/DirectXTex/e102d0bd3e1a9e59e9aa7276b3ff27c484b783b6/DirectXTex/DDS.h"
    FILENAME "DDS.h"
    SHA512 49ED2C454A39D59EBAE06F2E96E814246754C83ECE074E052A8872F7E16FA7C9E00FEC3B1F1757E09AE9FC1D7C7AFCF7C845D377A3E8EC876E7F7D5CEDB1487A
)
file(INSTALL ${ARCHIVE} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/libbsarchConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbsarch)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CURRENT_PACKAGES_DIR}/share/libbsarch/libbsarchConfigVersion.cmake"
  VERSION "${VERSION}"
  COMPATIBILITY AnyNewerVersion
)
