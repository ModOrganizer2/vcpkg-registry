cmake_minimum_required(VERSION 3.21)

include(CMakeParseArguments)
include(${CMAKE_CURRENT_LIST_DIR}/mo2_utils.cmake)

#! mo2_configure_warnings : configuration warning for C++ target
#
# \param:WARNINGS level of warnings, possible values are ON/All, OFF, or 1, 2, 3, 4
#    for corresponding /W flags (ON is All) (default ON)
# \param:EXTERNAL enable warnings for external libraries, possible values are
#   the same as warnings, but ON is 3 (default 1)
#
function(mo2_configure_warnings TARGET)
	cmake_parse_arguments(MO2 "" "WARNINGS;EXTERNAL" "" ${ARGN})

	mo2_set_if_not_defined(MO2_WARNINGS ON)
	mo2_set_if_not_defined(MO2_EXTERNAL 1)

	if (${MO2_WARNINGS} STREQUAL "ON")
		set(MO2_WARNINGS "All")
	endif()

	if (${MO2_EXTERNAL} STREQUAL "ON")
		set(MO2_EXTERNAL "3")
	endif()

	if(NOT (${MO2_WARNINGS} STREQUAL "OFF"))
		string(TOLOWER ${MO2_WARNINGS} MO2_WARNINGS)
		target_compile_options(${TARGET} PRIVATE "/W${MO2_WARNINGS}" "/wd4464")

		# external warnings
		if (${MO2_EXTERNAL} STREQUAL "OFF")
			target_compile_options(${TARGET}
				PRIVATE "/external:anglebrackets" "/external:W0")
		else()
			string(TOLOWER ${MO2_EXTERNAL} MO2_EXTERNAL)
			target_compile_options(${TARGET}
				PRIVATE "/external:anglebrackets" "/external:W${MO2_EXTERNAL}")
		endif()
	endif()

endfunction()

#! mo2_configure_sources : configure sources for the given C++ target
#
# \param:SOURCE_TREE if set, a source_group will be created using TREE
#
function(mo2_configure_sources TARGET)
	cmake_parse_arguments(MO2 "SOURCE_TREE" "" "" ${ARGN})

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

	if (${MO2_SOURCE_TREE})
		source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}
			PREFIX src FILES ${source_files} ${header_files})
	else()
		source_group(src REGULAR_EXPRESSION ".*\\.(h|cpp)")
	endif()

	source_group(ui REGULAR_EXPRESSION ".*\\.ui")
	source_group(cmake FILES CMakeLists.txt)
	source_group(autogen FILES ${rule_files} ${qm_files} ${ui_header_files})
	source_group(autogen REGULAR_EXPRESSION ".*\\cmake_pch.*")
	source_group(resources FILES ${rc_files} ${qrc_files})

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

endfunction()

#! mo2_configure_msvc : set flags for C++ target with MSVC
#
# \param:PERMISSIVE permissive mode (default OFF)
# \param:BIGOBJ enable bigobj (default OFF)
# \param:CLI enable C++/CLR (default OFF)
#
function(mo2_configure_msvc TARGET)

	if (NOT MSVC)
		return()
	endif()

	cmake_parse_arguments(MO2 "" "PERMISSIVE;BIGOBJ;CLI" "" ${ARGN})

	set(CXX_STANDARD 20)
	if (${MO2_CLI})
		set(CXX_STANDARD 17)
	endif()
	set_target_properties(${TARGET} PROPERTIES
		CXX_STANDARD ${CXX_STANDARD} CXX_EXTENSIONS OFF)

	if(NOT ${MO2_PERMISSIVE})
		target_compile_options(${TARGET} PRIVATE "/permissive-")
	endif()

	if(${MO2_BIGOBJ})
		target_compile_options(${TARGET} PRIVATE "/bigobj")
	endif()

	# multi-threaded compilation
	target_compile_options(${TARGET} PRIVATE "/MP")

	# VS emits a warning for LTCG, at least for uibase, so maybe not required?
	target_link_options(${TARGET}
		PRIVATE
		$<$<CONFIG:RelWithDebInfo>:
			# enable link-time code generation
			/LTCG

			# disable incremental linking
			/INCREMENTAL:NO

			# eliminates functions and data that are never referenced
			/OPT:REF

			# perform identical COMDAT folding
			/OPT:ICF
		>)

    if(${MO2_CLI})
		set_target_properties(${TARGET} PROPERTIES COMMON_LANGUAGE_RUNTIME "")
    endif()

	set_target_properties(${TARGET} PROPERTIES VS_STARTUP_PROJECT ${TARGET})

endfunction()

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
	mo2_set_if_not_defined(MO2_PERMISSIVE OFF)
	mo2_set_if_not_defined(MO2_BIGOBJ OFF)
	mo2_set_if_not_defined(MO2_CLI OFF)
	mo2_set_if_not_defined(MO2_TRANSLATIONS ON)
	mo2_set_if_not_defined(MO2_AUTOMOC ON)
	mo2_set_if_not_defined(MO2_EXTRA_TRANSLATIONS "")

	mo2_configure_warnings(${TARGET} ${ARGN})
	mo2_configure_sources(${TARGET} ${ARGN})
	mo2_configure_msvc(${TARGET} ${ARGN})

	if (${MO2_AUTOMOC})
		find_package(Qt6 COMPONENTS Widgets REQUIRED)
		set_target_properties(${TARGET}
			PROPERTIES AUTOMOC ON AUTOUIC ON AUTORCC ON)
	endif()

	if(${MO2_TRANSLATIONS})
		mo2_add_translations(${TARGET}
		    INSTALL_RELEASE
			SOURCES ${CMAKE_CURRENT_SOURCE_DIR} ${MO2_EXTRA_TRANSLATIONS})
	endif()

	mo2_find_git_hash(GIT_COMMIT_HASH)
	target_compile_definitions(
		${TARGET} PRIVATE NOMINMAX QT_MESSAGELOGCONTEXT GITID="${GIT_COMMIT_HASH}")

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/pch.h)
		target_precompile_headers(${PROJECT_NAME}
			PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/pch.h)
	endif()
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

#! mo2_configure_plugin : configure a target as a MO2 C++ plugin
#
# this function automatically set uibase as a dependency
#
# extra arguments are given to mo2_configure_target
#
function(mo2_configure_plugin TARGET)
	mo2_configure_target(${TARGET} ${ARGN})
	mo2_set_project_to_run_from_install(
		${TARGET} EXECUTABLE ${CMAKE_INSTALL_PREFIX}/bin/ModOrganizer.exe)
endfunction()

#! mo2_install_plugin : install the given MO2 plugin
#
# for this to work properly, the target must have been configured
#
# \param:FOLDER install the plugin as a folder, instead of a single DLL
#
function(mo2_install_plugin TARGET)
	cmake_parse_arguments(MO2 "FOLDER" "" "" ${ARGN})

	if (${MO2_FOLDER})
		install(TARGETS ${TARGET} RUNTIME DESTINATION bin/plugins/$<TARGET_FILE_BASE_NAME:${TARGET}>)
	else()
		install(TARGETS ${TARGET} RUNTIME DESTINATION bin/plugins)
	endif()
	install(TARGETS ${TARGET} ARCHIVE DESTINATION lib)

	# install PDB if possible
	install(FILES $<TARGET_PDB_FILE:${TARGET}> DESTINATION pdb OPTIONAL)

endfunction()
