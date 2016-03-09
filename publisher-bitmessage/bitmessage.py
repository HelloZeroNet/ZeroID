#!/usr/bin/env python
import sys, os, time, json, xmlrpclib, re
import config

os.chdir(config.zeronet_dir)

def log(text):
	print text
	open(config.logfile, "a").write("\n[%s] %s" % (time.strftime("%a, %d %b %Y %H:%M:%S"), text))

def addUser(auth_address, user_name):
	data = json.load(open("data/%s/data/users_archive.json" % config.site_address))
	# Check if user name or auth address exits
	for data_user_name, data_cert in data["users"].items():
		if data_user_name.lower() == user_name.lower():
			return log("User name %s already exits." % user_name)
		if ",%s," % auth_address in data_cert:
			return log("Address %s already exits." % auth_address)

	data = json.load(open("data/%s/data/users.json" % config.site_address))
	# Check if user name or auth address exits
	for data_user_name, data_cert in data["users"].items():
		if data_user_name.lower() == user_name.lower():
			return log("User name %s already exits." % user_name)
		if ",%s," % auth_address in data_cert:
			return log("Address %s already exits." % auth_address)

	log("Adding %s %s" % (auth_address, user_name))

	sign = os.popen("python zeronet.py --debug cryptSign %s#bitmsg/%s %s 2>&1" % (auth_address, user_name, config.site_privatekey)).readlines()[-1].strip()

	log("Sign %s" % sign)
	if sign[-1] != "=": return False # Sign error

	data["users"][user_name] = "bitmsg,%s,%s" % (auth_address, sign)

	log("Saving json")
	json.dump(data, open("data/%s/data/users.json" % config.site_address, "w"), indent=2, sort_keys=True)

	log("Publishing")

	res = os.popen("python zeronet.py --debug siteSign %s %s --publish 2>&1" % (config.site_address, config.site_privatekey)).read()
	if "content.json signed!" not in res or "Successfuly published" not in res:
		return log(res)

	return True


api = xmlrpclib.ServerProxy(config.bitmessage_url)
res = api.getAllInboxMessages()
for message in json.loads(res)["inboxMessages"]:
	try:
		body = message["message"].decode("base64")
		subject = message["subject"].decode("base64")
		if subject.startswith("add:"):
			cmd, auth_address, user_name = subject.split(":")
		elif body.startswith("add:"):
			cmd, auth_address, user_name = body.split(":")
		else:
			log("Unknown message: %s %s %s" % (message["msgid"], subject, body))
			continue

		auth_address = re.sub("[^A-Za-z0-9]", "", auth_address)
		user_name = re.sub("[^A-Za-z0-9]", "", user_name)

		log("New user: %s %s" % (auth_address, user_name))
		if "slave" in sys.argv:
			log("Wait 30 sec to allow master updater")
			time.sleep(30)
		addUser(auth_address, user_name)
		log("Trashing message")
		log(api.trashMessage(message["msgid"]))

	except Exception, err:
		print err
		log("%s: %s" % (err, message))

print "Done."