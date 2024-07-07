ad_library {

    Procedures to handle the parameters passed in by datatable version 1.10+

    @author KH
    @cvs-id $Id$

}


namespace eval ctrl::jquery::datatable  {
    variable min_version 1.10

}



ad_proc -public ctrl::jquery::datatable::query_param { 
    {-column_array dt_info}
} {

    Convert the arrays passed in with [] and convert to () for compatiability  to TCL 

    @option formset

} {

    set param_ns_set [ns_getform]
    set data_list [ns_set array $param_ns_set]
 
    set sort_list [list]
    set other_attribute_list [list]

    set search_global [list]
    foreach {key value} $data_list  {
	set value [string trim $value]

	set arr_process_p 0
    
	# match the column information 
	if [regexp {columns\[([0-9]+)\]} $key full column] {
	    set key_v1 [string map {\]\[ "-"} $key]
	    set key_v1 [string map {\[ "-"} $key_v1]
	    set key_v1 [string map {\] ""} $key_v1]

	    set key_v1 [string trim $key_v1]

	    set key_list [lrange [split $key_v1 "-"] 2 end]

	    set arr_process_p 1

	    set attribute [join $key_list "-"]

	    if [info exists column_info($column)] {
		lappend column_info($column) $attribute $value
	    } else {
		array set column_info [list $column [list $attribute $value]]
#		set column_info($column) [list $attribute $value]
	    }
       

	    # match the order 
	}  elseif [regexp {order\[([0-9])+\]} $key full order] {
    
	    
	    # ---------------------
	    # order[$i][column]
	    # order[$i][dir]
	    # ---------------------
	    set key_v1 [string map {\]\[ "-"} $key]
	    set key_v1 [string map {\[ "-"} $key_v1]
	    set key_v1 [string map {\] ""} $key_v1]
	    set key_v1 [string trim $key_v1]
	    set key_list [lrange [split $key_v1 "-"] 1 end]

	    set order_attribute [lindex $key_list 1]
	    if [string equal $order_attribute column] {
		set direction asc
		set direction [ns_set iget $param_ns_set "order\[$order\]\[dir\]"]
		lappend  sort_list $value $direction
	    }
            # match the search 
	} elseif [regexp {search\[([a-z,A-Z]+)\]} $key full search_attr] {
	    # -------------------
	    # process 
	    # search[value] 
	    # search[regex]
	    # -------------------
	    set arr_process_p 1
	    lappend search_global $search_attr $value
	} else {
	    # -----------------------------------
	    # check other single value param
	    # -----------------------------------
	    set datatable_other_attribute_list [list draw start length]
	    if {[lsearch -exact $datatable_other_attribute_list $key] > -1} {
		lappend  other_attribute_list $key $value
	    }
	}
    }

    # ----------------
    # Process order_attribute
    #  ---------------------

    set new_sort_list [list]

    foreach {col direction}  $sort_list {
    
	if ![empty_string_p [array get column_info $col]] {

	    if [array exists onecolumn_info] {
		array unset onecolumn_info
	    }
	    array set onecolumn_info [set column_info($col)]
	    lappend new_sort_list $onecolumn_info(data) $direction
	}
    }

    upvar $column_array dt_info

    set info_list [list sort_list $new_sort_list search_global $search_global page_attribute_list $other_attribute_list column_info_list [array get column_info]]
    array set dt_info $info_list

}



ad_proc -public ctrl::jquery::datatable::editor_data_param {} {
    Return the data[xyz] into a key value list format specified by array get

    {xyz xyz_value ...}
} {

    set param_ns_set [ns_getform]
    set data_list [ns_set array $param_ns_set]

    set return_list [list]

    foreach {key value} $data_list  {
	set value [string trim $value]

	set arr_process_p 0
	# match the column information 
	if {[regexp {data\[([a-zA-Z_0-9]+)\]\[\]} $key full data_key]} {
	    if [empty_string_p [array get data_multiple_arr $data_key]] {
		set data_multiple_arr($data_key) $value
	    } else {
	        lappend data_multiple_arr($data_key) $value
	    }
	} elseif [regexp {data\[(.*)\]} $key full data_key] {
	    lappend return_list $data_key $value
	}
    }

    if [array exists data_multiple_arr] {
	set return_list [concat $return_list [array get data_multiple_arr]]
    }

    return $return_list
}