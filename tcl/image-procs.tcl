# /packages/ctrl-procs/tcl/image-procs.tcl					-*- tab-width: 4 -*-
ad_library {

	Procs for images

	@creation-date	2/11/2005
	@cvs-id			$Id: image-procs.tcl,v 1.1 2005/03/10 23:36:05 jwang1 Exp $
}

namespace eval ctrl::image {}

ad_proc -public ctrl::image::get_info {
	{-filename}
	{-array}
	{-type ""}
} {
	Get the size of a .jpg or .gif image.  Returns the height and width
	information in the given array.

	@param filename The absolute path to the .jpg or .gif image in the filesystem.
	@param array	The name of the array to upvar the width and height information to.
	@param type		Either a gif or jpg

	@returns		1 if successful, 0 otherwise.

	@author			Jeff Wang
	@creation-date	2/11/2005
} {
	# Parse the file name out
	set extension	""
	set found_p		[regexp {.*/(.*)[.](.*)} $filename match image_filename extension]
	set file_list	[glob -nocomplain $filename]

	if {(!$found_p && [empty_string_p $type]) || ([llength $file_list] == 0)} {
		return 0
	} else {

		if {[string equal $extension "gif"] || [string equal $type "gif"]} {
			set size [ns_gifsize $filename]
		} elseif {[string equal $extension "jpg"] || [string equal $type "jpg"]} {
			set size [ns_jpegsize $filename]
		} else {
			ad_return_error "Error calling ctrl::image::get_info"
			"ctrl::image::get_info can only retreive information on .gif and .jpg images and you requested info for a file ending in '$extension'"
			ad_script_abort
		}

		upvar $array	local_array
		set local_array(width)	[lindex $size 0]
		set local_array(height) [lindex $size 1]

		return 1
	}
	return 0
}

ad_proc -private ctrl::image::metadata {
	{-file}
	{-content	""}
	{-into		""}
	{-as_attr_list:boolean}
} {
	<p>Use ImageMagick to get the metadata of an image file.  Make sure the file
	exists prior to calling this proc.</p>

	<p>//TODO// support passing in <var>content</var> directly</p>

	@param			into			The name of the array in the calling frame to fill.
	@param			as_attr_list_p	Pass this in order to get back a result as
									a list in <code>[array get ...]</code>
									format.
	@return			A list of metadata values.

	@see			ns_guesstype
	@see			ns_gifsize
	@see			ns_jpegsize
	@see			ctrl::image::dimensions

	@author			Andrew Helsley (helsleya@cs.ucr.edu)
	@creation-date	2009-02-05
} {
	if {[catch {
			exec identify -verbose $file | grep -Eie {(geometry|format)}
		} metadata]} {
		return [list]
	}

	regsub -all -- {(^|\n)\s*}	$metadata {\1}	metadata
	regsub -all -- {\s*(\n|$)}	$metadata {\1}	metadata
	regsub -all -- {:\s*}		$metadata {	}	metadata

	set result [list]
	foreach line [split $metadata "\n"] {
		foreach {name value} [split $line "\t"] { break ; }
		set name	[string trim [string tolower $name]]
		set value	[string trim [string tolower $value]]
		lappend result $name $value
	}
	if {[exists_and_not_null into]} {
		upvar $into the_metadata
	}
	array set the_metadata $result

	if {[exists_and_not_null the_metadata(geometry)]
		&& [regexp -- {([1-9][0-9]*)x([1-9][0-9]*)} $the_metadata(geometry) -> width height]} {
		array set the_metadata [list width $width height $height]
	}

	# Clean up format and set RFC 2616 compatible "content-type" from it
	#	This is an RFC 1590 "Internet Media Type" identifier.  Currently
	#	registered types can be found at:
	#
	#		http://www.iana.org/assignments/media-types/
	set format [string tolower [lindex $the_metadata(format) 0]]
	switch -- $format {
		jp2 - jpeg - gif - tiff - png {
			set the_metadata(type) image/$format
		}
		jpg {
			set the_metadata(type) image/jpeg
		}
		tif {
			set the_metadata(type) image/tiff
		}
		default {
			set the_metadata(type) application/$format
		}
	}

	if {$as_attr_list_p} {
		return [array get the_metadata]
	} elseif {[info exists the_metadata(width)]
			  && [info exists the_metadata(height)]
			  && [info exists the_metadata(format)]
			  && [info exists the_metadata(type)]} {
		return [list $the_metadata(width) $the_metadata(height) $the_metadata(type) $the_metadata(format)]
	} else {
		return [list]
	}
}

ad_proc -private ctrl::image::dimensions {
	{-file		""}
	{-content	""}
	{-into		""}
	{-as_attr_list:boolean}
} {
	<p>Use ImageMagick to get the dimensions of an image file.  Make sure the
	file exists prior to calling this proc.</p>

	<p>//TODO// support passing in <var>content</var> directly</p>

	@param			file			The path to the image file which you want to get the dimensions of.
	@param			content			The contents of an image which you want to get the dimensions of.
	@param			into			The name of the array in the calling frame to fill.
	@param			as_attr_list_p	Pass this in order to get back a result as
									a list in <code>[array get ...]</code>
									format.
	@return			A list of dimension values.

	@see			ns_guesstype
	@see			ns_gifsize
	@see			ns_jpegsize
	@see			ctrl::image::metadata

	@author			Andrew Helsley (helsleya@cs.ucr.edu)
	@creation-date	2009-02-02
} {
	if {$file eq "" && $content eq ""} {
		error "Must supply -file OR -content"
	} elseif {$file eq "" && $content ne ""} {
		set file /dev/stdin
		# //TODO// arrange to pipe $content into the command
	}

	# //TODO// use identify ... -format "%wx%h" and avoid 'grep'+'head'?:
	set dimensions [lindex [exec identify -verbose $file 2>/dev/null | grep -Eie geometry | head -n 1] 1]
	if {[regexp -- {0*([1-9][0-9]*)x0*([1-9][0-9]*)} $dimensions -> width height]} {
		if {[exists_and_not_null into]} {
			upvar $into dims
		}
		array set dims [list width $width height $height]
		if {$as_attr_list_p} {
			return [array get dims]
		} else {
			return [list $width $height]
		}
	}

	if {[exists_and_not_null into]} {
		upvar $into dims
		array set dims [list]
	}
	return [list]
}
