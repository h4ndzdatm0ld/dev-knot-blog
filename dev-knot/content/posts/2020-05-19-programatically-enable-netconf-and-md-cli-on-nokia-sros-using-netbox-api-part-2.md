---
title: Programatically Enable NETCONF and MD-CLI on Nokia – SROS Using Netbox API. (Part 2)
author: Hugo Tinoco
type: post
draft: true
date: 2020-05-19T21:32:56+00:00
url: /2020/05/19/programatically-enable-netconf-and-md-cli-on-nokia-sros-using-netbox-api-part-2/
timeline_notification:
  - 1589923979
categories:
  - Networking
  - Automation
---

CODE: <https://github.com/h4ndzdatm0ld/sros-enable-netconf/blob/master/enable-netconf-netboxapi.py>

Okay, so you&#8217;re still reading? Lets keep digging into the mind of the network team and see how this exercisce is going..  So far, we&#8217;ve got a command line tool that we can target one specific node and deploy a script to enable MD-CLI, Yang Models from Nokia and of course, NETCONF. But, how far does this really get us? Really, it&#8217;s usefull to test on a handful of nodes and see the behaviour and response to our scripts in a lab environemnt. I&#8217;ve tested it on several SROS 19.10R3 A8&#8217;s and SR1&#8217;s.

It&#8217;s time to elaborate on the script and use the tool the Avifi has already deployed and mainted, Netbox. If you haven&#8217;t heard of Netbox, google it. In short it&#8217;s an IPAM/DCIM and so much more. The customer has requested we do not make any changes to anything in the subnet 10.0.0.0/16, anything else is fair game.  Lucky for us, the IP&#8217;s we need have been tagged with &#8216;7750&#8217;, would you believe that?! We&#8217;ll use a filter on our API call to extract the IP&#8217;s that we need and loop through them doing, but also leaving out anything in the 10xspace. We&#8217;ve taken a step back from the command line driven tool model and make a few things a bit more static, by using default arguements from the argparse package.

Before writing any more code, lets pull an API token from the Netbox server.

Here are the instructions: <https://netbox.readthedocs.io/en/stable/api/authentication/>

We&#8217;ll put this token into our application.. not the most secure way of doing this, but for simplicity &#8211; we&#8217;ll store it in a var in plain text for now. In my opinion, the authorization handled by the netbox administrator should theoretically prevent us from doing anything catastrophic when providing a user with an API token. .. in a perfect world 😉

Lets get to coding!<img loading="lazy" class="alignnone size-full wp-image-138" src="http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-19-at-1.16.50-pm.png" alt="Screen Shot 2020-05-19 at 1.16.50 PM" width="1120" height="332" srcset="http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-19-at-1.16.50-pm.png 1120w, http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-19-at-1.16.50-pm-300x89.png 300w, http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-19-at-1.16.50-pm-1024x304.png 1024w, http://localhost:8000/wp-content/uploads/2020/05/screen-shot-2020-05-19-at-1.16.50-pm-768x228.png 768w" sizes="(max-width: 1120px) 100vw, 1120px" />

I thought about passing the argsparsge args into this function and having the ability to pass in an arguement as a &#8216;tag&#8217; to filter by on the API call, but I didn&#8217;t think that was necessary. Although it could be usefull later and a quick and easy modification.

The code above shows **nb** as the pynetbox authenticated api requests. We then use the application form **&#8216;ipam.ip_addresses**&#8216; and filter by a tag, in which we pass in as an arguement on the function.

> The customer requested we skip over any device in the RFC 10 Space, so we create a conditional statement to evaluate the IP&#8217;s. Note this is a very broad catch, it should be redefined if this were production as 192, could very much contain &#8217;10.&#8217;. I would recommend adding the startswith() function and be more specific. But for now, this works.

&nbsp;

https://gist.github.com/h4ndzdatm0ld/c787191fc1fb48d509e1a69979bc73bc

&nbsp;

We loop through the IP results in which we got back from the API call and strip the subnet mask using regular expressions. We than pass the IP into our Netconf connection and proceed to get the configuration. Here is a snippet of the RegEX function to strip the /subnet mask from the IP.

https://gist.github.com/h4ndzdatm0ld/eea413ae2b76ee4a906a294664bd1f1d

Finally, I created a function that will establish the initial netcon connection and get.config. We save the netconf element to a file and open it to be able to parse the xml contents, with **xmltodict**. With this, we extract the system host name and use it as a var to create a folder directory and a file name. We save the running configuration in xml format.

https://gist.github.com/h4ndzdatm0ld/cd4bf5439acfae2133946632a10b1685
