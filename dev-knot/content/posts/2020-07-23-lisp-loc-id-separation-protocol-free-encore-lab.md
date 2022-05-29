---
title: LISP – Loc/ID Separation Protocol (FREE ENCORE LAB)
author: Hugo Tinoco
type: post
date: 2020-07-23T23:37:45+00:00
url: /2020/07/23/lisp-loc-id-separation-protocol-free-encore-lab/
timeline_notification:
  - 1595547469
categories:
  - Uncategorized

---
I have decided to continue my education and dig deeper into the Cisco world. As an engineer that&#8217;s basically dedicated the past 4 years of his life into a Nokia IP/Routing world, I somtimes need to take a step back and spend time to understand other vendor&#8217;s platform and emerging technologies. I recently passed the Cisco DevNet exam and well, it made me realize there is a lot of gaps in my knowledge regarding Cisco. I&#8217;m currently studying for ENCORE and hope to grasp some of the unfamiliar knowledge and refresh up on all the basics, OSPF, BGP, STP, etc..  I hold a  NRS II, which is basically a CCNP, but it involves a detailed 4 hour live router lab that must be performed in person under strict monitoring rules. My goal is to become a CCNP/NRS II by the end of the year. I&#8217;ve chosen to start labbing LISP, as SD-Access is an emplementation of VXLAN with LISP control plane. These are technologies I will be digging much deeper into as I have not had experience with them professionally.

Lets talk about Overlay Tunnels.  An overlay network is a logical or virtual network on top of a physical transport network, which is also known as the underlay network.

Some overlay tunneling technologies include, GRE, IPsec, LISP, VxLAN and MPLS. In this POST, I want to concentrate on LISP.

The main goal of LISP is to address the scalability problems with the growing route table of the internet.

A few KeyTerms to remmember:

  * **Endpoint Identifier (EID**) &#8211; The IP address of an endpoint within a LISP Site. EIDs are the same ip addresses in use today on endpoints (v4/v6).
  * **LISP Site** &#8211; The name of the Site where EID&#8217;s and LISP routers live.
  * **Ingress Tunnel Router (ITR)** &#8211; LISP Routers that **LISP-encapsulate** IP Packets coming from EIDs that are **destined outside** the LISP site.
  * **Egress tunnel router (ETR)** &#8211; ETRs are LISP routers that **de-encapsulate** LISP-encapsulated IP packets coming from sites outside the LISP site and **destined to EIDs within the LISP site. **
  * **Tunnel Router (xTR)** &#8211; Routers that perform ITR and ETR Functions. (Most routers wihtin an LISP domain)
  * **Proxy ITR (PITR)** -PITRS are for non-LISP sites that send traffic to EID destinations
  * **Proxy ETR (PETR)** &#8211; PETRS act just like ETRS, but for EIDs that send traffic to destinations at non-LISP sites.
  * **LISP Router** &#8211; Any router that performs any LISP functions.
  * **Routing Location (RLOC)** &#8211; RLOC is an IPv4/v6 address of an ETR that is Internet facing or core network facing.
  * **Map Server (MS)** &#8211; This is a network device (Router) that learns EID to prefix mapping entries from an ETR and stores them in a local EID-to-RLOC mapping database.
  * **Map Resolver (MR)** &#8211; Network device that receives LISP-encapsulated map requests from an ITR and finds the appropriate ETR to answer those requests by consulting the map server.
  * **Map Server/Map Resolver (MS/MR)** &#8211; When MS and MR are implemented on the same device.<img loading="lazy" class="alignnone size-full wp-image-155" src="http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm.png" alt="Screen Shot 2020-07-23 at 4.30.40 PM" width="1812" height="917" srcset="http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm.png 1812w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-300x152.png 300w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-1024x518.png 1024w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-768x389.png 768w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-1536x777.png 1536w" sizes="(max-width: 1812px) 100vw, 1812px" />

The advantage and key control plane feature of LISP is the efficiency and scalability of the on-deman routing, as it&#8217;s not a PUSH model such as BGP or OSPF. LISP utilizes a pull model where only the requested routing information is provided, instead of a full table.

This entire operation sure feels like a DNS query. I felt this way the second I was updating the MS/MS in my lab telling it what the EID&#8217;s prefixes within my LISP site was. It&#8217;s an easy way to think of LISP and maybe that will click easier in your head.

Lets review the registration process for Site: Avifi-A on the left, CSR-A12.

<img loading="lazy" class="alignnone size-full wp-image-155" src="http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm.png" alt="Screen Shot 2020-07-23 at 4.30.40 PM" width="1812" height="917" srcset="http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm.png 1812w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-300x152.png 300w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-1024x518.png 1024w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-768x389.png 768w, http://localhost:8000/wp-content/uploads/2020/07/screen-shot-2020-07-23-at-4.30.40-pm-1536x777.png 1536w" sizes="(max-width: 1812px) 100vw, 1812px" /> 

If the traffic flow is from Site Avifi &#8211; B to Site Avifi-A, the Avifi-A router will be the ETR in this instance(technically, the device is confiured as itr/etr as it&#8217;s providing both functions.). Avifi-A will need to adervtise it&#8217;s Lo0 address to the MS/MR.

The EID for Avifi-A : 192.168.1.0/24 &#8211; This includes the Lo0 that&#8217;s currently reachable on the router.

The RLOC is the interface address configured on Gi1 on the Avifi-A router. Although not displayed on the image, it&#8217;s 10.0.1.2.

Here is an example configuration snippet of the database-mapping command to include the EID and the RLOC.

> **R2-Avifi-A#show run | sec lisp**  
> router lisp  
> database-mapping 192.168.1.0/24 10.0.1.2 priority 1 weight 100  
> ipv4 itr map-resolver 10.0.1.1

The Lab has since expanded to add CPE&#8217;s with traditional OSPF routing between the xTR and the CPE. There is redistribution of connected subnets (loopbacks) and the xTR has an updated database to include this loopback.

I&#8217;ve also included an IPSEC via VTI that has an OSPF adjacency across a simulated ISP network with public IP addresses. This allows us to take advantage of a PxTR which is a PITR and PETR router collapsed into one device.  I&#8217;ve uploaded this EVE-NG LAB into my blog for you to downoad and play with..who knows, maybe ever learn about LISP!

I&#8217;ve left fun exercise for your to practice, if you wish to use this lab.

TASK:

Establish the underlay network for Site B&#8217;s CPE to the PE. Once that&#8217;s completed, ensure the EID is updated on the MS/MR and that the EID is reachable via LISP overlay network.

[\_Exports\_eve-ng_export-20200724-023627][1]

&nbsp;

 [1]: http://localhost:8000/wp-content/uploads/2020/07/exports_eve-ng_export-20200724-023627.zip "_Exports_eve-ng_export-20200724-023627"