---
title: "Nornir 3.0 – ::NETCONF:: Config Backup – XML/Jz0n"
author: Hugo Tinoco
type: post
draft: False
date: 2020-10-02T13:17:00+00:00
url: /2020/10/02/nornir-3-0-netconf-config-backup-xml-jz0n/
featured_image: /wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm.png
timeline_notification:
  - 1601645187
categories:
  - Uncategorized
tags:
  - json
  - network automation
  - nornir
  - xml
---

First things first: Review the code:

**Code**: <a rel="noreferrer noopener" href="https://github.com/h4ndzdatm0ld/nornir3-netconf-backup" target="_blank">https://github.com/h4ndzdatm0ld/nornir3-netconf-backup</a>

The goal of this walkthrough is to backup configuration files from NETCONF enabled devices. Thanks to the flexibility of python, we have the choice to either back up the files as JSON or XML.. We will use the **nornir_utils,** &#8216;**write_file&#8217;** plugin which is now decoupled from Nornir (for those of you used to Nornir 2.x).

Ensure you have this plugin available, by installing it via pip:

<div class="wp-block-syntaxhighlighter-code ">
  <pre class="brush: plain; title: ; notranslate" title="">
pip3 install nornir_utils
</pre>
</div>

Lets inspect our host file and rely on a custom data k, v: **&#8216;operation: netconf-enabled&#8217;** to use as our Filter.

<pre class="wp-block-code"><code>R3_SROS_PE:
  hostname: 192.168.0.222
  groups:
    - NOKIA
  data:
    region: west-region
    operation: netconf-enabled

R8_IOSXR_PE:
  hostname: 192.168.0.182
  groups:
    - IOSXR
  data:
    region: west-region
    operation: netconf-enabled</code></pre>

Lets begin our Nornir 3.0 runbook: Pay close attention to our filter, as we pass in (operation=&#8221;netconf-enabled&#8221;) from above.

Also ensure the additional libraries being imported, such as xmltodict and json, etc.. are present and installed.

<pre class="wp-block-code"><code>from nornir import InitNornir
from nornir_utils.plugins.functions import print_result
import datetime, os, xmltodict, json, sys
from nornir_utils.plugins.tasks.files import write_file
from nornir_netconf.plugins.tasks import netconf_get_config

__author__ = "Hugo Tinoco"
__email__ = "hugotinoco@icloud.com"

# Specify a custom config yaml file.
nr = InitNornir("config.yml")

# Filter the hosts by the 'west-region' site key.
netconf_devices = nr.filter(operation="netconf-enabled")</code></pre>

A couple custom functions that we will take advantage of to assist us in creating directories and converting XML to JSON.

<pre class="wp-block-code"><code>def create_folder(directory):
    """Helper function to automatically generate directories"""
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print("Error: Creating directory. " + directory)


def xml2json(xmlconfig):
    """Simple function to conver the extract xml config and convert it to JSON str"""
    try:
        xml = xmltodict.parse(str(xmlconfig))
        return json.dumps(xml, indent=2)
    except Exception as e:
        print(f"Issue converting XML to JSON, {e}")</code></pre>

The **create_folder** function is a simple way to pass in a directory name and use the os library to create a new directory, if it&#8217;s not present. This is helpful as we will use this function to generate the &#8216;backup&#8217; folder in our code to store our configuration files.

**xml2json** function is exactly that. We take in a XML string and return it in JSON. <figure class="wp-block-image size-large">

<img loading="lazy" width="1350" height="1190" src="http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm.png?w=1024" alt="" class="wp-image-228" srcset="http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm.png 1350w, http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm-300x264.png 300w, http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm-1024x903.png 1024w, http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-2.01.09-pm-768x677.png 768w" sizes="(max-width: 1350px) 100vw, 1350px" /> </figure>

The Bulk of the code:

<pre class="wp-block-code"><code>def get_config(task, json_backup=False, xml_backup=False):
    """Use the get_config operation to retrieve the full xml config file from our device.
    If 'json_backup' set to True, the xml will be converted to JSON and backedup as well.
    """
    response = task.run(task=netconf_get_config)
    xmlconfig = response.result

    # Path to save output: This path will be auto-created for your below&gt;
    path = f"Backups/{task.host.platform}"

    if json_backup == False and xml_backup == False:
        sys.exit("JSON and XML are both set to False. Nothing to backup.")

    # Generate Directories:
    create_folder(path)

    # Generate Time.
    x = datetime.datetime.now()
    today = x.date()

    # If the 'True' Bool val is passed into the xml_config task function,
    # convert xml to json as well and backup.
    if json_backup == True:
        json_config = xml2json(xmlconfig)

        write_file(
            task, filename=f"{path}/{task.name}_{today}_JSON.txt", content=json_config
        )
    if xml_backup == True:
        write_file(
            task, filename=f"{path}/{task.name}_{today}_XML.txt", content=xmlconfig
        )


def main():

    netconf_devices.run(task=get_config, json_backup=True, xml_backup=True)


if __name__ == "__main__":
    main()
</code></pre>

Lets review. The **get_config** will take in the nornir task and have two boolean parameters which default to False, which are: XML backup and JSON backup. This allows us to specify if we want to backup the config in simple XML format, JSON format.. or both if you desire.

We start by extracting the config, using the nornir_netconf: netconf_get_config task. This retrieves the configuration and we extract the .result attribute and wrap it into a variable.

Now, we create a path as to where the files will be backed-up. We use f strings to format the directory structure: We specify a folder &#8216;Backups&#8221; followed by the platform of the device in which the current task is being executed against.

<pre class="wp-block-code"><code># Path to save output: This path will be auto-generated.
path = f"Backups/{task.host.platform}"

# Generate Directories:
create_folder(path)</code></pre>

We take this custom generated path and pass it in to our **create_folder** function and allow python to help us set up the directories.

One other thing to prepare for our file naming convention is a date to append at the end of the filename. Lets create a variable out of the datetime library and pass it in later on as we name our files.

<pre class="wp-block-code"><code>    # Generate Time.
    x = datetime.datetime.now()
    today = x.date()
</code></pre>

Finally, lets handle the boolean values and allow our program to make a decision on how to save the configuration (XML, JSON or both).

One thing to note, earlier in the code I added a system exception to exit the program if neither json_backup or xml_backup are set to True. There is no reason to execute and generate folders without a backup file to create and to place in the directories.

<pre class="wp-block-code"><code>   if json_backup == False and xml_backup == False:
        sys.exit("JSON and XML are both set to False. Nothing to backup.")</code></pre>

<pre class="wp-block-code"><code>    # If the 'True' Bool val is passed into the xml_config task function,
    # convert xml to json as well and backup.
    if json_backup == True:
        json_config = xml2json(xmlconfig)

        write_file(
            task, filename=f"{path}/{task.name}_{today}_JSON.txt", content=json_config
        )
    if xml_backup == True:
        write_file(
            task, filename=f"{path}/{task.name}_{today}_XML.txt", content=xmlconfig
        )</code></pre>

In the above code we take advantage of our **xml2json** custom function if we want to convert the retrieved XML config from our device and use our **write_file** Nornir Plugin to create and write the file. Something that&#8217;s also utilized from Nornir, is the task.host.name. _If we are strategic enough we can even use our task.name of the current task and use it to our advantage._ You can see we create the filename using f-strings and pass in the **task.host.name** alongside the **today** variable which was constructed earlier from the datetime library.

Execution:

The final result, depending on which format you chose to backup the configs will vary. In this demonstration, i&#8217;ve enabled both choices. See the tree directory below that was auto created for me and the **write_file** plugin from Nornir was helpful enough to save the configuration files. The Backups directory was generated, followed by the platform (task.host.platform) and finally the name of the file

filename = {task.host.name}\_{date}\_{XML_OR_JSON}<figure class="wp-block-image size-large is-resized">

<img loading="lazy" src="http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-7.55.32-pm.png?w=706" alt="" class="wp-image-240" width="580" height="506" srcset="http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-7.55.32-pm.png 706w, http://localhost:8000/wp-content/uploads/2020/10/screen-shot-2020-10-01-at-7.55.32-pm-300x262.png 300w" sizes="(max-width: 580px) 100vw, 580px" /> </figure>

There you have it! A simple way to take advantage of the Nornir 3.0 framework and create backups of all your NETCONF enabled devices in either XML or JSON format.
