
package=lv2
$(package)_version=1.18.2
$(package)_download_path=https://lv2plug.in/spec/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=4e891fbc744c05855beb5dfa82e822b14917dd66e98f82b8230dbd1c7ab2e05e

define $(package)_set_vars
  $(package)_config_opts += --lv2dir=$($($(package)_type)_prefix)/lib/lv2 --copy-headers
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
