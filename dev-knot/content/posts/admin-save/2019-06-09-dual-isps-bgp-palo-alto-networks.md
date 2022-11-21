---
title: Dual ISPs BGP – Palo Alto Networks
author: Hugo Tinoco
type: post
draft: false
date: 2019-06-09T10:13:30+00:00
url: /2019/06/09/dual-isps-bgp-palo-alto-networks/
timeline_notification:
  - 1560075851
categories:
  - Networking
---

&nbsp;

<figure id="attachment_61" aria-describedby="caption-attachment-61" style="width: 2061px" class="wp-caption alignnone"><img loading="lazy" class="alignnone size-full wp-image-61" src="http://localhost:8000/wp-content/uploads/2019/06/topology-1.png" alt="Topology" width="2061" height="997" srcset="http://localhost:8000/wp-content/uploads/2019/06/topology-1.png 2061w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-300x145.png 300w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-1024x495.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-768x372.png 768w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-1536x743.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-2048x991.png 2048w" sizes="(max-width: 2061px) 100vw, 2061px" /><figcaption id="caption-attachment-61" class="wp-caption-text">Network Topology</figcaption></figure>

&nbsp;

First things first! I passed the BGP Exam for the Nokia SRA Certification. I am now planning to deviate a bit and obtain my Sec+ and see where that takes me.. Anyways..

I&#8217;ve been very interested in Palo Alto Networks lately and I&#8217;m low-key starting to think about the certification path for PA.  I want to take some time and go over a Dual ISP connection utilizing a PA at the edge. I&#8217;m hoping to provide some insight from both a Service Provider  and Enterprise standpoint. The goal is to have a highly redundant WAN connection utilizing the PA.

Something I want to start keeping in mind:

<table id="table-as-numbers-2" class="sortable" style="height:113px;" width="565">
  <tr>
    <td align="center">
      64496 &#8211; 64511
    </td>

    <td>
      16 bit
    </td>

    <td>
      Reserved for use in documenation & sample code.
    </td>

    <td>
      [<a href="http://www.iana.org/go/rfc5398">RFC5398</a>]
    </td>
  </tr>
</table>

Topology:

ISP 1 ( AS 64511 ) will be adveritising a default-route via 172.16.65.0/31 interconnect with the PA on eth1/4.

ISP 2 ( AS 64496 ) will be adveritising a default-route via 172.16.64.0/31 interconnect with the PA on eth1/1.

The Enterprise LAN will be peering with the PA via iBGP on Gi0/0 and eth1/7 on the PA from Autonomous System 64500

&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-

From ISP 1 &#8211; a VPRN (VRF) 100 is configured, advertising a default-route.

From ISP 2 &#8211; a VPRN (VRF) 200 is configured, advertising a default-route.

Here is a snippet from the Nokia VRF that&#8217;s providing internet service connection to the Palo Alto. A similar configuration exisist on the ISP 1 router.

<img loading="lazy" class="alignnone  wp-image-65" src="http://localhost:8000/wp-content/uploads/2019/06/nokiabgp.png" alt="nokiabgp.PNG" width="393" height="368" srcset="http://localhost:8000/wp-content/uploads/2019/06/nokiabgp.png 614w, http://localhost:8000/wp-content/uploads/2019/06/nokiabgp-300x281.png 300w" sizes="(max-width: 393px) 100vw, 393px" />

<p style="text-align:justify;">
  &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-
</p>

From the Palo Alto &#8211; The initial steps to take are the following:

1. Create an &#8220;Untrust&#8221; zone. This zone will be facing the Internet (ISP1 & ISP2).

<span style="color:#008080;">Normally, I would suggest micro-segmenting these zones, but this requires a bit more policy creation. </span>Example <span style="color:#008080;">would be, 1 zone for ISP 1 and a different zone for ISP 2 for an absolute zero-trust architecture.</span>

2. Create a Management Profile which simply allows ICMP (pings) for troubleshooting and verification purposes.

Here is what the Layer 3 Interfaces look like:

<img loading="lazy" class="alignnone size-full wp-image-62" src="http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa.png" alt="interfaces-PA" width="2782" height="389" srcset="http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa.png 2782w, http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa-300x42.png 300w, http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa-1024x143.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa-768x107.png 768w, http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa-1536x215.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/interfaces-pa-2048x286.png 2048w" sizes="(max-width: 2782px) 100vw, 2782px" />

We should have IP connectivity between our Palo-Alto and both of our ISP&#8217;s! We&#8217;re officially connected to the internet&#8230; sort of.

Now for the fun stuff, BGP connections!

Lets start with the Palo-Altos.

1. Select the  &#8220;Virtual Routers&#8217; setion under the Network tab.
2. Select the &#8220;BGP&#8221; tab.
3. ENABLE the BGP protocol by checking the box.
4. Assign a Router ID. This can be one of the two IP&#8217;s on the interfaces facing our WAN services or a loopback (preffered).
5. Input your local AS Number.
6. **Make sure to UN-CHECK &#8220;Reject Default Route&#8221;**
   1. Both ISP&#8217;s will be advertising us Default-Routes. We&#8217;ll select one with BGP techniqures as a primary.
7. **Make sure to CHECK &#8220;Install Route&#8221;**
   1. This is necessary if we want to install routes from BGP / Local FIB into the Global Routing Table on the Palo Alto.
8. Depending on what model Palo-Alto you have, I would suggest creating a BFD profile and enabling this on your WAN connection for a fast-fail over detection to minimize downtime for your internal users.
   1. To create a BFD Profile:
      1. Network > Network Profiles > BFD Profile.
9. This should be enough for the &#8220;General&#8221; Tab.

**let&#8217;s move over to the &#8220;Peer Group&#8221;**

1. Add a new Peer Group, lets call this ISP 1 &#8211; Re-create the steps for ISP 2.
   1. Name: ISP 1
   2. Type: EBGP
2. Add a new peer.
   1. Name: WAN-ISP-1
   2. Peer-AS: 64511
   3. Select the appropriate Interface / IP Address
   4. Input the appropriate /31 peer IP of the WAN connection.
   5. Under Advanced, make sure the Inherit Protocol&#8217;s Global BFD Porifle is selected.
   6. Select OK and commit.

Here is what the BGP Peer Group section should look like at this point:

<img loading="lazy" class="alignnone size-full wp-image-63" src="http://localhost:8000/wp-content/uploads/2019/06/bgp.png" alt="bgp.PNG" width="2283" height="701" srcset="http://localhost:8000/wp-content/uploads/2019/06/bgp.png 2283w, http://localhost:8000/wp-content/uploads/2019/06/bgp-300x92.png 300w, http://localhost:8000/wp-content/uploads/2019/06/bgp-1024x314.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/bgp-768x236.png 768w, http://localhost:8000/wp-content/uploads/2019/06/bgp-1536x472.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/bgp-2048x629.png 2048w" sizes="(max-width: 2283px) 100vw, 2283px" />

Now, verify our BFD sessions..

<img loading="lazy" class="alignnone size-full wp-image-63" src="http://localhost:8000/wp-content/uploads/2019/06/bgp.png" alt="bgp" width="2283" height="701" srcset="http://localhost:8000/wp-content/uploads/2019/06/bgp.png 2283w, http://localhost:8000/wp-content/uploads/2019/06/bgp-300x92.png 300w, http://localhost:8000/wp-content/uploads/2019/06/bgp-1024x314.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/bgp-768x236.png 768w, http://localhost:8000/wp-content/uploads/2019/06/bgp-1536x472.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/bgp-2048x629.png 2048w" sizes="(max-width: 2283px) 100vw, 2283px" />

All looks good!  Lets verify we&#8217;re seeing a default-route from both peers:

<img loading="lazy" class="alignnone size-full wp-image-64" src="http://localhost:8000/wp-content/uploads/2019/06/def.png" alt="def" width="2291" height="613" srcset="http://localhost:8000/wp-content/uploads/2019/06/def.png 2291w, http://localhost:8000/wp-content/uploads/2019/06/def-300x80.png 300w, http://localhost:8000/wp-content/uploads/2019/06/def-1024x274.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/def-768x205.png 768w, http://localhost:8000/wp-content/uploads/2019/06/def-1536x411.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/def-2048x548.png 2048w" sizes="(max-width: 2291px) 100vw, 2291px" />

From the Local-RIB (And the Route Table) under the &#8220;More Runtime Stats&#8221; we are installing the default-route from our peer at ISP 1 &#8211; 172.16.65.0.

What if that peer is a 1G connection, but our Peer at ISP 2 should be our Primary WAN interface, as it&#8217;s a 10G interface? Let&#8217;s play with BGP now.

First, lets make sure all our outgoing traffic is going out or preffered exit path ( ISP 2) &#8211; let&#8217;s change our Local Pref on routes from ISP 2 to be more prefferd over ISP 1.

Navigate to BGP > Import and Add a new policy.

1. Create a new rule that&#8217;s used by ISP-2.
2. Under the Match tab, select the &#8220;From Peer&#8217; &#8211; &#8220;WAN-ISP-2.&#8221;
3. Unde the Action tab, up the Local Preference to 200 and select OK .
4. Repeat the steps above and hard set the LP to 100 on WAN-ISP-1.
5. Commit and let&#8217;s compare the route-table from our previous snippet.

Here is the Local-RIB, selecting the default-route from ISP-2.

<img loading="lazy" class="alignnone size-full wp-image-68" src="http://localhost:8000/wp-content/uploads/2019/06/newrib-1.png" alt="newrib.PNG" width="2276" height="594" srcset="http://localhost:8000/wp-content/uploads/2019/06/newrib-1.png 2276w, http://localhost:8000/wp-content/uploads/2019/06/newrib-1-300x78.png 300w, http://localhost:8000/wp-content/uploads/2019/06/newrib-1-1024x267.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/newrib-1-768x200.png 768w, http://localhost:8000/wp-content/uploads/2019/06/newrib-1-1536x401.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/newrib-1-2048x534.png 2048w" sizes="(max-width: 2276px) 100vw, 2276px" />

And verifying the Global Route Table as our preffered exit point:

<img loading="lazy" class="alignnone size-full wp-image-69" src="http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1.png" alt="rt-pref" width="2277" height="886" srcset="http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1.png 2277w, http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1-300x117.png 300w, http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1-1024x398.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1-768x299.png 768w, http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1-1536x598.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/rt-pref-1-2048x797.png 2048w" sizes="(max-width: 2277px) 100vw, 2277px" />

Looks good! All traffic is now routing out 172.16.64.0, which is our preffered 10G WAN interface to ISP-2.

Now how do we influence traffic to come into our AS via ISP 2 in hopes of avoiding asymmetrical routing? Well.. we can prepend if we&#8217;re advertising routes or advertise a more specific route to the prefferred neighbor and aggregate the routes advertised to the less preffered neighbor. The MED values are not helpful in this case, as we are peering with two separate providers.

We won&#8217;t worry about this for now, as we are not adveritisng any public routes to our providers, we simply need internet for our business.

Lets go ahead and redestribute the default route to our Enterprise core router.

But first.. lets peer with it.

I established a peering session with our Enterprise router and set it inside the &#8220;Trust&#8221; zone.

- This is just an example design. Depending on the business, a Router will be at the edge and the firewall will sit behind it which is not true in this scenario.

The BGP session has been established with our Enterprise Cisco Router.

**A new Peer Group should be created with a peer defined as the internal router.**

<img loading="lazy" class="alignnone size-full wp-image-71" src="http://localhost:8000/wp-content/uploads/2019/06/ibgp.png" alt="ibgp.PNG" width="2264" height="794" srcset="http://localhost:8000/wp-content/uploads/2019/06/ibgp.png 2264w, http://localhost:8000/wp-content/uploads/2019/06/ibgp-300x105.png 300w, http://localhost:8000/wp-content/uploads/2019/06/ibgp-1024x359.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/ibgp-768x269.png 768w, http://localhost:8000/wp-content/uploads/2019/06/ibgp-1536x539.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/ibgp-2048x718.png 2048w" sizes="(max-width: 2264px) 100vw, 2264px" />

> ENT-ROUTER#show ip bgp summary
> BGP router identifier 192.168.1.2, local AS number 64500
> BGP table version is 1, main routing table version 1
> 1 network entries using 144 bytes of memory
> 1 path entries using 80 bytes of memory
> 1/0 BGP path/bestpath attribute entries using 152 bytes of memory
> 1 BGP AS-PATH entries using 24 bytes of memory
> 0 BGP route-map cache entries using 0 bytes of memory
> 0 BGP filter-list cache entries using 0 bytes of memory
> BGP using 400 total bytes of memory
> BGP activity 1/0 prefixes, 1/0 paths, scan interval 60 secs
>
> Neighbor V AS MsgRcvd MsgSent TblVer InQ OutQ Up/Down State/PfxRcd
> 192.168.1.1 4 64500 4 4 1 0 0 00:00:21 1

- _**An internal BGP session isn&#8217;t necessary, as a static default route would be plenty. However, for lab purposes lets continue with more BGP FUN.**_

We can create static routes that point the two /31 interconnects to our directly connected interface from our Cisco to the Palo. This way, the default route that&#8217;s re-advertised by default is actually installed into our routing table.

> **Network Next Hop Metric LocPrf Weight Path**
> **\* i 0.0.0.0 172.16.64.0 200 0 64496 ?**
>
> **Total number of prefixes 1**
> **ENT-ROUTER#**

Again, we&#8217;re not installing this route, because our local router has no idea where 172.16.64.0 lives.

Create the two static routes for 172.16.64.0/31 and 172.16.65.0/31 and the magic happens:

<img loading="lazy" class="alignnone size-full wp-image-72" src="http://localhost:8000/wp-content/uploads/2019/06/cisco.png" alt="cisco" width="1043" height="1042" srcset="http://localhost:8000/wp-content/uploads/2019/06/cisco.png 1043w, http://localhost:8000/wp-content/uploads/2019/06/cisco-300x300.png 300w, http://localhost:8000/wp-content/uploads/2019/06/cisco-1024x1024.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/cisco-150x150.png 150w, http://localhost:8000/wp-content/uploads/2019/06/cisco-768x767.png 768w" sizes="(max-width: 1043px) 100vw, 1043px" />

&nbsp;

Our Enterprise router now has a way out to the world! Don&#8217;t forget to create the inter-zone policy to allow traffic from the Trust to Untrust zone. Also, in a real deployment &#8211; there will be a NAT rule out to the inter-webz on the PA, but that&#8217;s out of scope for this lab, as I wanted to focus attention to the WAN facing configuration on the Palo Alto.

[Palo Alto Documentation on NAT][1]

&nbsp;

[1]: https://docs.paloaltonetworks.com/pan-os/7-1/pan-os-admin/networking/nat-configuration-examples#https://docs.paloaltonetworks.com/pan-os/7-1/pan-os-admin/networking/nat-configuration-examples#
