
package=lua
$(package)_version=5.4.3
$(package)_download_path=https://www.lua.org/ftp/
$(package)_file_name=$(package)-$($(package)_version).tar.gz
$(package)_sha256_hash=f8612276169e3bfcbcfb8f226195bfc6e466fe13042f1076cbde92b7ec96bbfb
$(package)_patches=build_shared.patch

define $(package)_set_vars
  $(package)_build_opts_linux = PLAT=linux MYCFLAGS="-fPIC"
  $(package)_build_opts_linux += TO_LIB="liblua.a liblua5.4.so"
  $(package)_build_opts_mingw32 = PLAT=mingw
  $(package)_build_opts_mingw32 += CC="$($(package)_cc)" 
  $(package)_build_opts_mingw32 += TO_BIN="lua.exe luac.exe" TO_LIB="liblua.a lua54.dll"
endef

define $(package)_preprocess_cmds
  patch -p1 < $($(package)_patch_dir)/build_shared.patch
endef

define $(package)_config_cmds
endef

define $(package)_build_cmds
	$(MAKE) $($(package)_build_opts)
endef

define $(package)_stage_cmds
	$(MAKE) $($(package)_build_opts) INSTALL_TOP="$($(package)_staging_prefix_dir)" install
endef

define $(package)_postprocess_cmds
endef
