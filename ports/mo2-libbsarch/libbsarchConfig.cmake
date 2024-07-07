if (TARGET libbsarch::libbsarch)
  return()
endif()

find_package(DirectXTex CONFIG REQUIRED)

get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

# create the actual library
add_library(libbsarch::libbsarch SHARED IMPORTED)
target_sources(libbsarch::libbsarch
    INTERFACE
        FILE_SET HEADERS
        TYPE HEADERS
        BASE_DIRS ${_IMPORT_PREFIX}/include
        FILES
            ${_IMPORT_PREFIX}/include/utils/convertible_ostream.hpp
            ${_IMPORT_PREFIX}/include/utils/convertible_string.hpp
            ${_IMPORT_PREFIX}/include/utils/string_convert.hpp
            ${_IMPORT_PREFIX}/include/base_types.hpp
            ${_IMPORT_PREFIX}/include/base_types.hpp
            ${_IMPORT_PREFIX}/include/bs_archive_auto.hpp
            ${_IMPORT_PREFIX}/include/bs_archive_entries.h
            ${_IMPORT_PREFIX}/include/bs_archive.h
            ${_IMPORT_PREFIX}/include/libbsarch.h
            ${_IMPORT_PREFIX}/include/libbsarch.hpp
            ${_IMPORT_PREFIX}/include/DDS.h
)
target_link_libraries(libbsarch::libbsarch
    INTERFACE
    "${_IMPORT_PREFIX}/lib/libbsarch_OOP.lib"
    Microsoft::DirectXTex)
set_target_properties(libbsarch::libbsarch PROPERTIES
    IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libbsarch.lib"
    IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/libbsarch.dll"
    IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/libbsarch.lib"
    IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/libbsarch.dll"
)
