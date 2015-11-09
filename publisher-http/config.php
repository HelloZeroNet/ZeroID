<?
$logfile = getcwd()."/.log.txt";
function logtext($text) {
	global $logfile;
	$text = print_r($text, true);
	$f = fopen($logfile, "a");
	fwrite($f, "\n\n".date("c")." ".$text);
	fclose($f);

}

function logdie($text) {
	logtext($text);
	die($text);
}

$workfile = getcwd()."/.works.db";
$works = json_decode(file_get_contents($workfile));
function addWork() {
	global $works;
	$work_id = time()+rand(1,10000)/1000;
	// Add here anything you want
	$num1 = round(rand(0,1000));
	$num2 = round(rand(0,1000));
	$work_task = "$num1*$num2"; // Any javascript code
	$work_solution = $num1*$num2; // The solution

	// Add to works
	$works->{$work_id} = $work_solution;

	saveWorks();

	return array($work_id, $work_task, $work_solution);
}

function verifyWork($work_id, $work_solution) {
	include("ratelimit.php");
	global $works;
	$res = ($works->{$work_id} == $work_solution); // Solution is right
	logtext($work_id.": ".$works->{$work_id}." ? ".$work_solution);
	unset($works->{$work_id});
	saveWorks();
	return $res;
}


function saveWorks() {
	global $works, $workfile;
	$f = fopen($workfile, "w");
	fwrite($f, json_encode($works, JSON_PRETTY_PRINT));
	fclose($f);
}


$site = "1iD5ZQJMNXu43w1qLB8sfdHVKppVMduGz";
$site_domain = "zeroid.bit";
$privatekey = // your site privatekey

$zeronet_dir = // your zeronet installation dir
$users_json = "$zeronet_dir/data/$site/data/users.json";

?>