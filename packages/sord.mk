
package=sord
$(package)_version=0.16.8
$(package)_download_path=http://download.drobilla.net/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=7c289d2eaabf82fa6ac219107ce632d704672dcfb966e1a7ff0bbc4ce93f5e14
$(package)_dependencies=serd

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
