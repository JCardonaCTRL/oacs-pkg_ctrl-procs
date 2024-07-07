ad_library {

    Procedures for handling JSON list

    @author KH
    @cvs-id $Id$
    @creation-date 2009-10-04

}
namespace eval ctrl::json {}

ad_proc -public ctrl::json::filter_special_chars {
	str
} {
	Filters special characters:
		* double-backslashes become quadruple
		* single-quotes are excaped
		* control characters become C/JS escaped characters
} {
	return [string map {
		{\\}	{\\\\}
		"\\"	{\\}
		"\""	{\"}
		"\b"	{\\b}
		"\f"	{\\f}
		"\n"	{\\n}
		"\r"	{\\r}
		"\t"	{\\t}
	} $str]
}

ad_proc -public ctrl::json::filter_special_chars_dt {
	str
} {
	Filters special characters:
		* double-backslashes become quadruple
		* single-quotes are excaped
		* control characters become C/JS escaped characters
} {
	regsub -all "\\\\" $str "\\\\\\\\" str
    regsub -all "\b" $str "\\b" str
    regsub -all "\f" $str "\\f" str
    regsub -all "\n" $str "\\n" str
    regsub -all "\r" $str "\\r" str
    regsub -all "\t" $str "\\t" str
    regsub -all "'"  $str "" str
    regsub -all {"} $str {} str
    return $str 
}

ad_proc -public ctrl::json::format_special {
	str
} {
	Add JSON format when the string isn't complete
} {
	set str [string trim $str]
	set ch0 [string index $str 0]
	set chN [string index $str end]

	# If the JSON already start and ends with matched open/close braces/brackets...
	if {(($ch0 eq "\{") && ($cnN eq "\}"))	\
		|| (($ch0 eq "\[") && ($chN eq "\]"))} {
		# ... don't add any more
		return $str
	}

	# Check the JSON in serch of components to determine if an object
	# or is an array
	set point_values [llength [split $str ":"]]
	set comma_values [llength [split $str ","]]
	set space_values [llength [split $str " "]]

	# Quote the string if it is not already quated but needs to be (?????)
	if {(($comma_values == 1) \
		  && ($point_values == 1) \
		  && ($space_values == 1)) \
		  && (($ch0 ne "\"") && ($chN ne "\""))} {
		set str "\"[ctrl::json::filter_special_chars $str]\""
	}

	# Add braces/brackets (??? should point_values == 1 be comma_values == 1???)
	if {$point_values > 1} {
		set str "\{$str\}"
	} elseif {$point_values == 1} {
		set str "\[$str\]"
	}

	return $str
}

ad_proc ctrl::json::construct_record {
	info_list
} {
	@param key_value_list
} {
	set js_record [list]

	foreach info $info_list {
#		util_unlist $info key value value_type
	    lassign $info key value value_type
		switch -- $value_type {
			"o" {
				# the value type is an object
				if ![empty_string_p $key] {
					lappend js_record "\"$key\":{$value}"
				} else {
					lappend js_record "{$value}"
				}
			}
			"a" {
				# the value is an array that is a tcl list
				lappend js_record "\"$key\":\[[join $value ","]\]"
			}
                        "a-p" {
                                # the value pair separated by comma
                                lappend js_record "\"$key\":{[join $value ","]}"
                        }
			"a-joined" {
				# the value is an array that is the tcl list already joined by ","
				lappend js_record "\"$key\":\[$value\]"
			}
			"f" {
				# the value that gets no json wrapper
				lappend js_record "\"$key\":$value"
			}
			default {
				# a quoted value
				set value [ctrl::json::filter_special_chars $value]

				#		set value [regsub -all "\"" $value {\"}]
				#		set value [regsub -all "\n" $value	"<br />"]
				lappend js_record "\"$key\":\"$value\""
			}
		}
	}
	return [join $js_record ","]
}
