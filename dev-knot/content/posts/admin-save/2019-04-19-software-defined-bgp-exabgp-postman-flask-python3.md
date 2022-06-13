---
title: Software Defined – BGP (ExaBGP, Postman, FLASK, Python3)
author: Hugo Tinoco
type: post
draft: false
date: 2019-04-19T04:54:25+00:00
url: /2019/04/19/software-defined-bgp-exabgp-postman-flask-python3/
timeline_notification:
  - 1555649668
categories:
  - Networking
  - Automation
---

Hello,

I am currently studying for the BGP exam of the Nokia SRA certification path &#8211; while doing so, I have found an interesting way to manipulate my BGP routes &#8211; I gotta give credit to ThePacketGeek for all their information which made this possible for me.

I&#8217;m utilizing several different tools to quickly advertise routes into my EVE-NG Lab topology, which are the following:

1. Exa-BGP : <a href="https://github.com/Exa-Networks/exabgp" target="_blank" rel="noopener">Exa-Networks GitHub</a>
2. PostMan : <a href="https://www.getpostman.com/" target="_blank" rel="noopener">PostMan</a>
3. RSUB to quickly edit text from through ssh tunel on a remote server : <a href="https://stackoverflow.com/questions/37458814/how-to-open-remote-files-in-sublime-text-3" target="_blank" rel="noopener">Rsub</a>
4. Python3
5. Ubuntu VM
6. FLASK

I&#8217;ve installed UbuntuVM which is on the same network as my EVE-NG topology. Assuming you have a general understanding of the architecture, I&#8217;m going to dive right in. I&#8217;ve got a Nokia 7750 SR &#8211; VPRN with a dot1q sap facing a switch which allows a TCP connection to establish across the link to my VM hosting ExaBGP &#8211; All of this is hosted on the same physical server.

- ExaBGP
  - Install ExaBGP with PIP3.
  - Create a configuration file for  ExaBGP to connect to your router.
    - sudo vi /etc/exabgp/conf.ini

> &#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8212;&#8211;
>
> <p style="text-align:justify;">
>   process announce-routes {<br /> run /usr/bin/python3.6m /home/htinoco/exampl.py;<br /> encoder json;<br /> }<br /> process http-api {<br /> run /usr/bin/python3.6m /home/htinoco/exabg-flask/http_api.py;<br /> encoder json;<br /> }
> </p>
>
> neighbor 10.0.0.200 { # Remote Peer  
> router-id 10.0.0.25; # Local router-id  
> local-address 10.0.0.25; # Local update-source  
> local-as 65001; # local AS  
> peer-as 65000; # Peer&#8217;s AS
>
> api {  
> processes [announce-routes, http-api]; #Running multiple processes, python3 script and HTTP API(FLASK)
>
> }

---

&nbsp;

Here is the python script I&#8217;m calling under the &#8216;announce-routes&#8217; process, which is pointing to /home/htinoco/example.py;

> #!/usr/bin/env python3  
> #Change this to the correct python version you&#8217;re using.
>
> from \_\_future\_\_ import print_function
>
> from sys import stdout  
> from time import sleep
>
> #Static routes I want to always announce when I start ExaBGP  
> messages = [
>
> > &#8216;announce route 250.10.0.0/24 next-hop self&#8217;,
> > &#8216;announce route 120.20.0.0/24 next-hop self&#8217;,
> > &#8216;announce route 110.20.0.0/24 next-hop self&#8217;,
> > &#8216;announce route 150.20.0.1/24 next-hop self&#8217;,
> > &#8216;announce route 100.10.1.0/24 next-hop self&#8217;,
> > ]
>
> sleep(5)
>
> #Iterate through messages  
> for message in messages:  
> stdout.write(message + &#8216;\n&#8217;)  
> stdout.flush()  
> sleep(1)
>
> #Loop endlessly to allow ExaBGP to continue running  
> while True:  
> sleep(1)

Now, there is also another process I&#8217;m calling, which is my FLASK app.

Here is my flask app:

> from flask import Flask, request  
> from sys import stdout
>
> app = Flask(\_\_name\_\_)
>
> \# Setup a command route to listen for prefix advertisements  
> @app.route(&#8216;/&#8217;, methods=[&#8216;POST&#8217;])  
> def command():  
> command = request.form[&#8216;command&#8217;]  
> stdout.write(&#8216;%s\n&#8217; % command)  
> stdout.flush()  
> return &#8216;%s\n&#8217; % command
>
> @app.route(&#8216;/shutdown&#8217;, methods=[&#8216;POST&#8217;])  
> def shutdown():  
> shutdown_server()  
> return &#8216;Server shutting down&#8230;&#8217;
>
> #The param localhost is applied so we can reach the api remotely &#8211;
>
> if \_\_name\_\_ == &#8216;\_\_main\_\_&#8217;:  
> app.run(host=&#8221;localhost&#8221;, port=7000, debug=True)
>
> #Example POSTS using postman / (BODY/KEY:COMMAND/VALUE=)  
> #announce route 100.10.0.0/16 next-hop 172.16.2.202 med 500  
> #announce route 100.20.0.0/16 next-hop 172.16.2.202 origin incomplete as-path [100 200 400]  
> #announce route 100.30.0.0/16 next-hop 172.16.2.202 med 200 origin egp  
> #announce route 100.40.0.0/16 next-hop 172.16.1.2/32 community [65000:666]

&nbsp;

We are ready to roll! &#8211; navigate to /etc/exabgp and lets launch exabgp using the conf.ini file we created &#8211;

htinoco@ubuntu-server:/etc/exabgp$ **exabgp conf.ini**

&nbsp;

> Here is the output after starting exabgp:
>
> **: \* Serving Flask app &#8220;http_api&#8221; ( lazy loading )** > **\* Running on http://0:7000/ (Press CTRL+C to quit)** > **\* Restarting with stat** > **\* Debugger is active!** > **\* Debugger PIN: 157-288-415**
> 04:35:45 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 100.10.0.0/24 next-hop self  
> 04:35:46 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 200.20.0.0/24 next-hop self  
> 04:35:47 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 210.20.0.0/24 next-hop self  
> 04:35:48 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 220.20.0.1/24 next-hop self  
> 04:35:49 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 240.20.1.1/24 next-hop self

We see the static routes advertisted to our BGP neighbor, from our python script.

We can now open up Postman and POST new routes as we please.

<img loading="lazy" class="alignnone size-full wp-image-56" src="http://localhost:8000/wp-content/uploads/2019/04/postman.png" alt="postman" width="2459" height="745" srcset="http://localhost:8000/wp-content/uploads/2019/04/postman.png 2459w, http://localhost:8000/wp-content/uploads/2019/04/postman-300x91.png 300w, http://localhost:8000/wp-content/uploads/2019/04/postman-1024x310.png 1024w, http://localhost:8000/wp-content/uploads/2019/04/postman-768x233.png 768w, http://localhost:8000/wp-content/uploads/2019/04/postman-1536x465.png 1536w, http://localhost:8000/wp-content/uploads/2019/04/postman-2048x620.png 2048w" sizes="(max-width: 2459px) 100vw, 2459px" />

In this example, I&#8217;m using &#8220;POST&#8221; and KEY &#8220;command&#8221; (review the flask-app code)

to announce the route : announce route 44.44.24.4/32 next-hop self community [65000:666]

The out put from exabg tail process:

> 04:40:10 | 2699 | api | route added to neighbor 10.0.0.200 local-ip 10.0.0.25 local-as 65001 peer-as 65000 router-id 10.0.0.25 family-allowed in-open : 44.44.23.4/32 next-hop self community 65000:666

Now lets verify that I am seeing this route on my 7750 SR router that has the BGP session established with ExaBGP.

> <img loading="lazy" class="alignnone size-full wp-image-57" src="http://localhost:8000/wp-content/uploads/2019/04/32.png" alt="32.PNG" width="1599" height="1250" srcset="http://localhost:8000/wp-content/uploads/2019/04/32.png 1599w, http://localhost:8000/wp-content/uploads/2019/04/32-300x235.png 300w, http://localhost:8000/wp-content/uploads/2019/04/32-1024x801.png 1024w, http://localhost:8000/wp-content/uploads/2019/04/32-768x600.png 768w, http://localhost:8000/wp-content/uploads/2019/04/32-1536x1201.png 1536w" sizes="(max-width: 1599px) 100vw, 1599px" />

There they are! The static routes from our python script and the freshly announced /32 route utilizing the API POST method.

Now we have a SUPER EASY! way to pump routes into our lab environment (Or production) in order to test policies, verify proper traffic patterns, correct route installment, etc. The possibilities are endless! I am going to use this to for many other tests, such as applying MED, route manipulation with communities and just more general policy based routing.
