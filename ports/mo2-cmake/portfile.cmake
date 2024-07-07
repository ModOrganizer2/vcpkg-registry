if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "vcpkg-cmake is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/mo2_cpp.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2_python.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2_utils.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/mo2-cmake-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
