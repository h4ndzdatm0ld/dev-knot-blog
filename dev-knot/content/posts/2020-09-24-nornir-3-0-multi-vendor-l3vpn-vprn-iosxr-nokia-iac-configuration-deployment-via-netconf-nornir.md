---
title: Nornir 3.0 – Multi-Vendor L3VPN/VPRN (IOSxR/Nokia) IaC – Configuration Deployment via NETCONF/NORNIR
author: Hugo Tinoco
type: post
draft: False
date: 2020-09-24T16:31:22+00:00
url: /2020/09/24/nornir-3-0-multi-vendor-l3vpn-vprn-iosxr-nokia-iac-configuration-deployment-via-netconf-nornir/
featured_image: /wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm.png
timeline_notification:
  - 1600965085
categories:
  - Uncategorized
---

What a title to this post, right?

With the recent release of Nornir 3.0  &#8211; I wanted to explore the capabilities of Nornir and I already know, I will prob never use Ansible for Network Automation ever again.. 😉 However, the reason for this post is to give a high level overview of Nornir 3.0 and provide a guide to convert 2.x Nornir/Netconf scripts over to 3.0.

Some of the topics explored in this post will include but not limited to the following:

1. Infrastructure as Code : (Jinja2 Template Rendering and YAML defined network state)
2. Nornir 3.0.
   1. Installation
   2. Plugins
   3. Directory Structure
3. NETCONF/YANG
4. Netmiko

## How to Follow Along

I&#8217;d recommed to download the code from my github and review the repo. Once you are familiar with the code you should be ready to start reading along.

### <span style="color:#ff0000;">CODE:</span>

## <https://github.com/h4ndzdatm0ld/Norconf>

Review the topology below: You will become the operator of this network throughout this journey. The solution you are implementing will ease the workload of the deployment engineers and possibly save your company some money. Depending on the issue that XYZ company is trying to solve, it&#8217;s becoming clear that not every one requires a high dollar solution to automate their networks with vendor specific nms, orchestrators, etc.<img loading="lazy" class="alignnone size-full wp-image-180" src="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm.png" alt="Screen Shot 2020-09-21 at 3.58.38 PM" width="1696" height="1462" srcset="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm.png 1696w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-300x259.png 300w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-1024x883.png 1024w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-768x662.png 768w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-1536x1324.png 1536w" sizes="(max-width: 1696px) 100vw, 1696px" />

For those of you new to Nornir, it&#8217;s an automation framework written in Python.  If you are familiar with Ansible, you can adapt quite easily to Nornir as long as you know how to get around with python. You will quickly realize how flexible it is. One of my favorite features of Nornir is multithreading, allowing concurrent connections which in return makes this framework incredibly fast. We will discuss the topic of workers/threads a little more later in this post.

## Getting Started

Begin by installing nornir with a simple **pip3 install nornir **

Lets discuss the directory structure. You can see here there is quite a bit going on..

<span style="color:#ff0000;"><strong>NOTE</strong>: All of the following files/directories have to manually be created. These are not autocreated. Take a minute and re-create the folders/files under a chosen filepath. I started a git repo and this is where I created all my folders.</span>

We&#8217;ve created a **defaults**, **groups** and **hosts** yml file under our &#8216;**inventory**&#8216; directory. We actually have a **config**.yml file which specifies the path location of these files<img loading="lazy" class="  wp-image-183 alignleft" style="color:var(--color-text);" src="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-9.37.12-am.png" alt="Screen Shot 2020-09-22 at 9.37.12 AM" width="251" height="323" srcset="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-9.37.12-am.png 520w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-9.37.12-am-233x300.png 233w" sizes="(max-width: 251px) 100vw, 251px" /><span style="color:var(--color-text);">. This config file is later passed into the nornir class that&#8217;s instantiated inside our python runbook, norconf.py. As always, our &#8216;</span><strong style="color:var(--color-text);">templates</strong><span style="color:var(--color-text);">&#8216; folder contains our Jinja2 files with the appropriate template files to render the configuration of the L3VPN and VPRNs for our multivendor environment. These are named according to their corresponding host platform and function.</span>

<span style="color:var(--color-text);"><strong>Template Naming Example:</strong></span>

<li style="list-style-type:none;">
  <ul>
    <li style="list-style-type:none;">
      <ul>
        <li style="list-style-type:none;">
          <ul>
            <li style="list-style-type:none;">
              <ul>
                <li style="list-style-type:none;">
                  <ul>
                    <li style="list-style-type:none;">
                      <ul>
                        <li>
                          <span style="color:var(--color-text);">{iosxr}-(platform) -{vrf}-(purpose)-.j2 (extension). The actual template is XML data following yang models.  The reason to use the platform in the naming scheme, is to be able to use the host platform during our program execution and match the name of the file with the help of f strings. This is just one way to do it and you can find other ways that make more sense to your deployment.</span>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </li>
              </ul>
            </li>
          </ul>
        </li>
      </ul>
    </li>
  </ul>
</li>

Additional files in here, such as nc_tasks.py are adopted from Nick Russos project which uses nornir 2.X. He&#8217;s configured some custom netconf tasks at a time in which netconf was originally being introduced into Nornir. The Log file is self explanatory.

At the time of this writing, the nornir_netconf plugin is not yet available for Nornir 3.0 as a direct pip dowload/install.  What I have done is a series of try/except and mostly failures to get this to work. I had to take a step back and understand a lot of what&#8217;s happening under the hood of nornir.  I&#8217;ve cloned the REPO @ <https://github.com/nornir-automation/nornir_netconf@first> and tried to install it via Poetry, but this was mostly a huge waste of time and nothing worked, particularly with the plugin configuration of Nornir. I removed the installation and went the pip route straight from git.

I was able to install the the code by using pip + git using the following:

> pip3 install git+https://github.com/nornir-automation/nornir_netconf@first

However, during the process I got an exception &#8220;AttributeError: module &#8216;enum&#8217; has no attribute &#8216;IntFlag'&#8221; From some searching around, it&#8217;s due to a discrepency with using enum34. I ran the following to ensure the package was present and removed it.

> **pip freeze | grep enum34**
>
> ➜ nornir_netconf-first pip3 freeze | grep enum34
> enum34==1.1.10

Looks like I do have it in installed &#8230;  A quick, &#8216;pip3 uninstall enum34&#8217; and re-ran the original pip3 install from git+git_page and the installation was successfull. I wonder what I broke by removing enum34 😉

> Installing collected packages: nornir-netconf
> Successfully installed nornir-netconf-1.0.0
>
> Python 3.8.2 (v3.8.2:7b3ab5921f, Feb 24 2020, 17:52:18)
> [Clang 6.0 (clang-600.0.57)] on darwin
> Type &#8220;help&#8221;, &#8220;copyright&#8221;, &#8220;credits&#8221; or &#8220;license&#8221; for more information.
> <span style="color:#ff0000;">>>> import nornir_netconf</span>
>
> > > > print(<span style="color:#ff0000;">SO FAR SO GOOD!)</span>

I was having an issue with nornir netconf plugin originally and had to investigate how to manually register a plugin. That is before I found out how to get around the hurdle and install via git+pip. Here is the code I used to manually register the plugin in my runbook directly, in case anyone ever wants to register a new plugin..although a lot has to happen for any of this to work.

<div>
  <blockquote>
    <div>
      from nornir.core.plugins.connections import ConnectionPluginRegister
    </div>

    <div>
      from nornir_netconf.plugins.connections import Netconf
    </div>

    <div>
      ConnectionPluginRegister.register(&#8220;netconf&#8221;, ConnectionPluginRegister)
    </div>

  </blockquote>

  <div>
    So, at this point &#8211; the netconf plugin is working.  The only problem I see with the nornir_netconf plugin is the returned output. After all this work, I realized if you do a print_result, to extract all the output &#8211; you don&#8217;t exactly get what you need to verify the sucess of the rpc-operation, such as the rpc_reply. This is a little troublesome. However, I did find that the custom netconf function written by Nick Russo gave me exactly what I need. At this time, I will not be using the nornir_netconf methods and instead import the custom russo tasks. See below:
  </div>
</div>

&nbsp;

https://gist.github.com/h4ndzdatm0ld/759161287434cdb4e464884c41309710

<span style="color:var(--color-text);">Importing this function, I am actually able to receive this rpc_reply from a successfull RPC operation. This is critical to the operation of my script &#8211; as I write conditional statements depending on the returning output of the tasks.run result. </span>

> <div>
>   <?xml version=&#8221;1.0&#8243;?><br /> <rpc-reply message-id=&#8221;urn:uuid:28f57844-94cb-4ecc-b927-ba1f5318eab7&#8243; xmlns:nc=&#8221;urn:ietf:params:xml:ns:netconf:base:1.0&#8243; xmlns=&#8221;urn:ietf:params:xml:ns:netconf:base:1.0&#8243;>
> </div>
>
> <div>
>   <ok/><br /> </rpc-reply>
> </div>

<div>
  During the time of this writing I did express my concern on the lack of response from this edit_config function on the soon to be introduced nornir_netconf plugin to Patrick Ogenstad who is leading the development of the netconf plugin. Sounds like he may be updating the code to actually return rpc reply in the output, more to come on that. As of now, I will continue with Russo&#8217;s custom function as I see this being a requirement for any netconf python script to properply acknowledge the result. Additionally, his nc_tasks.py file contains a netconf_commit function which is a necessity for applying configurations against candidate target stores.
</div>

<div>
</div>

<div>
  I treat NETCONF as an API. I need a response and I need a response NOW! 😉
</div>

<div>
</div>

<div>
  Okay, enough about getting NETCONF to work on this new Nornir version.
</div>

<div>
</div>

<div>
  Lets go over the inventory directory and the defaults, groups and hosts file.
</div>

<div>
</div>

## The Host File:

> <div>
>   <div>
>     <div>
>       &#8212;
>     </div>
>
>     <div>
>       <strong>R3_CSR</strong>:
>     </div>
>
>     <div>
>       hostname: 192.168.0.223
>     </div>
>
>     <div>
>       groups:
>     </div>
>
>     <div>
>         &#8211; CSR
>     </div>
>
>     <div>
>       <strong>R3_SROS_PE:</strong>
>     </div>
>
>     <div>
>       hostname: 192.168.0.222
>     </div>
>
>     <div>
>       groups:
>     </div>
>
>     <div>
>         &#8211; NOKIA
>     </div>
>
>     <div>
>       data:
>     </div>
>
>     <div>
>         region: west-region
>     </div>
>
>     <div>
>       <strong>R8_IOSXR_PE:</strong>
>     </div>
>
>     <div>
>       hostname: 192.168.0.182
>     </div>
>
>     <div>
>       groups:
>     </div>
>
>     <div>
>         &#8211; IOSXR
>     </div>
>
>     <div>
>       data:
>     </div>
>
>     <div>
>         region: west-region
>     </div>
>
>   </div>
> </div>

<div>
  A simple yaml file that looks very familiar.. this should be an easy transition for all the Ansible folks. You define a host, hostname and specify a group to avoid duplication of data.
</div>

<div>
</div>

<div>
  This is an example of the groups file &#8211; The inheritance from the group file is passed straight to each host that&#8217;s part of the group. If there is data inside the defaults yaml file, this is also inherited to all hosts. Something to keep in mind.
</div>

## The Group File

<div>
  <img loading="lazy" class="  wp-image-186 alignleft" src="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-12.23.32-pm.png" alt="Screen Shot 2020-09-22 at 12.23.32 PM" width="296" height="663" srcset="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-12.23.32-pm.png 546w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-12.23.32-pm-134x300.png 134w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-12.23.32-pm-458x1024.png 458w" sizes="(max-width: 296px) 100vw, 296px" />
</div>

<div>
  <span style="color:#ff0000;"><strong>NOTE</strong>:</span>
</div>

<div>
</div>

- <span style="color:#ff0000;">The  data.target key is inherited and called upon during the execution of rpc-edit config to point the operation against the correct netconf data store)</span>
- <span style="color:#ff0000;">These connection options can make or break the process</span>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

<div>
</div>

## The Config File

- **A config.yaml file must specify the location of the hosts, groups and defaults fiiles.**

<div>
  <img loading="lazy" class="alignnone  wp-image-187" src="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-2.10.34-pm.png" alt="Screen Shot 2020-09-22 at 2.10.34 PM" width="395" height="276" srcset="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-2.10.34-pm.png 684w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-22-at-2.10.34-pm-300x210.png 300w" sizes="(max-width: 395px) 100vw, 395px" />
</div>

<div>
</div>

## Threads

We have specified 100 num_workers, which really means we can have up to 100 concurrent multithreaded sessions to devices.  The way I think about Nornir running process is everything you&#8217;re doing is in a giant &#8216;for loop&#8217;. The tasks runs through all the devices in the inventory (unless you specify a filter) one by one.  Although there isn&#8217;t a for statement written anywhere visible, you&#8217;re looping through all the devices in your inventory. However, using threads you&#8217;re actually doing this is parallel.  You could technically specify the &#8216;plugin: serial&#8217; and not take advantage of threads.

## Plugins

<div>
</div>

<div>
  Before we move forward and begin writing our runbook/code &#8211; one thing I want to emphasize is the difference in Nornir 2.x and 3.x.  You must individually install the plugins! Here is a link to the current Nornir Plugins available and documentation/how &#8211; to from Nornir.
</div>

<div>
</div>

<div>
  <a href="https://nornir.tech/nornir/plugins/">https://nornir.tech/nornir/plugins/</a>
</div>

<div>
</div>

<div>
  <a href="https://nornir.readthedocs.io/en/latest/plugins/">https://nornir.readthedocs.io/en/latest/plugins/</a>
</div>

<div>
</div>

<div>
  This part is incredibly important, as the power of Nornir is basically to become a sort of orchestartor and controller of these tasks which include running code that take advantage of these plugins. In our code we will use load_yaml, template_file, netmiko and the nornir_utils.
</div>

<div>
</div>

> <div>
>   pip3 install nornir_utils
> </div>
>
> <div>
>   pip3 install nornir_netmiko
> </div>
>
> <div>
>   pip3 install nornir_jinja2
> </div>

## Run Book (Python Script of Compiled &#8216;tasks&#8217;)

<div>
  As we begin writing our runbook for our project, lets instantiate the <strong>InitNornir</strong> class and pass in the custom config.yml file:
</div>

> <div>
>   <div>
>     <div>
>       from nornir import InitNornir
>     </div>
>
>     <div>
>       from nornir_netmiko.tasks import netmiko_send_command
>     </div>
>
>     <div>
>       from nornir_utils.plugins.functions import print_result
>     </div>
>
>     <div>
>       from nornir_utils.plugins.tasks.data import load_yaml
>     </div>
>
>     <div>
>       from nornir_jinja2.plugins.tasks import template_file
>     </div>
>
>     <div>
>       from nornir_netconf.plugins.tasks import netconf_edit_config
>     </div>
>
>     <div>
>       from nc_tasks import netconf_edit_config, netconf_commit
>     </div>
>
>     <div>
>       import xmltodict, json, pprint
>     </div>
>
>     <div>
>       __author__ = &#8216;Hugo Tinoco&#8217;
>     </div>
>
>     <div>
>       __email__ = &#8216;hugotinoco@icloud.com&#8217;
>     </div>
>
>     <div>
>       <strong># Specify a custom config yaml file.</strong>
>     </div>
>
>     <div>
>
>     </div>
>
>     <div>
>       <strong>nr = InitNornir(&#8216;<span style="color:#ff0000;">config.yml</span>&#8216;)</strong>
>     </div>
>
>   </div>
> </div>

<div>
</div>

## Filters

##<img loading="lazy" class="alignnone size-full wp-image-180" style="color:var(--color-text);font-size:16px;font-weight:400;" src="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm.png" alt="Screen Shot 2020-09-21 at 3.58.38 PM" width="1696" height="1462" srcset="http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm.png 1696w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-300x259.png 300w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-1024x883.png 1024w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-768x662.png 768w, http://localhost:8000/wp-content/uploads/2020/09/screen-shot-2020-09-21-at-3.58.38-pm-1536x1324.png 1536w" sizes="(max-width: 1696px) 100vw, 1696px" />

What are filters and how do we create them? A filter is a selection of hosts in which you want to execute a runbook against. For our main example in this post, we are an operator who is in charge of deploying a L3VPN/VPRN in a multi-vendor environemnt at the core. This will include Nokia SR 7750 and Cisco IOSxR. However, our hosts file contains ALL of our devices that are available in our network. The L3VPN we are deploying is only spanning across our &#8216;west-region&#8217; pictured on the bottom left of the topology above. There are two CPE&#8217;s, one attached to the Nokia 7750 and one to the Cisco IOSxR. In order to deploy this service, we want to specify within Nornir that we only need to execute the tasks against these two specific routers. The rest of the network doesn&#8217;t need to know about this service.  Below is a snippet of the &#8216;hosts.yml&#8217; file which has customized region key and west-region item. You can see this is duplicated to the R8_IOSXR_PE device.  That&#8217;s it! We&#8217;ve identified common ground between these devices, being in the &#8216;west-region&#8217; of our network.

> <div>
>   <strong>R3_SROS_PE:</strong>
> </div>
>
> <div>
>   hostname: 192.168.0.222
> </div>
>
> <div>
>   groups:
> </div>
>
> <div>
>     &#8211; NOKIA
> </div>
>
> <div>
>   data:
> </div>
>
> <div>
>     region: west-region
> </div>
>
> <div>
>
> </div>
>
> <div>
>   <strong>R8_IOSXR_PE:</strong>
> </div>
>
> <div>
>   hostname: 192.168.0.182
> </div>
>
> <div>
>   groups:
> </div>
>
> <div>
>     &#8211; IOSXR
> </div>
>
> <div>
>   data:
> </div>
>
> <div>
>     region: west-region
> </div>

Now lets write some code to ensure nornir knows this is a filter.

> <div>
>   <div>
>     <strong># Filter the hosts by the &#8216;west-region&#8217; site key.</strong>
>   </div>
>
>   <div>
>
>   </div>
>
>   <div>
>     <strong>west_region = nr.filter(region=&#8217;<span style="color:#ff0000;">west-region</span>&#8216;)</strong>
>   </div>
> </div>

<div>
  Wow, that was a lot.  This will come in handy once we are ready to execute the entire runbook in our main() function. Remember, the west-region is specified in the hosts file. This could also be inherited from the group file, if the hosts belongs to said group.
</div>

<div>
</div>

## Infrastructure as Code

We&#8217;ll be extracting information from our Yaml files which are variables inputted by the user along side our Jinja2 templates consisting of our Yang Models. We use Jinja2 to distribute the correct variables across our yang models for proper rendering. For distributing  the configurations via NETCONF across our core network we enlist the help of Nornir to manage all of theses tasks. We&#8217;re allowing Nornir to handle the flow and procedures to ensure proper deployment.

## VARS

Below is the yaml file containing our vars which will be utilized to render the j2 template.  The following is for the Nokia platform:

> <div>
>   <div>
>     &#8212;
>   </div>
>
>   <div>
>     VRF:
>   </div>
>
>   <div>
>       &#8211; SERVICE_NAME: AVIFI
>   </div>
>
>   <div>
>         SERVICE_ID: &#8216;100&#8217;
>   </div>
>
>   <div>
>          CUSTOMER_ID: 200
>   </div>
>
>   <div>
>         CUSTOMER_NAME: AVIFI-CO
>   </div>
>
>   <div>
>         DESCRIPTION: AVIFI-CO
>   </div>
>
>   <div>
>         ASN: &#8216;64500&#8217;
>   </div>
>
>   <div>
>         RD: 100
>   </div>
>
>   <div>
>         RT: 100
>   </div>
>
>   <div>
>         INTERFACE_NAME: TEST-LOOPBACK
>   </div>
>
>   <div>
>         INTERFACE_ADDRESS: 3.3.3.3
>   </div>
>
>   <div>
>         INTERFACE_PREFIX: 32
>   </div>
> </div>

<div>
  If you are not familiar with how a L3VPN works, this is the time you can review this topic. In order to properly configure a L3VPN service for your customer, you must provide a service name for your VRF. In the Nokia/SROS world, you must also provide a customer_id, which is passed into the creation of the service for the specific customer. A customer name is also passed into the vars file as you want to specify the name of the customer not just a numerical value(id). The Autonomous system is a requirement for the VRF, along side the route-target and route-distinguisher.  Additionally, we will be creating a loopback interface within the VRF for testing purposes. The goal here is not only to deploy the service but to validate L3 Connectivity across the core via Multi-Protocol BGP (MP-BGP). MPLS has already been configured in the core.
</div>

<div>
</div>

## Jinja 2 &#8211; yang:sr:conf

There are so many important pieces to construct this automation project. The J2 template file, must include everything that is necessary to create this service. Below is the example for the Nokia device. Please see my code via the github repo at the top of this document to review the IOSxR J2 Template file. There are also supporting documents at the end of this document if you need more information on Jinja2

https://gist.github.com/h4ndzdatm0ld/6735855049104432ffbf0169ba53a660

## Runbook Walkthrough

https://gist.github.com/h4ndzdatm0ld/9f7975fa6a49d7815adb70975498d41b

Our overall goal is to deploy the VPRN/L3VPN. We start by creating a few custom functions.

We create **get_vrfcli and get_vprncli**. These two functions take advantage of **netmiko_send_command plugin** and are using platform specific cli commands. We will use these two commands to retrieve the service status. Then we take the two functions and wrap them inside **cli_stats**.  We load the yaml file using the **load_yaml plugin** from Nornir. Once the task is executed, we drill into our vars file and extract the service name as a variable from our loaded dictionary (yaml file). This variable is then passed into the get_vrpncli/get_vrfcli functions to execute against our devices. At this point, if we execute the cli_stats tasks against our west-region, we can use conditional statements to execute the correct command against the correct platform device. The way in which we access the platform, is by simply digging into the task.host.platform key. This will return the value of the key.

<span style="color:#ff0000;"><strong>NOTE:</strong> </span>

I am working on a video tutorial and demonstration of Nornir 3.0. During the video, I will create additional tasks in which verify the L3 Connectivity via simple ping commands.

## Bulk of the Code:

https://gist.github.com/h4ndzdatm0ld/f9942cf65ba73c99b49c91d9c8a9609a

&nbsp;

Lets review the i**ac_render** function. We simply load our yaml vars and render our j2 templates. Special attention to the following:

<table class="highlight tab-size js-file-line-container">
  <tr>
    <td id="file-gistfile1-txt-LC10" class="blob-code blob-code-inner js-file-line">
      template= f&#8221;{task.host.platform}-vrf.j2&#8243;
    </td>
  </tr>

  <tr>
    <td id="file-gistfile1-txt-L11" class="blob-num js-line-number">
      This allows us to properly select a template that matches the host during the execution of the task. Using our f-strings, we pass in the task.host.platform and append the &#8216;-vrf&#8217; which in turn matches the name of our stored xml templates inside our templates directory. Example: &#8220;iosxr-vrf.j2&#8221;
    </td>
  </tr>
</table>

At this point we have our payload to deploy against our devices. One thing to note, the result of the rendered template using the nornir plugin, template_file is a Nornir Class. <span style="text-decoration:underline;">Make sure this gets converted to a str:</span> &#8220;payload = str(vprn.result)&#8221;. We will pass this into our **netconf_edit_config** task as the payload to deploy via netconf.

> deploy_config = task.run(task=netconf_edit_config, target=task.host[&#8216;target&#8217;],             config=payload)

Lets examine this line of code. We assign &#8216;**deploy_config&#8217;** as the variable for the returning output of our task. The task we will execute is the &#8216;**netconf_edit_config**&#8216; function. Again, this is a wrapper of **ncclient**, which I hope you&#8217;re familiar with &#8211; if not, please give it a google search or review the additional resources at the bottom of the doc.
Now, the&#8217; target=task.host[&#8216;target&#8217;]&#8217; is the data store to use during our rpc NETCONF call. We specified this for our host inside our groups file. See below:

NOKIA:
username: &#8216;admin&#8217;
password: &#8216;admin&#8217;
platform: alcatel_sros
port: 22
data:
<span style="color:#ff0000;">    target: candidate </span>

NETCONF has three data stores in which we can execute configuration changes against.

1.  Running
2.  Startup
3.  Candidate

In my opinion, candidate is the most valuable operation. We are able to input a config change, validate and once we are sure of the changes we must commit the change. As the operator of this network, we must be sure not to cause any outages or create any rippling effects from our automation. We will insepct the RPC reply and ensure all is good and if so, we will commmit out changes for the customer.

Line 23, has a conditional statement where we dig into the actual platform of the hosts that&#8217;s running within our task. We simply compare it to alcatel_sros or iosxr, as those are our two core devices in this example. We extract a couple different items in the result of our loaded yaml file which we will use to return some output to the screen and provide results in a readable format. We do the same with our iosxr results.

At this point, the **netconf_edit_config** wrapper for ncclient should have executed the netconf rpc and editted the configuration.

We store the reply in a variable called rpcreply, by extracting the .result attribute out of our original deploy_config variable. This gives us the xml reply and we can check the result of the reply by using &#8216;if rpcreply.ok:&#8217;

Line 42 gives us a simple feedback to let us know the result has returned OK. We now run the **netconf_commit**  task and confirm the change.

Finally, lets validate some of the services applied and use our custom function **&#8216;nc_getvprn&#8217;** against our Nokia 7750.

> nc_getvprn(task, serviceid=serviceid, servicename=servicename,   customerid=customerid)

Earlier, we extrracted some vars from our yaml file and loaded them into script as the following: &#8216;serviceid&#8217;, &#8216;servicename&#8217; and &#8216;customerid&#8217;. We use these variables to execute the task and get some information by parsing the result of the **netconf_get_config** rpc call. We process this information by using **xmltodict.parse** and converting the xml to a Python dictionary. We compare the values found inside our running configuration against the desired state of our network element. Infrastructue as code is fun right? Once we do some comparasion of our items, we return meaningful output to the screen to let us, the operator know that everything is configured as expected.

If you are not familiar with xmltodict, I will provide additional references at the bottom of this document.

At the time of this writing I only have completed the compliance check against the Nokia sros device. I will most likley be extending this code to do the same against the IOSxR device. Below is the customer &#8216;nc_getvprn&#8221; function which we just described.

&nbsp;

## Execution

https://gist.github.com/h4ndzdatm0ld/160ff829b3fd3ffb09e3c29334315588

It&#8217;s that easy. We run our tasks against our filter, west_region to narrow down our hosts for our multi-vendor environment. Lets review the output!

https://gist.github.com/h4ndzdatm0ld/94e2019c6cb79246c48af70bbd4ec701

From the output above, we deployed our L3VPN (IOSxR) and VPRN (NOKIA) device. After we take full advantage of our IaC+Nornir, we return back to our CLI Scraping automation and rely on Netmiko to run simple show commands to view the VRF is actually present and validate the services.

## Additional Resources:

[Kirk Byers Nornir 3.0 Docs][1]

[Jinja 2 &#8211; Render Templates][2]

[NETCONF &#8211; ncclient (Github)][3]

[XMLTODICT][4]

[1]: https://github.com/twin-bridges/nornir_course/blob/master/nornir3_changes.md?__s=bqzu9wzbekhnsuqbiqz4
[2]: https://blogs.cisco.com/developer/network-configuration-template
[3]: https://github.com/ncclient/ncclient
[4]: https://docs.python-guide.org/scenarios/xml/
