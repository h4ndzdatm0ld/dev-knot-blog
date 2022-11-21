---
title: Are you using rMate?
author: Hugo Tinoco
type: post
draft: true
date: 2019-12-12T05:58:51+00:00
url: /2019/12/12/are-you-using-rmate/
timeline_notification:
  - 1576130334
categories:
  - DevOps
  - Automation
---

A good friend of mine, Randall, would always joke with me about using Nano and rMate instead of vi. He's an awesome programmer and incredibly smart &#8211; So, I've always listened to every piece of advice he's given me &#8211; but, I simply couldn't let go of using rMate instead of nano or vi.

rMate is a way to edit remote files via a reverse SSH tunnel on your local machine via SublimeText.

This is WAY easier to navigate long scripts or text files, instead of using a terminal. Besides, you can keep the file open in a sublime text tab and any and all changes save and transfer to your remote server via the secure tunnel.

## Clone rMate on remote server:

##### _&#8211; I personally cloned the aurora rmate. There are a few out there._

<a href="https://github.com/aurora/rmate" target="_blank" rel="noopener">https://github.com/aurora/rmate</a>

<pre>sudo wget -O /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rmate</pre>

Once you get the files from the github, go ahead and edit the permissions.

## Install the SublimeText package:

Open the Package Manager in Sublime Text. search for &#8216;rsub' and install it.

Ctrl+Shift+P / Linux-Win

Cmd+Shift+P / Mac

Now, lets open a command line on your local host and connect to a remote server to edit a remote file on your local install of sublime text.

### **ssh -R 52698:localhost:52698 {{username}}@{{remote-server}}**

For my example, I'm going to remote into my local netbox server, with the following command from my WSL instance.

<img loading="lazy" class="alignnone size-full wp-image-112" src="http://localhost:8000/wp-content/uploads/2019/12/ssh.png" alt="ssh" width="894" height="98" srcset="http://localhost:8000/wp-content/uploads/2019/12/ssh.png 894w, http://localhost:8000/wp-content/uploads/2019/12/ssh-300x33.png 300w, http://localhost:8000/wp-content/uploads/2019/12/ssh-768x84.png 768w" sizes="(max-width: 894px) 100vw, 894px" />

&nbsp;

Here is a quick video, demonstrating how easy it is to edit a file locally from a remote server:

&nbsp;

There are many more ways to use this cool little tool.

Check out the github and the following arguments &#8211; I've personally have set up several aliases on my workstation to be able to easily ssh to common servers I manage and have the ability to call rsub on files.

Example:

Create an alias by editing the .bashrc file and adding the previous ssh command, but this way &#8211; you can standardize the use of rsub by adding the &#8216;r' behind the dns name of the server. You don't always want to SSH with a reverse tunnel, so having the option to do, is much nicer &#8211; besides, this is an insane amount of text to input simply to ssh. My brain doesn't want to do that, the million times a day I ssh into devices.

alias rnetbx='ssh -R 52698:localhost:52698 htinoco@10.0.0.116&#8242;

> root@Snowblind-Tower:/mnt/c# nano ~/.bashrc  _**\## Sorry Randall**_
> root@Snowblind-Tower:/mnt/c# source ~/.bashrc
> root@Snowblind-Tower:/mnt/c# rnetbx   _**\## <&#8212;&#8212;&#8212;The new alias**_
> The authenticity of host &#8216;10.0.0.116 (10.0.0.116)' can't be established.
> ECDSA key fingerprint is SHA256:XkjSNWW8a6Nri7m5wdV5KBpdXdTT9DDD+SxZa//2qic.
> Are you sure you want to continue connecting (yes/no)?

### Arguments

    -H, --host HOST  Connect to HOST. Use 'auto' to detect the host from SSH.
    -p, --port PORT  Port number to use for connection.
    -w, --[no-]wait  Wait for file to be closed by TextMate.
    -l, --line LINE  Place caret on line number after loading file.
    +N               Alias for --line, if N is a number (eg.: +5).
    -m, --name NAME  The display name shown in TextMate.
    -t, --type TYPE  Treat file as having specified type.
    -n, --new        Open in a new window (Sublime Text).
    -f, --force      Open even if file is not writable.
    -v, --verbose    Verbose logging messages.
    -h, --help       Display this usage information.
        --version    Show version and exit.

&nbsp;

I didn't know about this tool until recently. I hope this helps someone and makes your day easier!
