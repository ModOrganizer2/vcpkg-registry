# uibase is prebuilt and is always dynamic, but MO2 uses a static triplets (for Boost,
# lz4, etc.) so we disable that warning
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

# TODO: add a copyright file to uibase and install it
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ModOrganizer2/modorganizer-uibase/releases/download/v${VERSION}/uibase_v${VERSION}.7z"
    FILENAME "uibase_${VERSION}.7z"
    SHA512 A42C1ED29BD5AF93496873247A25F35F07C330D3AD1BFD46F1F34BFCBBC06606784D87D2E5C975226D9A129601A527A5F7E76EE770666AE8E8A683873805D232
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
