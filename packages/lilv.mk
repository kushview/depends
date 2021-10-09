
package=serd
$(package)_version=0.24.12
$(package)_download_path=http://download.drobilla.net/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=26a37790890c9c1f838203b47f5b2320334fe92c02a4d26ebbe2669dbd769061
$(package)_dependencies=lv2 serd sord sratom

define $(package)_set_vars
  $(package)_config_opts=--no-utils
endef

define $(package)_preprocess_cmds
endef

define $(package)_config_cmds
  $($(package)_waf_configure)
endef

define $(package)_build_cmds
  $(WAF) build
endef

define $(package)_stage_cmds
  $(WAF) install --progress --destdir=$($(package)_staging_dir)
endef

define $(package)_postprocess_cmds
endef
