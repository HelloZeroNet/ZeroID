import os

site_address = "yoursiteaddress"
site_privatekey = "yoursiteprivatekey"
bitmessage_url = "http://apiusername:apipassword@localhost:8442/" # ~/.config/PyBitmessage/keys.dat (apiusername = user, apipassword = pass)

zeronet_dir = "/home/zeronet/"
logfile = os.path.dirname(os.path.realpath(__file__))+"/bitmessage.log"

# To install add this lint to ~/.config/PyBitmessage/keys.dat [bitmessagesettings] section:
# apinotifypath = /home/zeronet/bitmessage-adder/bitmessage.py