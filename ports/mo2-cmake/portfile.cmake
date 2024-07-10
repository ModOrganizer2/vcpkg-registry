set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ModOrganizer2/cmake_common
    REF dev/vcpkg
    SHA512 e0c3f0818242f41c60cac7548c8168a67ad5bd69db1c01303d594de4ba846f4bea45dc0055918dc16bfe342c77bd20bf05c3e36dcea1d58d6a3008510f036044
    HEAD_REF master
)

file(INSTALL
    "${SOURCE_PATH}/mo2_cpp.cmake"
    "${SOURCE_PATH}/mo2_python.cmake"
    "${SOURCE_PATH}/mo2_utils.cmake"
    "${SOURCE_PATH}/mo2.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2-cmake-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
