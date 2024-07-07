# /packages/cra/tcl/ajax-procs.tcl
ad_library {
	Utilities for Ajax Services

	@author: shhong@mednet.ucla.edu
	@creation-date: 2015-05-21
}

namespace eval cra::ajax {}

ad_proc -public cra::ajax::filter_special_chars {
   {-str:required}
} {
    Filter special characters
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
