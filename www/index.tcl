set version_id [apm_version_id_from_package_key [ad_conn package_key]]
template::forward "/api-doc/package-view?version%5fid=$version_id&public%5fp=1&kind=procs"
#-template::forward "cg-tools/index"
