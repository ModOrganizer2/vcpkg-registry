cmake_minimum_required(VERSION 3.22)

if (DEFINED MO2_INCLUDED)
	return()
endif()

find_package(Qt6 6.7.0 REQUIRED COMPONENTS Core)

# version-major independent variables
set(Qt_VERSION ${Qt6_VERSION})
set(Qt_VERSION_MAJOR ${Qt6_VERSION_MAJOR})

include(${CMAKE_CURRENT_LIST_DIR}/mo2_utils.cmake)

# setup path for find_package(), etc.
mo2_required_variable(NAME CMAKE_INSTALL_PREFIX TYPE PATH)

# custom property, used to keep track of the type of target
define_property(
	TARGET PROPERTY MO2_TARGET_TYPE INHERITED
	BRIEF_DOCS  "Target type for MO2 C++ target."
	FULL_DOCS "Automatically set when using mo2_configure_XXX functions.")

# to be able to organize projects into folder for VS
set(USE_FOLDERS TRUE)

set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP autogen)
set_property(GLOBAL PROPERTY AUTOMOC_SOURCE_GROUP autogen)
set_property(GLOBAL PROPERTY AUTORCC_SOURCE_GROUP autogen)

include(${CMAKE_CURRENT_LIST_DIR}/mo2_cpp.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/mo2_python.cmake)

# mark as included
set(MO2_DEFINED true)
