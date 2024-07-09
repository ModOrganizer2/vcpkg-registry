set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/mo2_cpp.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2_python.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2_utils.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2-cmake-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
