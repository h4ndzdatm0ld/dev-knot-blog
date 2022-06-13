---
title: "Nokia: Service Router – Default Originate Replica (Cisco BGP Command)"
author: Hugo Tinoco
type: post
draft: false
date: 2019-01-28T14:56:48+00:00
url: /2019/01/28/nokia-service-router-default-originate-replica-cisco-bgp-command/
timeline_notification:
  - 1548687412
categories:
  - Networking
---

A simple overview on how to re-create the Cisco BGP &#8216;default-originate&#8217; command for a default route advertisement from a Nokia Service Provider perspective (IPv4/IPv6.)

There are several ways to advertise a default route in the Cisco environment &#8211; here is a quick summary:

1. The first option is what we will attempt to replicate from a Nokia Service Router perspective. Advertising a default route PER BGP Peer instance. This is a more controlled way of advertising.
   &#8216;neighbor X.Y.X.Y default-originate&#8217; Again, this doesn&#8217;t require an active default route to be present or redistributed. This will generate and propagate to the specified neighbor only.
2. Adding a &#8220;network 0.0.0.0&#8221; command under the address family for your BGP routing instance to advertise to ALL neighbors. Remember: This requires an present /0 route in the FIB.
3. Redistribution &#8211; from a currently active default route in the routing table of an IGP. Hence, redistribute &#8211; (Almost the same as option 2)
4. &#8220;Default-information originate&#8221; &#8211; This command will GENERATE a default route to ALL BGP neighbors under the family. An active default route is NOT required to be present under another routing instance in order to propagate the new default route to all BGP peers

&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8211;

The topology will be a Cisco edge device dual-homed to a Nokia PE devices from ISP XYZ. NOTE: There is currently no route map prepending the AS, but we are load balancing.

&nbsp;

The topology will be a Cisco edge device dual-homed to a Nokia PE devices from ISP XYZ. NOTE: There is currently no route map prepending the AS, but we are load balancing.

<img loading="lazy" class="alignnone  wp-image-26" src="http://localhost:8000/wp-content/uploads/2019/01/topology-1.png" alt="topology" width="430" height="378" srcset="http://localhost:8000/wp-content/uploads/2019/01/topology-1.png 663w, http://localhost:8000/wp-content/uploads/2019/01/topology-1-300x264.png 300w" sizes="(max-width: 430px) 100vw, 430px" />

Here is the configuration from the Cisco Edge Device (CustomerSiteB):

<img loading="lazy" class="alignnone  wp-image-27" src="http://localhost:8000/wp-content/uploads/2019/01/capture.png" alt="Capture.PNG" width="436" height="233" srcset="http://localhost:8000/wp-content/uploads/2019/01/capture.png 915w, http://localhost:8000/wp-content/uploads/2019/01/capture-300x160.png 300w, http://localhost:8000/wp-content/uploads/2019/01/capture-768x410.png 768w" sizes="(max-width: 436px) 100vw, 436px" />

_Not much in configuration. Standard BGP session to an ISP (without authentication)  &#8211; **Note** the **BFD** configuration for the peers for_ a fast _failover. Will do a blog post about this in the upcoming weeks, which I will demonstrate the **fast-external-**\_fallover \_command as well._

Currently, we are not learning any BGP routes from our ISP.  Here is the configuration from the Nokia PE devices R5/R6.  (Only showing one side, as they are extremely similar, with only varying subnets)

<img loading="lazy" class="alignnone  wp-image-28" src="http://localhost:8000/wp-content/uploads/2019/01/vprn.png" alt="vprn" width="422" height="345" srcset="http://localhost:8000/wp-content/uploads/2019/01/vprn.png 859w, http://localhost:8000/wp-content/uploads/2019/01/vprn-300x246.png 300w, http://localhost:8000/wp-content/uploads/2019/01/vprn-768x629.png 768w" sizes="(max-width: 422px) 100vw, 422px" />

Creating a **Prefix-List:**

Lets begin the process to simulate the default-route advertisement.

_**Note: add**_ prefix :_**:/0 exact for IPv6 & family ipv6 under the policy statement.**_

We&#8217;ll start by configuring a prefix list on our PE devices (R5/R6):**<img loading="lazy" class="alignnone  wp-image-29" src="http://localhost:8000/wp-content/uploads/2019/01/pflist.png" alt="pflist.PNG" width="420" height="74" srcset="http://localhost:8000/wp-content/uploads/2019/01/pflist.png 801w, http://localhost:8000/wp-content/uploads/2019/01/pflist-300x53.png 300w, http://localhost:8000/wp-content/uploads/2019/01/pflist-768x135.png 768w" sizes="(max-width: 420px) 100vw, 420px" />**

Next, we create a **Policy Statement:**

<img loading="lazy" class="alignnone  wp-image-30" src="http://localhost:8000/wp-content/uploads/2019/01/default.png" alt="default.PNG" width="415" height="215" srcset="http://localhost:8000/wp-content/uploads/2019/01/default.png 815w, http://localhost:8000/wp-content/uploads/2019/01/default-300x155.png 300w, http://localhost:8000/wp-content/uploads/2019/01/default-768x397.png 768w" sizes="(max-width: 415px) 100vw, 415px" />

**_Make sure to COMMIT the changes!_**

**Adding the policy statement under the BGP configuration inside the VRFs.**

/configure service vprn 100 <span style="color:#ff0000;"># Example VRF</span>

- <span style="color:#ff0000;">#Create a Black Hole/ Null Route to discard any unwanted/un-routable traffic.</span>
  **static-route ::/0 black-hole**
  **static-route 0.0.0.0/0 black-hole**

Add the new &#8220;**Default Originate&#8221; policy statement we created earlier to the the BGP Group of your customer as an export statement.**

<img loading="lazy" class="alignnone  wp-image-31" src="http://localhost:8000/wp-content/uploads/2019/01/export.png" alt="export.PNG" width="412" height="273" srcset="http://localhost:8000/wp-content/uploads/2019/01/export.png 889w, http://localhost:8000/wp-content/uploads/2019/01/export-300x199.png 300w, http://localhost:8000/wp-content/uploads/2019/01/export-768x509.png 768w" sizes="(max-width: 412px) 100vw, 412px" />

At this point we should be advertising ONLY a default route to our BGP neighbor.

From our PE device, a quick &#8220;show router 100 bgp neighbor 175.175.1.2 advertised-route&#8221; will display the following:

<img loading="lazy" class="alignnone  wp-image-32" src="http://localhost:8000/wp-content/uploads/2019/01/advertised.png" alt="advertised.PNG" width="442" height="111" srcset="http://localhost:8000/wp-content/uploads/2019/01/advertised.png 1299w, http://localhost:8000/wp-content/uploads/2019/01/advertised-300x76.png 300w, http://localhost:8000/wp-content/uploads/2019/01/advertised-1024x258.png 1024w, http://localhost:8000/wp-content/uploads/2019/01/advertised-768x193.png 768w" sizes="(max-width: 442px) 100vw, 442px" />

I will go ahead and replicate this policy statement on both VPRN&#8217;s on R5/R6 &#8211; Our Nokia PE devices for the Dual-Homed BGP Customer and apply the export statement to the BGP peer.

A look at &#8220;show ip route bgp&#8221; on the CustomerSiteB Cisco edge device shows us the two paths (thanks to the the load balancing, &#8216;maximum-paths 2&#8217; configuration):

<img loading="lazy" class="alignnone  wp-image-33" src="http://localhost:8000/wp-content/uploads/2019/01/ecmp.png" alt="ecmp.PNG" width="508" height="59" srcset="http://localhost:8000/wp-content/uploads/2019/01/ecmp.png 853w, http://localhost:8000/wp-content/uploads/2019/01/ecmp-300x35.png 300w, http://localhost:8000/wp-content/uploads/2019/01/ecmp-768x89.png 768w" sizes="(max-width: 508px) 100vw, 508px" />

Now we are learning a default route from both uplinks to our dual-homed ISP connection. Failover should be seamless at this point, although having two default routes is prob not what you want &#8211; this is a simple example of how to accomplish a default-originate command, which doesn&#8217;t exist on the Nokia environment.
