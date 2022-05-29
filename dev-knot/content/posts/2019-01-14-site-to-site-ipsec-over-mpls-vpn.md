---
title: Site-to-Site IPSec over MPLS VPN
author: Hugo Tinoco
type: post
date: 2019-01-14T04:02:54+00:00
url: /2019/01/14/site-to-site-ipsec-over-mpls-vpn/
timeline_notification:
  - 1547438717
categories:
  - Uncategorized

---
I want to start by saying I&#8217;ve over complicated everything because, well, it&#8217;s my lab and it&#8217;s fun for me. Depending on customer needs, a simple MPLS L2 VRF and an IPSEC tunnel on top would be sufficient, unless the sites also require internet service by the Service Provider delivering the VRF. In a simple MPLS VPN where the service simply connects sites to sites, the IP addresses are not advertised and could be a lot more secure than over the internet. Another advantage of utilizing an MPLS VPN is the ease of troubleshooting for the customer &#8211; the service traverses only one provider &#8211; not through the internet.

Lets take a deep dive at what an IPSEC tunnel looks like from an Enterprise perspective over a service provider MPLS L2/L3 VPN, not only from the CustomerSites but what actually happens inside the ServiceProvider network? In this case, we&#8217;ll be going from a statically configured site, which is Site-A on the left (Topology A below). The configuration is a Static L3 MPLS VRF provisioned with a Nokia Routed-VPLS utilizing a VRRP for Router-Redundancy (R2/R3). This is a common configuration provided by Service Providers to customers.  
The MPLS VRF goes across the MPLS Core Network and terminates on R6 and R5. Both of these sites are participating in the same VRF (VPRN 100) and have an eBGP session set up to the CustomerSiteB on the right side.

**_A few key notes:_**  
I&#8217;ve set up an AS-Path prepend from the Customer Router at Site B facing the eBGP session on R5 at 175.175.1.1.  
The Customer Site B router is currently load balancing across both eBGP neighbors to take full advantage of the dual-homed configuation.

<img loading="lazy" class="  wp-image-10 aligncenter" src="http://localhost:8000/wp-content/uploads/2019/01/site-to-siteipsecovermpls.png" alt="site-to-siteipsecovermpls" width="841" height="517" /> 

_Topology A._

**_MPLS Security?_**

An MPLS VPN (L2 or L3) Is secure to a certain degree. MPLS VPNs do not encrypt packets across the network, which makes it susceptible to eavesdropping by intruders.

Here is a wireshark capture without IPSEC between CustomerSiteA and R1. The traffic shows icmp request from CustomerSiteB to the Lo0 of CustomerSiteA.  As you can see, there is no encryption by the Service Provider and the service being delivered could easily be sniffed. How much do you trust your Service Provider?

<!--more-->

<img loading="lazy" class="alignnone size-full wp-image-12" src="http://localhost:8000/wp-content/uploads/2019/01/wireshark-noencr.png" alt="wireshark-noencr.PNG" width="2281" height="891" /> 

Here is the Service Provider configuration for the VPRN on R2 for more context:

<!--more-->

<img loading="lazy" class="alignnone size-full wp-image-15" src="http://localhost:8000/wp-content/uploads/2019/01/configr2.png" alt="configR2.PNG" width="989" height="1377" srcset="http://localhost:8000/wp-content/uploads/2019/01/configr2.png 989w, http://localhost:8000/wp-content/uploads/2019/01/configr2-215x300.png 215w, http://localhost:8000/wp-content/uploads/2019/01/configr2-735x1024.png 735w, http://localhost:8000/wp-content/uploads/2019/01/configr2-768x1069.png 768w" sizes="(max-width: 989px) 100vw, 989px" /> 

Nothing else too exciting on the other side. Here is a configuration snippet from R6. The same applies to R5, but substitue the correct subnets.

<img loading="lazy" class="alignnone size-full wp-image-16" src="http://localhost:8000/wp-content/uploads/2019/01/r6vprn.png" alt="R6vprn.PNG" width="1263" height="1287" srcset="http://localhost:8000/wp-content/uploads/2019/01/r6vprn.png 1263w, http://localhost:8000/wp-content/uploads/2019/01/r6vprn-294x300.png 294w, http://localhost:8000/wp-content/uploads/2019/01/r6vprn-1005x1024.png 1005w, http://localhost:8000/wp-content/uploads/2019/01/r6vprn-768x783.png 768w" sizes="(max-width: 1263px) 100vw, 1263px" /> 

&nbsp;

**_Lets build the IPSEC Site-to-Site tunnel from CustomerSiteA to CustomerSiteB._**

The interesting traffic from CustomerSiteA will be the LAN subnet 192.168.1.0/24 &#8211; The interesting traffic from CustomerSiteB will be the LAN subnet 172.16.1.0/24. We&#8217;ll throw in the loopbacks as well.

_NOTE: Perhaps I&#8217;ll go back and experiment with a DM-VPN as there are two public facing GW&#8217;s on the customer routers. Will this work as a DMVPN? I&#8217;ll find out later._

For now, we&#8217;ll build an IPSEC tunnel to one GW on CustomerSiteB. Technically, this is not utilizing the full redundancy of dual homed BGP sessions, which is just one of the many obstacles NE&#8217;s have to deal with and what makes this so fun.** _We will use the 172.172.1.1/24  &#8211; R6 &#8211; connection for our IPSEC tunnel due to the current_** configuartion** _(AS-PathPrepend)._**

PHASE 1 :: Isakamp Policy.

This is the bidriectional ISAKMP negotation of our tunnel. This policy must match on both customer routers, except for the Lifetime.

  1. Hash Algorithm
  2. Authentication
  3. Diffie-Hellman Group #
  4. Lifetime.
  5. Encryption Algorithm.

&nbsp;

**Config snippet of our ISAKAMP policy. This is also applied to Site-B-GW-Router.  
** 

&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;  
Site-A-GW-Router#show run | se crypto

&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;  
crypto isakmp policy 10  
encr aes  
hash sha256  
authentication pre-share  
group 5  
Site-A-GW-Router#

* * *

**Next, the simple ISAKMP** Peer / key **to** establish **the tunnel. This should wrap up PHASE 1 &#8211; Configuration.**

crypto isakmp key WowWhatAPassword! address 172.172.1.2

**PHASE** 2 : **Here we will establish the** unidrectional **channels between our IPSEC SA&#8217;s &#8211; (Peers).  _This_ is reminds _me of an MPLS LSP? Ring a Bell?_** Unidrection_ **tunnels? 😉**_ 

The transform set will match on both sides, here is the configuration:

crypto ipsec transform-set TSET esp-aes 256 esp-sha512-hmac  
mode tunnel

  * &#8211; Remember that a IPSec mode can be  set to two modes. 
      * Mode Tunnel 
          * Only the Packet Payload is encrypted across the tunnel.
      * Mode Tunnel 
          * The IPHeader and Payload are encrypted. Basically, the entire packet and this is the most secure AND default.

We&#8217;re ready to move on and define our &#8216;interesting&#8217; traffic. Lets create our access list to specify what traffic should trigger the IPSec tunnel. Remember, the local subnet first, heading to the remote subnet. **_DON&#8217;T FORGET THIS REQUIRES WILDCARD BITs. This got me a few times._**

Take note of the name of the Access List. We&#8217;ll need this for our crypto map to apply to our outbound interface.

Site-A-GW-Router#show run | se access-list  
ip access-list extended VPN-TRAFFIC  
permit ip 192.168.1.0 0.0.0.255 172.16.1.0 0.0.0.255  
Site-A-GW-Router#

_Now, reverse this on the other side&#8230;_  
Site-B-GW_Router#show run | se access-list  
ip access-list extended VPN-TRAFFIC  
permit ip 172.16.1.0 0.0.0.255 192.168.1.0 0.0.0.255

**Almost there!** Lets create our Crypto Map and apply this to our outbound interface. This will include the peer (Neighbor far-end public facing IP of CustomerSite-B), the Transform Set name from earlier (TSET) and we will identify the &#8216;interesting&#8217; traffic to trigger the IPSEC tunnel, which we named VPN-TRAFFIC.

Again, this would match on the other side, but the peer address would be substituted for the Public Facing IP of CustomerSite-A.  
Site-A-GW-Router#show run | se crypto map  
crypto map VPN-MAP 100 ipsec-isakmp  
set peer 172.172.1.2  
set transform-set TSET  
match address VPN-TRAFFIC  
Site-A-GW-Router#

**After thinking further on my earlier thought, would this require a DMVPN? I think we could simply add another crypto map and have a separate peer.**

We are ALMOST DONE! &#8211; The final step: Adding the &#8216;VPN-MAP&#8217; to the outbound interface on our CustomerRouters.

However, here is something I want to show you about MPLS VPN&#8217;s without encryption which makes for a significant vulnerability regardings eavesdropping. Of course, we saw the snippet of the wireshark capture at the PE &#8211; to the CE. This is a vulnerable point, but what about inside the core? Although the Service Provider has a responsibility, there could be people who are using packet captures and are able to capture sensative traffic without an issue (Employees in general). MPLS makes dropping packet captures in the network VERY easy, which is great for troubleshooting! Traffic can be replicated in a number of ways &#8211;

I&#8217;ve built a packet capture on R1 which will replicate any traffic that is coming from the SAP/port facing the customer on R6. If you&#8217;re interested in learning more on how to build mirror services on the Nokia platform, check out this video I&#8217;ve made a few months back.



Here is a snippet of the wireshark capture, mirroring traffic thats  still unencrypted. Remember, we haven&#8217;t applied out VPN crypto map.

<img loading="lazy" class="alignnone size-full wp-image-19" src="http://localhost:8000/wp-content/uploads/2019/01/vpnmirror.png" alt="vpnmirror.PNG" width="2091" height="819" srcset="http://localhost:8000/wp-content/uploads/2019/01/vpnmirror.png 2091w, http://localhost:8000/wp-content/uploads/2019/01/vpnmirror-300x118.png 300w, http://localhost:8000/wp-content/uploads/2019/01/vpnmirror-1024x401.png 1024w, http://localhost:8000/wp-content/uploads/2019/01/vpnmirror-768x301.png 768w, http://localhost:8000/wp-content/uploads/2019/01/vpnmirror-1536x602.png 1536w, http://localhost:8000/wp-content/uploads/2019/01/vpnmirror-2048x802.png 2048w" sizes="(max-width: 2091px) 100vw, 2091px" /> 

I&#8217;ll post a quick configuration of the Mirror service and debug config.

On R1 I plugged a Kali Linux box to port 1/1/3.

*A:R1>config>mirror>mirror-dest# info  
&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-  
remote-source  
far-end 10.10.10.6  
exit  
sap 1/1/3 create  
exit  
no shutdown

  * The far-end command specifies the System IP address of R6. This is specifing the remote source for the capture.

On R6:

*A:R6>config>mirror>mirror-dest# info  
&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;-  
spoke-sdp 61:200 create  
no shutdown  
exit  
no shutdown

Here, the mirror service simply specifies a SPOKE with a VC-ID attached to it, as any other service. This is directing all the mirrored traffic to R1 via this service (200).

Finally, our debug &#8211; this specifies the SOURCE port or SAP to mirror. Again, this could be either ingress or egress or both.

*A:R6# show debug  
debug  
mirror-source 200  
port 1/1/1 egress ingress  
no shutdown  
exit  
exit  
*A:R6#

&#8211; Lets go back and apply our crypto map to our outbound interfaces and compare the mirror service traffic thats being replicated to our sniffer box.

On CustomerSite-B and Site-A I&#8217;ve applied &#8216;crypto map VPN-MAP&#8217;

interface GigabitEthernet0/1  
ip address 172.172.1.2 255.255.255.0  
duplex auto  
speed auto  
media-type rj45  
**crypto map VPN-MAP**  
end

Now we can see our Phase 1  &#8211;

Site-B-GW_Router#show crypto ipsec sa

interface: GigabitEthernet0/1  
Crypto map tag: VPN-MAP, local addr 172.172.1.2

protected vrf: (none)  
**local ident (addr/mask/prot/port): (172.16.1.0/255.255.255.0/0/0)**  
**remote ident (addr/mask/prot/port): (192.168.1.0/255.255.255.0/0/0)**  
current_peer 77.77.77.28 port 500  
PERMIT, flags={origin\_is\_acl,}  
#pkts encaps: 0, #pkts encrypt: 0, #pkts digest: 0  
#pkts decaps: 0, #pkts decrypt: 0, #pkts verify: 0  
#pkts compressed: 0, #pkts decompressed: 0  
#pkts not compressed: 0, #pkts compr. failed: 0  
#pkts not decompressed: 0, #pkts decompress failed: 0  
#send errors 0, #recv errors 0

**local crypto endpt.: 172.172.1.2, remote crypto endpt.: 77.77.77.28**  
plaintext mtu 1500, path mtu 1500, ip mtu 1500, ip mtu idb GigabitEthernet0/1  
current outbound spi: 0x0(0)  
PFS (Y/N): N, DH group: none

Lets not forget to add static routes pointing where to send the interesting traffic.

**Site-B-GW_Router(config)#ip route 192.168.1.0 255.255.255.0 77.77.77.28**

I will do the same on the other side.

Now, the momemnt of truth. I&#8217;ve configured a device hanging off the CustomerSite-B Router with an ip address that&#8217;s inside the local lan of 172.16.1.x, which should trigger the IPSEC tunnel.

The device has a default route going to the GW Router. Here is a snippet of the same mirror service showing traffic encapsulated from the customers internal network to the remote destination THROUGH the service provider.

<img loading="lazy" class="alignnone size-full wp-image-20" src="http://localhost:8000/wp-content/uploads/2019/01/espencvrf.png" alt="espencvrf" width="2073" height="929" srcset="http://localhost:8000/wp-content/uploads/2019/01/espencvrf.png 2073w, http://localhost:8000/wp-content/uploads/2019/01/espencvrf-300x134.png 300w, http://localhost:8000/wp-content/uploads/2019/01/espencvrf-1024x459.png 1024w, http://localhost:8000/wp-content/uploads/2019/01/espencvrf-768x344.png 768w, http://localhost:8000/wp-content/uploads/2019/01/espencvrf-1536x688.png 1536w, http://localhost:8000/wp-content/uploads/2019/01/espencvrf-2048x918.png 2048w" sizes="(max-width: 2073px) 100vw, 2073px" /> 

Remember, the Site-to-Site IPSec tunnel that we built only identifies specific traffic.

Make sure to correctly craft the access lists to tunnel your traffic. So, there ya have it. The IPSEC security going over the MPLS VPN.

This was a fun lab for me. I&#8217;ve been putting myself a lot in the shoes of the customer &#8211; from an enterprise perspective as I take a deep dive into my CCNA Security studies. It&#8217;s made me think aboout a lot of different scenarios and I hope to create more labs and blog post alike.

&nbsp;

Thanks,

&nbsp;

Hugo Tinoco

&nbsp;