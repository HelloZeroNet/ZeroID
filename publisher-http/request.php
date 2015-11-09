<?
include "config.php";

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: *');

if ($_SERVER['REQUEST_METHOD'] != "POST") {
	logdie("Not allowed");
}

if (isset($_SERVER['HTTP_REFERER']) and strpos($_SERVER['HTTP_REFERER'], $site) === false and strpos(strtolower($_SERVER['HTTP_REFERER']), $site_domain) === false) { 
	header('HTTP/1.0 403 Forbidden');
	logdie("Referer error.");
}

logtext("Request: Parsing parameters...");

logtext($_SERVER);
logtext($_POST);

logtext("Adding work...");

list($work_id, $work_task, $work_solution) = addWork();

$back = array();
$back["work_id"] = $work_id;
$back["work_task"] = $work_task;

$back = json_encode($back);

logtext("Sending work: $back");

echo $back;

?>