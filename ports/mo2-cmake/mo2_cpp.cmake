cmake_minimum_required(VERSION 3.21)

if (POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW)
endif()

include(CMakeParseArguments)
include(${CMAKE_CURRENT_LIST_DIR}/mo2_utils.cmake)

#! mo2_configure_target : do basic configuration for a MO2 C++ target
#
# this functions does many things:
# - glob relevant files and add them to the target
# - set many compile flags, definitions, etc.
# - add step to create translations (if not turned OFF)
#
# \param:SOURCE_TREE if set, a source_group will be created using TREE
# \param:WARNINGS enable all warnings, possible values are ON/All, OFF, or 1, 2, 3, 4
#    for corresponding /W flags (ON is All) (default ON)
# \param:EXTERNAL_WARNINGS enable warnings for external libraries, possible values are
#   the same as warnings, but ON is 3 (default 1)
# \param:PERMISSIVE permissive mode (default OFF)
# \param:BIGOBJ enable bigobj (default OFF)
# \param:CLI enable C++/CLR (default OFF)
# \param:TRANSLATIONS generate translations (default ON)
# \param:AUTOMOC automoc (and autouic, autoqrc), (default ON)
# \param:EXTRA_TRANSLATIONS extra translations to include (folder)
#
function(mo2_configure_target TARGET)
	cmake_parse_arguments(MO2 "SOURCE_TREE"
		"WARNINGS;EXTERNAL_WARNINGS;PERMISSIVE;BIGOBJ;CLI;TRANSLATIONS;AUTOMOC"
		"EXTRA_TRANSLATIONS"
		${ARGN})

	# configure parameters and compiler flags
	mo2_set_if_not_defined(MO2_WARNINGS ON)
	mo2_set_if_not_defined(MO2_EXTERNAL_WARNINGS 1)
	mo2_set_if_not_defined(MO2_PERMISSIVE OFF)
	mo2_set_if_not_defined(MO2_BIGOBJ OFF)
	mo2_set_if_not_defined(MO2_CLI OFF)
	mo2_set_if_not_defined(MO2_TRANSLATIONS ON)
	mo2_set_if_not_defined(MO2_AUTOMOC ON)
	mo2_set_if_not_defined(MO2_EXTRA_TRANSLATIONS "")

	if (${MO2_AUTOMOC})
		find_package(Qt6 COMPONENTS Widgets REQUIRED)
		set_target_properties(${TARGET}
			PROPERTIES AUTOMOC ON AUTOUIC ON AUTORCC ON)
	endif()

	target_compile_options(${TARGET}
		PRIVATE "/MP"
		$<$<CONFIG:RelWithDebInfo>:/O2>
	)

	set(CXX_STANDARD 20)
	if (${MO2_CLI})
		set(CXX_STANDARD 17)
	endif()
	set_target_properties(${TARGET} PROPERTIES
		CXX_STANDARD ${CXX_STANDARD}
		CXX_EXTENSIONS OFF)

	# VS emits a warning for LTCG, at least for uibase, so maybe not required?
	target_link_options(${TARGET}
		PRIVATE
		$<$<CONFIG:RelWithDebInfo>:/LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF>)

	if (${MO2_WARNINGS} STREQUAL "ON")
		set(MO2_WARNINGS "All")
	endif()

	if (${MO2_EXTERNAL_WARNINGS} STREQUAL "ON")
		set(MO2_EXTERNAL_WARNINGS "3")
	endif()

	if(NOT (${MO2_WARNINGS} STREQUAL "OFF"))
		string(TOLOWER ${MO2_WARNINGS} MO2_WARNINGS)
		target_compile_options(${TARGET} PRIVATE "/W${MO2_WARNINGS}" "/wd4464")

		# external warnings
		if (${MO2_EXTERNAL_WARNINGS} STREQUAL "OFF")
			target_compile_options(${TARGET}
				PRIVATE "/external:anglebrackets" "/external:W0")
		else()
			string(TOLOWER ${MO2_EXTERNAL_WARNINGS} MO2_EXTERNAL_WARNINGS)
			target_compile_options(${TARGET}
				PRIVATE "/external:anglebrackets" "/external:W${MO2_EXTERNAL_WARNINGS}")
		endif()
	endif()

	if(NOT ${MO2_PERMISSIVE})
		target_compile_options(${TARGET} PRIVATE "/permissive-")
	endif()

	if(${MO2_BIGOBJ})
		target_compile_options(${TARGET} PRIVATE "/bigobj")
	endif()

	# find source files
	if(DEFINED AUTOGEN_BUILD_DIR)
		set(UI_HEADERS_DIR ${AUTOGEN_BUILD_DIR})
	else()
		set(UI_HEADERS_DIR ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_autogen/include_RelWithDebInfo)
	endif()

	file(GLOB_RECURSE source_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
	file(GLOB_RECURSE header_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
	file(GLOB_RECURSE qrc_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.qrc)
	file(GLOB_RECURSE rc_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.rc)
	file(GLOB_RECURSE ui_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/*.ui)
	file(GLOB_RECURSE ui_header_files CONFIGURE_DEPENDS ${UI_HEADERS_DIR}/*.h)
	file(GLOB_RECURSE rule_files CONFIGURE_DEPENDS ${CMAKE_BINARY_DIR}/*.rule)
	file(GLOB_RECURSE misc_files CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/../*.natvis)

	if (${MO2_SOURCE_TREE})
		source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}
			PREFIX src
			FILES ${source_files} ${header_files})
	else()
		source_group(src REGULAR_EXPRESSION ".*\\.(h|cpp)")
	endif()
	source_group(ui REGULAR_EXPRESSION ".*\\.ui")
	source_group(cmake FILES CMakeLists.txt)
	source_group(autogen FILES ${rule_files} ${qm_files} ${ui_header_files})
	source_group(autogen REGULAR_EXPRESSION ".*\\cmake_pch.*")
	source_group(resources FILES ${rc_files} ${qrc_files})


	if(${MO2_TRANSLATIONS})
		mo2_add_translations(${TARGET}
		    INSTALL_RELEASE
			SOURCES ${CMAKE_CURRENT_SOURCE_DIR} ${MO2_EXTRA_TRANSLATIONS})
	endif()

	target_sources(${TARGET}
		PRIVATE
		${source_files}
		${header_files}
		${ui_files}
		${ui_header_files}
		${qrc_files}
		${rc_files}
		${misc_files}
		${qm_files})

	execute_process(
	  COMMAND git log -1 --format=%h
	  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	  OUTPUT_VARIABLE GIT_COMMIT_HASH
	  OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	target_compile_definitions(
		${TARGET}
		PRIVATE
		_UNICODE
		UNICODE
		NOMINMAX
		_CRT_SECURE_NO_WARNINGS
		BOOST_CONFIG_SUPPRESS_OUTDATED_MESSAGE
		_SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
		QT_MESSAGELOGCONTEXT
		GITID="${GIT_COMMIT_HASH}")

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/pch.h)
		target_precompile_headers(${PROJECT_NAME}
			PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/pch.h)
	endif()

    if(${MO2_CLI})
        if (CMAKE_GENERATOR MATCHES "Visual Studio")
            set_target_properties(${TARGET} PROPERTIES COMMON_LANGUAGE_RUNTIME "")
        else()
			# can this really happen?
            set(COMPILE_FLAGS "${COMPILE_FLAGS} /clr")
            string(REPLACE "/EHs" "/EHa" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
        endif()
    endif()

	set_target_properties(${TARGET} PROPERTIES VS_STARTUP_PROJECT ${TARGET})

	target_link_libraries(${TARGET} PRIVATE Version Dbghelp)
endfunction()

#! mo2_configure_tests : configure a target as a MO2 C++ tests
#
# this function creates a set of tests available in the ${TARET}_gtests variable
#
# extra arguments are given to mo2_configure_target, TRANSLATIONS and AUTOMOC are
# OFF by default
#
function(mo2_configure_tests TARGET)
	mo2_configure_target(${TARGET} TRANSLATIONS OFF AUTOMOC OFF ${ARGN})

	set_target_properties(${TARGET} PROPERTIES MO2_TARGET_TYPE "tests")

	find_package(GTest REQUIRED)
	target_link_libraries(${TARGET} PRIVATE GTest::gtest GTest::gmock GTest::gtest_main)

	# gtest_discover_tests would be nice but it requires Qt DLL, uibase, etc., in the
	# path, etc., and is not working right now
	#
	# there is an open CMake issue: https://gitlab.kitware.com/cmake/cmake/-/issues/21453
	#
	# gtest_discover_tests(${TARGET}
	# 	WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin
	# 	PROPERTIES
	# 	VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin
	# )
	#

	gtest_add_tests(TARGET ${TARGET} TEST_LIST ${TARGET}_gtests)
	set(${TARGET}_gtests ${${TARGET}_gtests} PARENT_SCOPE)

	mo2_deploy_qt_for_tests(
		TARGET ${TARGET}
		BINARIES "$<FILTER:$<TARGET_RUNTIME_DLLS:${TARGET}>,EXCLUDE,^.*[/\\]Qt[^/\\]*[.]dll>")

	set_tests_properties(${${TARGET}_gtests}
		PROPERTIES
		ENVIRONMENT_MODIFICATION
		"PATH=path_list_prepend:$<JOIN:$<TARGET_RUNTIME_DLL_DIRS:${TARGET}>,\;>"
	)
endfunction()

#! mo2_configure_uibase : configure the uibase target for MO2
#
# this function does mostly nothing except calling mo2_configure_target, but is useful
# to be consistent with other mo2_configure_XXX
#
function(mo2_configure_uibase TARGET)
	if (NOT (${TARGET} STREQUAL "uibase"))
		message(WARNING "mo2_configure_uibase() should only be used on the uibase target")
	endif()

	mo2_configure_target(${TARGET} ${ARGN})
	set_target_properties(${TARGET} PROPERTIES MO2_TARGET_TYPE "uibase")

	target_include_directories(${TARGET} PUBLIC
		${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/game_features)

	mo2_set_project_to_run_from_install(
		${TARGET} EXECUTABLE ${CMAKE_INSTALL_PREFIX}/bin/ModOrganizer.exe)
endfunction()

#! mo2_configure_plugin : configure a target as a MO2 C++ plugin
#
# this function automatically set uibase as a dependency
#
# extra arguments are given to mo2_configure_target
#
function(mo2_configure_plugin TARGET)
	mo2_configure_target(${TARGET} ${ARGN})
	target_link_libraries(${TARGET} PUBLIC uibase)

	set_target_properties(${TARGET} PROPERTIES MO2_TARGET_TYPE "plugin")

	mo2_set_project_to_run_from_install(
		${TARGET} EXECUTABLE ${CMAKE_INSTALL_PREFIX}/bin/ModOrganizer.exe)
endfunction()

#! mo2_configure_library : configure a C++ library (NOT a plugin), can be a STATIC
# or SHARED library
#
# extra arguments are given to mo2_configure_target, TRANSLATIONS and AUTOMOC are
# OFF by default
#
function(mo2_configure_library TARGET)
	mo2_configure_target(${TARGET} AUTOMOC OFF TRANSLATIONS OFF ${ARGN})

	get_target_property(TARGET_TYPE ${TARGET} TYPE)

	target_include_directories(${TARGET}
		PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

	if (${TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
		set_target_properties(${TARGET} PROPERTIES MO2_TARGET_TYPE "library-static")
	else()
		mo2_set_project_to_run_from_install(
			${TARGET} EXECUTABLE ${CMAKE_INSTALL_PREFIX}/bin/ModOrganizer.exe)
		set_target_properties(${TARGET} PROPERTIES MO2_TARGET_TYPE "library-shared")
	endif()
endfunction()

#! mo2_configure_executable : configure a target as MO2 C++ executable
#
# \param:ELEVATED set flag on the executable to run as elevated by default
#
# extra arguments are given to mo2_configure_target
#
function(mo2_configure_executable TARGET)
	cmake_parse_arguments(MO2 "ELEVATED" "" "" ${ARGN})

	mo2_configure_target(${TARGET} ${ARGN})
	set_target_properties(${TARGET}
		PROPERTIES WIN32_EXECUTABLE TRUE MO2_TARGET_TYPE "executable")

	get_target_property(output_name ${TARGET} OUTPUT_NAME)
	if("${output_name}" STREQUAL "output_name-NOTFOUND")
		set(output_name ${TARGET})
	endif()

	mo2_set_project_to_run_from_install(
		${TARGET} EXECUTABLE ${CMAKE_INSTALL_PREFIX}/bin/${output_name})

	if (${MO2_ELEVATED})
		# does not work with target_link_options, so keeping it that way for now... this
		# is not a very used option anyway
		set_target_properties(${TARGET} PROPERTIES LINK_FLAGS
			"/MANIFESTUAC:\"level='requireAdministrator' uiAccess='false'\"")
	endif()
endfunction()

#! mo2_install_target : set install for a MO2 target
#
# for this to work properly, the target must have been configured
#
# \param:FOLDER install the plugin as a folder, instead of a single DLL, ignore for
#   other target types
# \param:INSTALLDIR installation directory, default is automatically deduced based on
#   the target type, this parameter is ignored for plugins and static libraries
#
function(mo2_install_target TARGET)
	cmake_parse_arguments(MO2 "FOLDER" "INSTALLDIR" "" ${ARGN})


	get_target_property(MO2_TARGET_TYPE ${TARGET} MO2_TARGET_TYPE)

	# core install: .lib, .dll or .exe, to the right folder
	if (${MO2_TARGET_TYPE} STREQUAL "uibase")
		mo2_set_if_not_defined(MO2_INSTALLDIR "bin")
		install(TARGETS ${TARGET} RUNTIME DESTINATION ${MO2_INSTALLDIR})
		install(TARGETS ${TARGET} ARCHIVE DESTINATION libs)
	elseif (${MO2_TARGET_TYPE} STREQUAL "plugin")
		if (${MO2_FOLDER})
			install(TARGETS ${TARGET} RUNTIME DESTINATION bin/plugins/$<TARGET_FILE_BASE_NAME:${TARGET}>)
		else()
			install(TARGETS ${TARGET} RUNTIME DESTINATION bin/plugins)
		endif()
		install(TARGETS ${TARGET} ARCHIVE DESTINATION libs)
	elseif (${MO2_TARGET_TYPE} STREQUAL "library-static")
		install(TARGETS ${TARGET} ARCHIVE DESTINATION libs)
	elseif (${MO2_TARGET_TYPE} STREQUAL "library-shared")
		mo2_set_if_not_defined(MO2_INSTALLDIR "bin/dlls")
		install(TARGETS ${TARGET} RUNTIME DESTINATION ${MO2_INSTALLDIR})
		install(TARGETS ${TARGET} ARCHIVE DESTINATION libs)
	elseif (${MO2_TARGET_TYPE} STREQUAL "executable")
		mo2_set_if_not_defined(MO2_INSTALLDIR "bin")
		install(TARGETS ${TARGET} RUNTIME DESTINATION ${MO2_INSTALLDIR})
	else()
		message(FATAL_ERROR "unknown MO2 target type for target '${TARGET}', did you forget using mo2_configure_XXX?")
	endif()

	# install PDB if possible
	if (NOT (${MO2_TARGET_TYPE} STREQUAL "library-static"))
		install(FILES $<TARGET_PDB_FILE:${TARGET}> DESTINATION pdb)
	endif()

endfunction()
