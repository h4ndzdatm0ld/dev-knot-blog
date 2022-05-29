---
title: DDoS Mitigation – RTBH – Blackhole Community
author: Hugo Tinoco
type: post
date: 2019-04-01T04:38:18+00:00
url: /2019/04/01/ddos-mitigation-rtbh-blackhole-community/
timeline_notification:
  - 1554093504
categories:
  - Uncategorized
---

I&#8217;m working on a mini-series of videos to demonstrate a common practice with Service Provider networks in regards to DDoS Mitigation. A quick google search and you can find PDF documents from ISP&#8217;s all over the world with detailed BGP communities they accept and how they manipulate traffic through their particular AS.

A BGP community string is simply a way to control policy routing through your upstream provider network. The community string in which I&#8217;ve been concentrating on is the common &#8220;Blackhole&#8221; community. This community is advertised to upstream providers to instruct the ISP to discard all traffic to the destination prefix before it is routed to the customer. It is common practice to allow this community. Inquire with your provider for the BGP community document to better understand the way in which you can manipulate  upstream traffic to your advantage.

This lab was mostly rooted from personal projects I&#8217;m undergoing but also a great excuse to start pushing the limits of my new EVE-NG server.  I&#8217;m really enjoying the interface and the ease-of-use.

Here is the part 1 of the video series. More to come, stay tuned..!
