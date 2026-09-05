include(FetchContent)

list(APPEND MOD_REQUIREMENTS "RED4ext 1.27.0+")

# Runtime RED4ext zip is only for local game_dir_requirements. CI packages the mod itself.
if(DEFINED CMAKE_CI_BUILD)
  set(MOD_RED4EXT_DEPENDENCY_ADDED ON)
  return()
endif()

if(NOT DEFINED MOD_RED4EXT_DEPENDENCY_ADDED)
  if(NOT EXISTS ${MOD_BINARY_DIR}/downloads/red4ext.zip OR MOD_FORCE_UPDATE_DEPS)
    if(NOT DEFINED MOD_RED4EXT_DOWNLOAD_URL)
      # Prefer a stable direct asset URL; GitHub API often returns HTML/rate-limit pages in CI.
      set(MOD_RED4EXT_DOWNLOAD_URL
        "https://github.com/WopsS/RED4ext/releases/download/v1.30.0/red4ext-1.30.0.zip")
    endif()
    file(DOWNLOAD
      ${MOD_RED4EXT_DOWNLOAD_URL}
      ${MOD_BINARY_DIR}/downloads/red4ext.zip
      STATUS _red4ext_dl_status
    )
    list(GET _red4ext_dl_status 0 _red4ext_dl_code)
    if(NOT _red4ext_dl_code EQUAL 0)
      message(WARNING "Failed to download RED4ext runtime package: ${_red4ext_dl_status}")
    else()
      file(ARCHIVE_EXTRACT
        INPUT ${MOD_BINARY_DIR}/downloads/red4ext.zip
        DESTINATION ${TOP_MOD_SOURCE_DIR}/game_dir_requirements/
      )
    endif()
  endif()
  set(MOD_RED4EXT_DEPENDENCY_ADDED ON)
endif()
