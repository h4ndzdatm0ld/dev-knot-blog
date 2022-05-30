---
title: Programatically Enable NETCONF and MD-CLI on Nokia – SROS
author: Hugo Tinoco
type: post
draft: false
date: 2020-05-18T19:24:24+00:00
url: /2020/05/18/programatically-enable-netconf-and-md-cli-on-nokia-sros/
timeline_notification:
  - 1589829866
categories:
  - Automation
  - Networking
---

Hi everyone,

First things first, the code lives here:

<https://github.com/h4ndzdatm0ld/sros-enable-netconf>

I wanted to put together a mini-series of posts on how to programatically enable netconf across many ALU/Nokia &#8211; SROS devices.

The theoretical problem we are trying to solve:

- Company Avifi has recently decided to enable NETCONF across their entire 7750 platform. They would like to do this all in one maintenance night.
- All of Avifi&#8217;s network is currently documented and stored in Netbox. We must extract a list of 7750&#8217;s and their IP addresses using the API requests.
- Programatically SSH into all the necessary devices:
  - Enable NETCONF
  - Create a NETCONF USER/PASSWORD
  - Enable Model-Driven CLI.

As a network engineer that&#8217;s constantly having to re-use scripts, templates, etc &#8211; I&#8217;d see this as an opportunity to create two things:

1. A tool I can easily use in my lab environment before I take this to production.
2. A production ready tool that my team can use.

We&#8217;ll start with a command line driven tool to easily target a single node, ssh into it and programmatically enable NETCONF as well as change from the standard CLI to the new Model-Driven CLI that Nokia offers on their 7750&#8217;s routers.

> As I&#8217;m getting more into the Dev/NET/OPS side of the house, I&#8217;m starting to think about CI/CD, unit tests, version control and the extensive amount of testing and variables that may change when implementing network wide changes via automation.

Let&#8217;s discuss some of the packages i&#8217;ll be using with Python 3.

Everyone should be familiar with **Netmiko** by now. We&#8217;ll use this to connect via SSH to our devices and manipulate our configurations.  As the starting point to this will be to build from a command line driven utility which targets a single node and expand into extracting a list of devices via Netbox, we will use **argparse** to send arguments from the CLI to our python script. **NCCLIENT** will be used to establish NETCONF connections. In order to not store passwords on our script, we will use **getpass** to prompt our users for passwords. On our future updated post, we&#8217;ll call the **pyNetbox** package / API client to interact with Netbox and extract the correct device IP addresses and run the script against it. **xmltodict** to convert the xml extracted file and parse to a dictionary.

<img loading="lazy" class="alignnone size-full wp-image-127" src="http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-18-at-12.07.21-pm.png" alt="Screen Shot 2020-05-18 at 12.07.21 PM" width="738" height="240" srcset="http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-18-at-12.07.21-pm.png 738w, http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-18-at-12.07.21-pm-300x98.png 300w" sizes="(max-width: 738px) 100vw, 738px" />

The tool will accept the arguements above, but the SSH username is defaulted to &#8216;admin&#8217;.

Once ran, the script will request for the SSH Password to the device, it will connect and send a list of commands to enable the NETCONF service and also switch from the Classic CLI to the new Model Driven CLI. Once this is complete, the SSH connection will be dropped and a new connection on port 830, the default NETCONF port will be established utilizing the new credentials. The tool will proceed to extract the running configuration, it will save a temp file and re-open it to parse it into a dictionary. We&#8217;ll extract the system name and use it as a var to create a folder directory of configurations and save the XML configuration by system name.

**Before running, open the script and edit the new usser credentials that you wish to pass for NETCONF connections. **

At this point, i&#8217;m able to run this against a multitude of devices individually to test functionality and make any adjustments before I implement the API connection into our Netbox server.

Below is the entire code, at beta. This command line driven utility will utilize NETMIKO to establish the initial connection to the device.  On the next post, we will take this code and change quite a bit to dynamically pass in a list of hosts from the Netbox API.

> <div>
>   <div>
>     <code>import netmiko, ncclient, argparse, getpass, sys, time, xmltodict, os&lt;/div>
> &lt;div>from netmiko import ConnectHandler&lt;/div>
> &lt;div>from ncclient import manager&lt;/div>
> &lt;div>from ncclient.xml_ import *&lt;/div>
> &lt;div>from xml.etree import ElementTree&lt;/div>
> &lt;div>def get_arguments():&lt;/div>
> &lt;div>parser = argparse.ArgumentParser(description='Command Line Driven Utility To Enable NETCONF\&lt;/div>
> &lt;div>On SROS Devices And MD-CLI.')&lt;/div>
> &lt;div>parser.add_argument("-n", "--node", help="Target NODE IP", required=True)&lt;/div>
> &lt;div>parser.add_argument("-u", "--user", help="SSH Username", required=False, default='admin')&lt;/div>
> &lt;div>parser.add_argument("-p", "--port", help="NETCONF TCP Port", required=False, default='830')&lt;/div>
> &lt;div>args = parser.parse_args()&lt;/div>
> &lt;div>return args&lt;/div>
> &lt;div># Lets make it easier to send and receive the output to the screen.&lt;/div>
> &lt;div># We'll create a function to pass in a list of commands as arguements.&lt;/div>
> &lt;div>def send_cmmdz(node_conn,list_of_cmds):&lt;/div>
> &lt;div>''' This function will unpack the dictionary created for the remote host to establish a connection with&lt;/div>
> &lt;div>and send a LIST of commands. The output will be printed to the screen.&lt;/div>
> &lt;div>Establish the 'node_conn' var first by unpacking the device connection dictionary. Pass it in as an args.&lt;/div>
> &lt;div>'''&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div>x = node_conn.send_config_set(list_of_cmds)&lt;/div>
> &lt;div>print(x)&lt;/div>
> &lt;div>exceptExceptionas e:&lt;/div>
> &lt;div>print(f"Issue with list of cmdz, {e}")&lt;/div>
> &lt;div>def send_single(node_conn, command):&lt;/div>
> &lt;div>''' This function will unpack the dictionary created for the remote host to establish a connection with&lt;/div>
> &lt;div>and send a single command. The output will be printed to the screen.&lt;/div>
> &lt;div>Establish the 'node_conn' var first by unpacking the device connection dictionary. Pass it in as an args.[]&lt;/div>
> &lt;div>'''&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div>x = node_conn.send_command(command)&lt;/div>
> &lt;div>print (x)&lt;/div>
> &lt;div>exceptExceptionas e:&lt;/div>
> &lt;div>sys.exit(e)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>def disconnect(node_conn):&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div>node_conn.disconnect()&lt;/div>
> &lt;div>exceptExceptionas e:&lt;/div>
> &lt;div>print(e)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>def netconfconn(args,ncusername,ncpassword):&lt;/div>
> &lt;div>conn = manager.connect(host=args.node,&lt;/div>
> &lt;div>port=args.port,&lt;/div>
> &lt;div>username=ncusername,&lt;/div>
> &lt;div>password=ncpassword,&lt;/div>
> &lt;div>hostkey_verify=False,&lt;/div>
> &lt;div>device_params={'name':'alu'})&lt;/div>
> &lt;div>return conn&lt;/div>
> &lt;div>def saveFile(filename, contents):&lt;/div>
> &lt;div>''' Save the contents to a file in the PWD.&lt;/div>
> &lt;div>'''&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div>f = open(filename, 'w+')&lt;/div>
> &lt;div>f.write(contents)&lt;/div>
> &lt;div>f.close()&lt;/div>
> &lt;div>exceptExceptionas e:&lt;/div>
> &lt;div>print(e)&lt;/div>
> &lt;div>def createFolder(directory):&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div>ifnot os.path.exists(directory):&lt;/div>
> &lt;div>os.makedirs(directory)&lt;/div>
> &lt;div>exceptOSError:&lt;/div>
> &lt;div>print('Error: Creating directory. '+ directory)&lt;/div>
> &lt;div>def main():&lt;/div>
> &lt;div># Extract the Arguements from ARGSPARSE:&lt;/div>
> &lt;div>args = get_arguments()&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Define the NETCONF USERNAME / PASSWORD:&lt;/div>
> &lt;div>NETCONF_USER = 'netconf'&lt;/div>
> &lt;div>NETCONF_PASS = 'NCadmin123'&lt;/div>
> &lt;div># # Create a dictionary for our device.&lt;/div>
> &lt;div>sros = {&lt;/div>
> &lt;div>'device_type': 'alcatel_sros',&lt;/div>
> &lt;div>'host': args.node,&lt;/div>
> &lt;div>'username': args.user,&lt;/div>
> &lt;div>'password': getpass.getpass(),&lt;/div>
> &lt;div>}&lt;/div>
> &lt;div># Pass in the dict and create the connection.&lt;/div>
> &lt;div>sros_conn = net_connect = ConnectHandler(**sros)&lt;/div>
> &lt;div># Establish a list of pre and post check commands.&lt;/div>
> &lt;div>print('Connecting to device and executing script...')&lt;/div>
> &lt;div>send_single(sros_conn, 'show system information | match Name')&lt;/div>
> &lt;div>send_single(sros_conn, 'show system netconf | match State')&lt;/div>
> &lt;div>enableNetconf = ['system security profile "netconf" netconf base-op-authorization lock',&lt;/div>
> &lt;div>'system security profile "netconf" netconf base-op-authorization kill-session',&lt;/div>
> &lt;div>f'system security user {NETCONF_USER} access netconf',&lt;/div>
> &lt;div>f'system security user {NETCONF_USER} password {NETCONF_PASS}',&lt;/div>
> &lt;div>f'system security user {NETCONF_USER} console member {NETCONF_USER}',&lt;/div>
> &lt;div>f'system security user {NETCONF_USER} console member "administrative"',&lt;/div>
> &lt;div>'system management-interface yang-modules nokia-modules',&lt;/div>
> &lt;div>'system management-interface yang-modules no base-r13-modules',&lt;/div>
> &lt;div>'system netconf auto-config-save',&lt;/div>
> &lt;div>'system netconf no shutdown',&lt;/div>
> &lt;div>'system management-interface cli md-cli auto-config-save',&lt;/div>
> &lt;div>'system management-interface configuration-mode model-driven']&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Execute Script.&lt;/div>
> &lt;div>send_cmmdz(sros_conn, enableNetconf)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Validate NETCONF is enabled and Operational.&lt;/div>
> &lt;div>send_single(sros_conn,'show system netconf')&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Disconnect from the SSH Connection to our far-end remote device.&lt;/div>
> &lt;div># We need to disconnect to open the pipe for python3 to establish netconf connection.&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>disconnect(sros_conn)&lt;/div>
> &lt;div>time.sleep(2)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>try:&lt;/div>
> &lt;div># Now let's connect to the device via NETCONF and pull the config to validate.&lt;/div>
> &lt;div>nc = netconfconn(args, NETCONF_USER, NETCONF_PASS)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Grab the running configuration on our device, as an NCElement.&lt;/div>
> &lt;div>config = nc.get_config(source='running')&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># XML elemnent as a str.&lt;/div>
> &lt;div>xmlconfig = to_xml(config.xpath('data')[0])&lt;/div>
> &lt;div># Write the running configuration to a temp-file (from the data/configure xpath).&lt;/div>
> &lt;div>saveFile('temp-config.xml', xmlconfig)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div># Lets open the XML file, read it, and convert to a python dictionary and extract some info.&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>withopen('temp-config.xml', 'r') as temp:&lt;/div>
> &lt;div>content = temp.read()&lt;/div>
> &lt;div>xml = xmltodict.parse(content)&lt;/div>
> &lt;div>sys_name = xml['data']['configure']['system']['name']&lt;/div>
> &lt;div>createFolder('Configs')&lt;/div>
> &lt;div>saveFile(f"Configs/{sys_name}.txt", xmlconfig)&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>exceptExceptionas e:&lt;/div>
> &lt;div>print(f"Issue with NETCONF connection, {e}")&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>&lt;/div>
> &lt;div>if __name__ == "__main__":&lt;/div>
> &lt;div>main()</code>
>   </div>
> </div>
