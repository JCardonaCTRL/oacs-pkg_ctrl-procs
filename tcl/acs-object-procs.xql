<?xml version="1.0"?>
<queryset>
	<fullquery name="ctrl::acs_object::update_object.update">
	 <querytext>
		begin
			acs_object.update_last_modified (
				object_id 		=> :object_id,
				modifying_user  => :modifying_user,
				modifying_ip 	=> :modifying_ip
			);
		end;
	 </querytext>
	</fullquery>

	<fullquery name="ctrl::object::touch.touch">
	 <querytext>
		begin
			acs_object.update_last_modified (
				object_id 		=> :object_id,
				modifying_user  => :modifying_user,
				modifying_ip 	=> :modifying_ip
			);
		end;
	 </querytext>
	</fullquery>
</queryset>

<!--	vim:set ts=4 sw=4 syntax=sql:	-->
<!--	Local Variables:				-->
<!--	mode:		sql					-->
<!--	tab-width:	4					-->
<!--	End:							-->
