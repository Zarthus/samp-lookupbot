<?php 

error_reporting(0);
set_time_limit(2);

$lookup = addslashes(str_replace(chr(0), '', $_GET['lookup']));
if ( !isset($_GET['lookup']) ) {
	echo "Please specify something to search for";
	die();
}
if ( !strlen($lookup) || empty($lookup) ) {
	echo "Your lookup was empty";
	die();
}
if ( !ctype_alnum( str_replace("_", "", $lookup) ) ) {
	echo "lookup was not alphanumeric";
	die();
}


$url = "http://wiki.sa-mp.com/wiki/";
$fullurl = $url . $lookup;
$result = "No result, Generated URL: $fullurl";
$found = false;
$content = file_get_contents($fullurl);
$content = explode("\n", $content);
$oddLookup = false;
if (strpos($lookup, '_') !== FALSE) $oddLookup = true;

$cpy = array();
$rf = false;
$rfi = 0;
foreach($content as $line)
{
	if ($rf && $rfi < 3) {
		$cpy['return'] .= strip_tags($line);
		$rfi ++;
		if ($rfi > 2) $rf = false;
	}
	
	if (strpos($line, 'Returns') !== FALSE) {
		$cpy['return'] = str_replace('  ', ' ', strip_tags(str_replace('Returns', 'Returns ', $line))); 
		$found = true; 
		if (strlen($cpy['return']) < 9) {
			$rf = true;
		}
	}
	
	if (strpos($line, 'Parameters:') !== FALSE) {
		$cpy['params'] = strip_tags(str_replace('Parameters:', '', $line));
		$found = true; 
	}
	
	if (isset($cpy['return']) && !$rf && isset($cpy['params'])) { break; }
}

if (!isset($cpy['params']) && isset($cpy['return'])) $cpy['params'] = '()';
if (isset($cpy['params']) && !isset($cpy['return'])) $cpy['return'] = 'Returns nothing (or result not found)';

$func = $lookup;
$params = str_replace('  ', ' ', $cpy['params']);
$returns = str_replace('  ', ' ', $cpy['return']);

$result = "$func$params - $returns";

if ($oddLookup && !$found || $found && (isset($_GET['return']) && $_GET['return'] == 'url')) 
	echo $fullurl;
else if ($found)
	echo $result;
else 
	echo "We could not find any result";
	
