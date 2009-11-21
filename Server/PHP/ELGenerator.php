<?php

//  Copyright (c) 2009 Dmitry Chestnykh, Coding Robots
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

require_once("ELConfig.php");

// Get name
$name = @$_REQUEST["name"];

if (!isset($name) || strlen($name) == 0) {
	if ($output_errors)
		print "Error: name is empty\n";
	exit(8);	
}


// --- don't change anything after this line --- 

$errors = array(
	1 => "error reading parameters from stdin",
	2 => "unknown curve",
	3 => "cannot initialize key",
	4 => "cannot decode public key",
	5 => "cannot decode private key",
	6 => "wrong private or public key",
	7 => "cannot generate signature"
);


function add_dashes($s)
{
	global $number_chars_in_dash_group;
	if ($number_chars_in_dash_group == 0)
		return $s;
	return implode("-", str_split($s, $number_chars_in_dash_group));
}


$descriptorspec = array(
   0 => array("pipe", "r"),
   1 => array("pipe", "w"),
);

$process = proc_open($elgen_path."elgen", $descriptorspec, $pipes);

if (is_resource($process)) {
	///*debug*/print "$name\n$curve_name\n$public_key\n$private_key";
    fwrite($pipes[0], "$name\n$curve_name\n$public_key\n$private_key");
    fclose($pipes[0]);

    $key = stream_get_contents($pipes[1]);
    fclose($pipes[1]);

    $return = proc_close($process);
	if ($return != 0) {
		if ($output_errors)
    		print "Error: ${errors[$return]}\n";
		exit($return);
	}
}
$out = str_replace("{#name}", $name, $output_format);
$out = str_replace("{#key}", add_dashes($key), $out);
print $out;

?>
