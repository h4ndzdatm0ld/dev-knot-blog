---
title: "BGP Conditional Advertisement – Palo-Alto NGFW"
author: "Hugo Tinoco"
type: "post"
draft: false
date: 2019-07-05T13:10:54+00:00
url: /2019/07/05/bgp-conditional-advertisement-palo-alto-ngfw/
timeline_notification:
  - 1562332257
categories:
  - "Networking"
tags:
  - "bgp"
---

<h1 style="text-align:center;">
  Conditional Advertisement
</h1>

<a href="https://docs.paloaltonetworks.com/pan-os/8-1/pan-os-web-interface-help/network/network-virtual-routers/bgp/bgp-conditional-adv-tab" target="_blank" rel="noopener">Palo Alto BGP Condi Adv Documentation</a>

This article will outline how to configure conditional advertisements when utilizing multiple up-links from a Palo-Alto acting as an edge device on your network. Conditional Advertisement is an advanced routing feature, which is introduced at a Cisco&#8217;s CCIE level. I will be re-using the LAB topology from my previous post, as it works perfectly with this scenario.

What is Conditional Advertisement ?

> The Border Gateway Protocol (BGP) conditional advertisement feature provides additional control of route advertisement, depending on the existence of other prefixes in the BGP table.
>
> &#8211; https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/16137-cond-adv.html

A defined prefix must exist in the FIB in order to **_suppress_** the condition, therefore **not** advertising the desired routes to the _less preferred_ neighbor. This is useful when you want full and definite control of ingress and egress traffic to your network when multi-homing to different ISPs. **Both BGP sessions will be up simultaneously,** however until the monitored prefix is no longer found in the route-table, the condition will be suppressed (Not Advertised). Once the prefix is not in the route-table, the condition will be met and the advertisement will be propagated to the secondary, less preferred neighbor.

<img loading="lazy" class="alignnone size-full wp-image-61" src="http://localhost:8000/wp-content/uploads/2019/06/topology-1.png" alt="Topology" width="2061" height="997" srcset="http://localhost:8000/wp-content/uploads/2019/06/topology-1.png 2061w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-300x145.png 300w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-1024x495.png 1024w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-768x372.png 768w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-1536x743.png 1536w, http://localhost:8000/wp-content/uploads/2019/06/topology-1-2048x991.png 2048w" sizes="(max-width: 2061px) 100vw, 2061px" />

**ISP 1 = Most Preferred <span style="color:#ff0000;"><em>(Monitor received prefix 192.168.100.1/32 from ISP-1-B)</em></span>**

**ISP 2 = Less Preferred**

ISP 1 will be advertising a loop-back in which the Palo-Alto will monitor (utilizing ping checks). Contact your upstream provider and explain to one of their engineers what you&#8217;d like to do and the reason for your request. A simple RFC 1918 loopback /32 can be coordinated between your ISP and your organization to be advertised.  _PA&#8217;s do not allow a default-route to be monitored as part of the BGP Conditional advertisement. From a service-providers standpoint, this should not be a difficult request although it may take some work, as BOGONS are filtered in and out of global route tables. _You don&#8217;t have to depend on your service provider advertising a specific route though&#8230; feel free to get creative. After all, BGP only looks at the local-fib &#8211; you can monitor _any_ route coming from any where (BGP,OSPF,ISIS).

---

Lets get to business! &#8211; Here is the advertisement routes from ISP-1 Router &#8211; (preferred ISP) &#8211; We somehow managed to get the ISP to advertise 192.168.100.1/32 and we will monitor this prefix under our cond-adv tab/bgp process on our edge PA.

<img loading="lazy" class="alignnone size-full wp-image-82" src="http://localhost:8000/wp-content/uploads/2019/07/adv-routes.png" alt="adv-routes" width="2267" height="1210" srcset="http://localhost:8000/wp-content/uploads/2019/07/adv-routes.png 2267w, http://localhost:8000/wp-content/uploads/2019/07/adv-routes-300x160.png 300w, http://localhost:8000/wp-content/uploads/2019/07/adv-routes-1024x547.png 1024w, http://localhost:8000/wp-content/uploads/2019/07/adv-routes-768x410.png 768w, http://localhost:8000/wp-content/uploads/2019/07/adv-routes-1536x820.png 1536w, http://localhost:8000/wp-content/uploads/2019/07/adv-routes-2048x1093.png 2048w" sizes="(max-width: 2267px) 100vw, 2267px" />

Now, lets verify our **IMPORT** statement on our Palo-Alto. We are _only allowing a default-route and prefix 192.168.100.1/32._

<img loading="lazy" class="alignnone size-full wp-image-83" src="http://localhost:8000/wp-content/uploads/2019/07/import-statement.png" alt="import-statement.PNG" width="1823" height="513" srcset="http://localhost:8000/wp-content/uploads/2019/07/import-statement.png 1823w, http://localhost:8000/wp-content/uploads/2019/07/import-statement-300x84.png 300w, http://localhost:8000/wp-content/uploads/2019/07/import-statement-1024x288.png 1024w, http://localhost:8000/wp-content/uploads/2019/07/import-statement-768x216.png 768w, http://localhost:8000/wp-content/uploads/2019/07/import-statement-1536x432.png 1536w" sizes="(max-width: 1823px) 100vw, 1823px" />

---

Lets talk about the EXPORT side. Create export statements specifying the Public IP of your public facing servers, etc. Even though we are advertising to both peers, the conditional advertisement SUPPRESSES the advertisement. At this point, since the condition hasn&#8217;t been configured, normal BGP behavior will send the routes to both peers.

Also, create a DENY policy to prevent any other routes from advertising (expected BGP behavior to re-advertise to other eBGP peers). Pay close attention to the &#8216;Used By&#8217; section.

I&#8217;m selecting both PEERS to advertise the public route 2.2.2.2/32 and the DENY action for the &#8216;no-routes&#8217; This is a common practice and the beauty of BGP; the full control. Put your security hat on and think of these export policies as actual firewall security policies. They are read from top to bottom in this case.

<img loading="lazy" class="alignnone size-full wp-image-84" src="http://localhost:8000/wp-content/uploads/2019/07/no-routes.png" alt="no-routes" width="2248" height="535" srcset="http://localhost:8000/wp-content/uploads/2019/07/no-routes.png 2248w, http://localhost:8000/wp-content/uploads/2019/07/no-routes-300x71.png 300w, http://localhost:8000/wp-content/uploads/2019/07/no-routes-1024x244.png 1024w, http://localhost:8000/wp-content/uploads/2019/07/no-routes-768x183.png 768w, http://localhost:8000/wp-content/uploads/2019/07/no-routes-1536x366.png 1536w, http://localhost:8000/wp-content/uploads/2019/07/no-routes-2048x487.png 2048w" sizes="(max-width: 2248px) 100vw, 2248px" />

1. Create an interface **LOOPBACK, if the IP is a /32.** Otherwise, create a secondary subnet on a L3 Interface. This is important as the default behavior of the PA will affect our advertisement.
2. Create a re-distribution and specify either a profile or simply input the prefix.
   1. Redistribution is required as we&#8217;re literally bringing in a directly connected interface (Loopback) or a IP from an interface into BGP.

---

<span style="text-decoration:underline;"><span style="color:#ff0000;"><strong>Lets select the &#8220;Conditional ADV&#8221; tab now.</strong></span></span>

**It&#8217;s very important to specify the &#8220;USED BY&#8221; as the SECONDARY, LESS PREFERRED peer.** Otherwise, this won&#8217;t work. As you can see, I have selected &#8220;ISP-2&#8221; as it&#8217;s my secondary peer. The &#8220;Non Exist Filters&#8221; specifies the IP Prefix that I am monitoring from ISP-1. If that peer session were to drop, the prefix 192.168.100.1/32 would disappear from my routing table, therefore the _condition would be triggered and the route would be advertised to the Secondary-Peer, &#8220;ISP-2&#8221;._

<img loading="lazy" class="alignnone size-full wp-image-85" src="http://localhost:8000/wp-content/uploads/2019/07/cond-1.png" alt="cond-1" width="2193" height="771" srcset="http://localhost:8000/wp-content/uploads/2019/07/cond-1.png 2193w, http://localhost:8000/wp-content/uploads/2019/07/cond-1-300x105.png 300w, http://localhost:8000/wp-content/uploads/2019/07/cond-1-1024x360.png 1024w, http://localhost:8000/wp-content/uploads/2019/07/cond-1-768x270.png 768w, http://localhost:8000/wp-content/uploads/2019/07/cond-1-1536x540.png 1536w, http://localhost:8000/wp-content/uploads/2019/07/cond-1-2048x720.png 2048w" sizes="(max-width: 2193px) 100vw, 2193px" />

Below, is the &#8220;Advertise Filters&#8221; tab. Here you will input the Public Server IP that you want to control advertisement of.  What this says, &#8220;Used By&#8221; &#8211; The peer that the prefix will be advertised to, once the &#8216;Non Exist Filters&#8221; prefix is non-existent in the routing table.<img loading="lazy" class="alignnone size-full wp-image-86" src="http://localhost:8000/wp-content/uploads/2019/07/cond-2.png" alt="cond-2" width="2193" height="638" srcset="http://localhost:8000/wp-content/uploads/2019/07/cond-2.png 2193w, http://localhost:8000/wp-content/uploads/2019/07/cond-2-300x87.png 300w, http://localhost:8000/wp-content/uploads/2019/07/cond-2-1024x298.png 1024w, http://localhost:8000/wp-content/uploads/2019/07/cond-2-768x223.png 768w, http://localhost:8000/wp-content/uploads/2019/07/cond-2-1536x447.png 1536w, http://localhost:8000/wp-content/uploads/2019/07/cond-2-2048x596.png 2048w" sizes="(max-width: 2193px) 100vw, 2193px" />

This out put displays the condition being SUPPRESSED, since the prefix 192.168.100.1/32 is PRESENT in the routing table.

> <span style="color:#ff0000;">admin@PA-VM> show routing protocol bgp loc-rib</span>  
> VIRTUAL ROUTER: default (id 1)  
> ==========  
> Prefix Nexthop Peer Weight LocPrf Org MED flap AS-Path  
> 0.0.0.0/0 172.16.65.0 WAN-ISP-1 0 100 i/c 0 0 64511  
> **<span style="color:#ff0000;">\*192.168.100.1/32 172.16.65.0 WAN-ISP-1 0 100 i/c 0 0 64511</span>** > *0.0.0.0/0 172.16.64.0 WAN-ISP-2 0 200 i/c 0 0 64496
> *192.168.1.0/24 192.168.1.2 Core-Router 0 100 igp 0 0  
> \*2.2.2.2/32 Local 0 100 i/c 0 0
>
> total routes shown: 5
>
> **<span style="color:#ff0000;">admin@PA-VM> show routing protocol bgp policy cond-adv</span>**  
> VIRTUAL ROUTER: default (id 1)  
> ==========  
> Peer/Group: WAN-ISP-2  
> **<span style="color:#ff0000;">Suppress condition met: yes</span>**  
> Suppress condition (Non-exist filter):  
> name: Loop-to-monitor  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 192.168.100.1  
> hit count: 17  
> Route filter (Advertise filter):  
> name: Routes-To-Advertise  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 2.2.2.2  
> hit count: 3  
> &#8212;&#8212;&#8212;-  
> Peer/Group: ISP-2  
> Suppress condition met: yes  
> Suppress condition (Non-exist filter):  
> name: Loop-to-monitor  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 192.168.100.1  
> hit count: 17  
> Route filter (Advertise filter):  
> name: Routes-To-Advertise  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 2.2.2.2  
> hit count: 3  
> &#8212;&#8212;&#8212;-

Now, I will shut down the Peering Session from the BGP edge router at ISP-1. This will pull the prefix 192.168.100.1/32 from the Routing Table on the Palo Alto and will meet the condition, therefore advertising the public server IP out the Secondary-Peering session, ISP-2.

> **<span style="color:#ff0000;">admin@PA-VM> show routing protocol bgp loc-rib</span>**  
> VIRTUAL ROUTER: default (id 1)  
> ==========  
> Prefix Nexthop Peer Weight LocPrf Org MED flap AS-Path  
> *0.0.0.0/0 172.16.64.0 WAN-ISP-2 0 200 i/c 0 0 64496  
> *192.168.1.0/24 192.168.1.2 Core-Router 0 100 igp 0 0  
> \*2.2.2.2/32 Local 0 100 i/c 0 0
>
> total routes shown: 3
>
> admin@PA-VM> show routing protocol bgp policy cond-adv  
> VIRTUAL ROUTER: default (id 1)  
> ==========  
> Peer/Group: WAN-ISP-2  
> **<span style="color:#ff0000;">Suppress condition met: no</span>**  
> Suppress condition (Non-exist filter):  
> name: Loop-to-monitor  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 192.168.100.1  
> hit count: 19  
> Route filter (Advertise filter):  
> name: Routes-To-Advertise  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 2.2.2.2  
> hit count: 3  
> &#8212;&#8212;&#8212;-  
> Peer/Group: ISP-2  
> Suppress condition met: no  
> Suppress condition (Non-exist filter):  
> name: Loop-to-monitor  
> AFI: bgpAfiIpv4  
> SAFI: unicast  
> Destination: 192.168.100.1  
> hit count: 19  
> Route filter (Advertise filter):  
> **<span style="color:#ff0000;">name: Routes-To-Advertise</span>**  
> **<span style="color:#ff0000;">AFI: bgpAfiIpv4</span>**  
> **<span style="color:#ff0000;">SAFI: unicast</span>**  
> **<span style="color:#ff0000;">Destination: 2.2.2.2</span>**  
> hit count: 3  
> &#8212;&#8212;&#8212;-

Keep in mind that BGP offers many knobs to traffic-engineer IN-bound and OUT-bound traffic. Utilizing MED is a way to steer traffic inbound, although &#8211; this will work only when dual-homing to the same ISP AND must be enabled/allowed by the upstream ISP.

When the MED option isn&#8217;t viable, utilizing pre-pend will utilize AS-PATH as a way to discourage upstream routers from selecting the less-desired route.

Also, keep in mind that most providers will have BGP communities they will share with their customers. Make sure to review this with your upstream provider and find out what is the best option for you. Finally, never forgot about old-faithful for outbound-exiting traffic.: Local-pref.
