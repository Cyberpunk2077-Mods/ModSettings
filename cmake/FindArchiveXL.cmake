include(FetchContent)
include(ResolveDependency)

if(NOT TARGET ArchiveXL)
  resolve_dependency(deps/archive_xl)
  add_library(ArchiveXL INTERFACE)
  target_include_directories(ArchiveXL INTERFACE deps/archive_xl/support/red4ext)
endif()

list(APPEND MOD_REQUIREMENTS "ArchiveXL 1.23.0+")

# Runtime ArchiveXL zip is only for local game_dir_requirements. CI packages the mod itself.
if(DEFINED CMAKE_CI_BUILD)
  set(MOD_ARCHIVE_XL_DEPENDENCY_ADDED ON)
  return()
endif()

if(NOT DEFINED MOD_ARCHIVE_XL_DEPENDENCY_ADDED)
  if(NOT EXISTS ${MOD_BINARY_DIR}/downloads/archiveXL.zip OR MOD_FORCE_UPDATE_DEPS)
    if(NOT DEFINED MOD_ARCHIVE_XL_DOWNLOAD_URL)
      set(MOD_ARCHIVE_XL_DOWNLOAD_URL
        "https://github.com/psiberx/cp2077-archive-xl/releases/download/v1.27.1/ArchiveXL-1.27.1.zip")
    endif()
    file(DOWNLOAD
      ${MOD_ARCHIVE_XL_DOWNLOAD_URL}
      ${MOD_BINARY_DIR}/downloads/archiveXL.zip
      STATUS _archivexl_dl_status
    )
    list(GET _archivexl_dl_status 0 _archivexl_dl_code)
    if(NOT _archivexl_dl_code EQUAL 0)
      message(WARNING "Failed to download ArchiveXL runtime package: ${_archivexl_dl_status}")
    else()
      file(ARCHIVE_EXTRACT
        INPUT ${MOD_BINARY_DIR}/downloads/archiveXL.zip
        DESTINATION ${TOP_MOD_SOURCE_DIR}/game_dir_requirements/
      )
    endif()
  endif()
  set(MOD_ARCHIVE_XL_DEPENDENCY_ADDED ON)
endif()
