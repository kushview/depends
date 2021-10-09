
package=suil
$(package)_version=0.10.10
$(package)_download_path=http://download.drobilla.net/
$(package)_file_name=$(package)-$($(package)_version).tar.bz2
$(package)_sha256_hash=750f08e6b7dc941a5e694c484aab02f69af5aa90edcc9fb2ffb4fb45f1574bfb
$(package)_dependencies=lv2 serd sord

define $(package)_set_vars
  $(package)_config_opts=
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
