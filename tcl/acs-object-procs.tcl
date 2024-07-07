# /packages/acs4x/tcl/acs-object-procs.tcl					-*- tab-width: 4 -*-
ad_library {

	Utility procs to help with ACS Objects

	@creation-date	2004/12/3
	@cvs-id			$Id: acs-object-procs.tcl,v 1.2 2005/11/19 08:47:53 andy Exp $
}

namespace eval ctrl::acs_object {}

ad_proc -public ctrl::acs_object::update_object {
	{-object_id:required}
	{-modifying_user ""}
	{-modifying_ip ""}
} {
	Update the acs_objects last_modified_date, user, and ip
} {
	if {![exists_and_not_null modifying_user]} {
		set modifying_user [ad_conn user_id]
	}
	if {![exists_and_not_null modifying_ip]} {
		set modifying_ip [ad_conn peeraddr]
	}

	db_exec_plsql update {}
}

namespace eval ctrl::object {}

ad_proc -public ctrl::object::touch {
	{-object_id:required}
	{-modifying_user	{[ad_conn user_id]}}
	{-modifying_ip		{[ad_conn peeraddr]}}
} {
	Update the acs_objects last_modified_date, user, and ip.  This will also
	update the last_modified_date of all objects that are under this object_id
	in the tree formed by linking objects via object_id and context_id.
} {
	set modifying_user	[subst $modifying_user]
	set modifying_ip	[subst $modifying_ip]
	db_exec_plsql touch {}
}
