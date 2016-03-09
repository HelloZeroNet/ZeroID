<?
include "config.php";

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: *');


if (isset($_SERVER['HTTP_REFERER']) and strpos($_SERVER['HTTP_REFERER'], $site) === false and strpos(strtolower($_SERVER['HTTP_REFERER']), $site_domain) === false) {
	header('HTTP/1.0 403 Forbidden');
	logdie("Referer error.");
}


logtext("Solution: Parsing parameters...");
logtext($_POST);

$_POST["work_id"] = 0+$_POST["work_id"];

$auth_address = $_POST["auth_address"];
$user_name = trim($_POST["user_name"], " ");

if (!preg_match("#^[A-Za-z0-9]+$#", $user_name)) {
	header("HTTP/1.0 400 Bad Request");
	logdie("Only english letters and numbers allowed in username.");
}

if (!preg_match("#^[A-Za-z0-9]+$#", $auth_address)) {
	header("HTTP/1.0 400 Bad Request");
	logdie("Bad address.");
}



logtext("Loading archive users...");
$data = json_decode(file_get_contents($users_archive_json));

foreach ($data->users as $data_user_name => $data_cert) {
	if (strtolower($data_user_name) == strtolower($user_name)) {
		header("HTTP/1.0 400 Bad Request");
		logdie("Username $user_name already exits.");
	}
	if (strpos($data_cert, ",".$auth_address.",") !== false) {
		header("HTTP/1.0 400 Bad Request");
		logdie("Address $auth_address already exits.");
	}
}


logtext("Loading users...");
$data = json_decode(file_get_contents($users_json));

foreach ($data->users as $data_user_name => $data_cert) {
	if (strtolower($data_user_name) == strtolower($user_name)) {
		header("HTTP/1.0 400 Bad Request");
		logdie("Username $user_name already exits.");
	}
	if (strpos($data_cert, ",".$auth_address.",") !== false) {
		header("HTTP/1.0 400 Bad Request");
		logdie("Address $auth_address already exits.");
	}
}


logtext("Verify work...");
$res = verifyWork($_POST["work_id"], $_POST["work_solution"]);
if (!$res) {
	header("HTTP/1.0 400 Bad Request");
	logdie("Bad solution :(");
}


logtext("Good solution, signing...");
chdir($zeronet_dir);
$out = array();
exec("python zeronet.py --debug cryptSign $auth_address#web/$user_name $privatekey 2>&1", $out);
$sign = $out[sizeof($out)-1];
$back = implode("\n", $out);
logtext($back);
logtext($sign);

if ($sign{strlen($sign)-1} != "=") logdie("User sign error, please contact site owner!");


logtext("Adding to users...");
$data->users->{$user_name} = "web,$auth_address,$sign";
$json_out = json_encode($data, JSON_PRETTY_PRINT);

$f = fopen($users_json, "w");
fwrite($f, $json_out);
fclose($f);


logtext("Signing...");
$out = array();
exec("python zeronet.py --debug siteSign $site $privatekey --publish 2>&1", $out);
$out = implode("\n", $out);
logtext($out);
if (strpos($out, "content.json signed!") === false) {
	header("HTTP/1.0 500 Internal Server Error");
	logdie("Site sign error, please contact site owner!");
}

/*
logtext("Publishing...");
$server_ip = $_SERVER['SERVER_ADDR'];
$out = array();
exec("python zeronet.py --debug --ip_external $server_ip sitePublish $site 2>&1", $out);
$out = implode("\n", $out);
logtext($out);
if (strpos($out, "Successfuly published") === false) {
	header("HTTP/1.0 500 Internal Server Error");
	logdie("Publish error, please contact site owner!");
}
*/

echo "OK";

?>