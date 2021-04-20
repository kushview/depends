
package=sratom
$(package)_version=0.6.8
$(package)_download_path=http://download.drobilla.net/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=3acb32b1adc5a2b7facdade2e0818bcd6c71f23f84a1ebc17815bb7a0d2d02df
$(package)_dependencies=lv2 serd sord

define $(package)_set_vars
  $(package)_config_opts=--static --no-shared
endef

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  $($(package)_waf_configure)
endef

define $(package)_build_cmds
  $(WAF) build --progress
endef

define $(package)_stage_cmds
  $(WAF) install --progress --destdir=$($(package)_staging_dir)
endef

define $(package)_postprocess_cmds
endef
