# USVFS is prebuilt and is always dynamic, but MO2 uses a static triplets (for Boost,
# lz4, etc.) so we disable that warning
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ModOrganizer2/usvfs/releases/download/v${VERSION}/usvfs_v${VERSION}.7z"
    FILENAME "usvfs_${VERSION}.7z"
    SHA512 98C7E2F569658550225BD2655A79BE67D3AE9A935D3407A5CBBB4C28DC22F352C20D1FE2EAAAAD82E1EC60C6CC53A03D5AFA59B8DB349B2F5AA0F2C7D2506CE1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/ModOrganizer2/usvfs/master/LICENSE"
    FILENAME "copyright"
    SHA512 8B089BBEADFFBD69B9C441C1C9AC6C0670D9890DE8E4115D39F4E7ABF6A834BBE392A4C91257465E4C97920172E94151BFF2DC39354EA753C002517AE8208CD5
)

# we need to move all files in appropriate locations:
#
#   bin/ should contain .dll and .pdb
#   lib/ should contain .lib and the cmake/ folder
#   tools/usvfs should contain .exe
#
# we also need to create debug/ with the same layout containing debug stuff
#
# the USVFS layout archive does not match exactly so we need to do some manually
# moving there and there
#

# install dll and their pdb for release
file(INSTALL
    ${SOURCE_PATH}/bin/usvfs_x64.dll
    ${SOURCE_PATH}/bin/usvfs_x86.dll
    ${SOURCE_PATH}/pdb/usvfs_x86.pdb
    ${SOURCE_PATH}/pdb/usvfs_x86.pdb
DESTINATION
    ${CURRENT_PACKAGES_DIR}/bin
)

# install dll and their pdb for debug
file(INSTALL
    ${SOURCE_PATH}/debug/bin/usvfs_x64.dll
    ${SOURCE_PATH}/debug/bin/usvfs_x86.dll
    ${SOURCE_PATH}/debug/pdb/usvfs_x86.pdb
    ${SOURCE_PATH}/debug/pdb/usvfs_x86.pdb
DESTINATION
    ${CURRENT_PACKAGES_DIR}/debug/bin
)

# install executable and their pdb for release
file(INSTALL
    ${SOURCE_PATH}/bin/usvfs_proxy_x64.exe
    ${SOURCE_PATH}/bin/usvfs_proxy_x86.exe
    ${SOURCE_PATH}/pdb/usvfs_proxy_x64.pdb
    ${SOURCE_PATH}/pdb/usvfs_proxy_x86.pdb
DESTINATION
    ${CURRENT_PACKAGES_DIR}/tools/usvfs
)

# install executable and their pdb for debug
file(INSTALL
    ${SOURCE_PATH}/debug/bin/usvfs_proxy_x64.exe
    ${SOURCE_PATH}/debug/bin/usvfs_proxy_x86.exe
    ${SOURCE_PATH}/debug/pdb/usvfs_proxy_x64.pdb
    ${SOURCE_PATH}/debug/pdb/usvfs_proxy_x86.pdb
DESTINATION
    ${CURRENT_PACKAGES_DIR}/debug/tools/usvfs
)

# install headers, lib and cmake stuff for release
file(INSTALL ${SOURCE_PATH}/include ${SOURCE_PATH}/lib DESTINATION ${CURRENT_PACKAGES_DIR})

# install lib and cmake stuff for debug
file(INSTALL ${SOURCE_PATH}/debug/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)

vcpkg_cmake_config_fixup(PACKAGE_NAME "usvfs" CONFIG_PATH "lib/cmake/usvfs")

# vcpkg_cmake_config_fixup does not seem to differentiate exe from debug and release
# so we need to manually fix this
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/usvfs/usvfs_x64Targets-debug.cmake"
    "\${_IMPORT_PREFIX}/tools"
    "\${_IMPORT_PREFIX}/debug/tools")
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/usvfs/usvfs_x86Targets-debug.cmake"
    "\${_IMPORT_PREFIX}/tools"
    "\${_IMPORT_PREFIX}/debug/tools")

vcpkg_install_copyright(FILE_LIST "${LICENSE}")
