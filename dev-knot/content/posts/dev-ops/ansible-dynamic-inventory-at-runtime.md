---
title: Ansible - Generate a Dynamic Inventory at Runtime
author: Hugo Tinoco
type: post
draft: false
date: 2019-01-14T04:02:54+00:00
url: /2019/01/14/site-to-site-ipsec-over-mpls-vpn/
timeline_notification:
  - 1547438717
categories:
  - Networking
  - Ansible
  - DevOps
  - Network Automation
---

We don't always get lucky enough to have a dynamic inventory from a trusted source of truth/record. Hell, sometimes we don't even have a static inventory accessible for our playbooks to use. Oh, but that's right! That team, under that BU has a spreadsheet with {X} part of the network. Maybe we can use that? Well, I'm not here to write about which problem to tackle first, but how you can leverage `ansible.builtin.add_hosts` and `json_schema` to rely on data from the user to dynamically create an inventory in memory.

As Network Automation Engineers, we commonly find ourselves helping everyone and anyone across the organization to alleviate those repetitive patterns. As we continue to evolve and adapt, we must determine what is worth the effort. Can we automate this specific task, without a dynamic inventory? Sure, we can find ways around that. One thing we already know, is never to trust the input from any user. Now, how to take these two things and create a strategy that's repeatable and able to provide a `dynamic` feel to our inventories?

Scenario:

Team A would like to be able to provide a list of devices and extract some information from them and then decide if some action should happen or not. Simple request, right? So, what do you do with this list of devices? Surely, we won't be creating new static inventory every time and updating our repository with a new and updated YAML file every time with the correct hosts, attached to the Change Request.
