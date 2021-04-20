package=serd
$(package)_version=0.30.10
$(package)_download_path=http://download.drobilla.net/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=affa80deec78921f86335e6fc3f18b80aefecf424f6a5755e9f2fa0eb0710edf

define $(package)_set_vars
  $(package)_config_opts=--static --no-shared
endef

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  $($(package)_waf_configure)
endef

define $(package)_build_cmds
  $(WAF) build -v
endef

define $(package)_stage_cmds
  $(WAF) install --progress --destdir=$($(package)_staging_dir)
endef

define $(package)_postprocess_cmds
endef
