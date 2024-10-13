# uibase is prebuilt and is always dynamic, but MO2 uses a static triplets (for Boost,
# lz4, etc.) so we disable that warning
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

# TODO: add a copyright file to uibase and install it
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ModOrganizer2/modorganizer-uibase/releases/download/v${VERSION}/uibase_v${VERSION}.7z"
    FILENAME "uibase_${VERSION}.7z"
    SHA512 6FF2B41C1AA38F303CA0AB88A19BA767E578FEC4E81758A7B840BB8C2E3AE1E5582530043060D6D12579B96BEE29F46E89B78D176C4B023BE21FBFC157192C68
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

file(INSTALL
    ${SOURCE_PATH}/bin/uibase.dll
    ${SOURCE_PATH}/pdb/uibase.pdb
DESTINATION
    ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${SOURCE_PATH}/lib/uibase.lib
    ${SOURCE_PATH}/lib/cmake
DESTINATION
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/bin/uibased.dll
    ${SOURCE_PATH}/pdb/uibased.pdb
DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL
    ${SOURCE_PATH}/lib/uibased.lib
    ${SOURCE_PATH}/lib/cmake
DESTINATION
    ${CURRENT_PACKAGES_DIR}/debug/lib
)

vcpkg_cmake_config_fixup(PACKAGE_NAME "mo2-uibase" CONFIG_PATH "lib/cmake/mo2-uibase")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
