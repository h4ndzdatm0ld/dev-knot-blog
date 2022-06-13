---
title: Securing SSH with MFA(Google Auth) on Ubuntu
author: Hugo Tinoco
type: post
date: 2019-10-12T16:25:29+00:00
url: /2019/10/12/securing-ssh-with-mfagoogle-auth-on-ubuntu/
timeline_notification:
  - 1570897534
categories:
  - "Networking"
  - "Security"
---

<img loading="lazy" class="alignnone size-full wp-image-96" src="http://localhost:8000/wp-content/uploads/2019/10/barcode.png" alt="barcode" width="652" height="459" srcset="http://localhost:8000/wp-content/uploads/2019/10/barcode.png 652w, http://localhost:8000/wp-content/uploads/2019/10/barcode-300x211.png 300w" sizes="(max-width: 652px) 100vw, 652px" />

This short article will go over how I&#8217;m practicing defense in depth to secure my Linux SSH access for critical infrastructure. We will install Google-Auth on a Ubuntu Server-19 and store the Scratch Codes in our LastPass Vault.  LastPass is utilizing my YubiKey which FIDO2, FIDO U2F, one-time password (OTP), OpenPGP and smart card, choice of form factors for desktop or laptop as a form of MFA to authenticate to the cloud service.  For my AuthCodes I will also be using LastPass Authenticator, even though I am installing Google Auth on the Ubuntu instance.  Finally, for those who use SecureCRT, there is one configuration change to make to your saved sessions for ease of use and compatibility.

Last Pass has a free option available and you can find Google Authenticator on your device&#8217;s App Store/Play Store. Yubikey is a paid hardware device.

**What is MFA?**

Multi-factor authentication combines two or more independent credentials: what the user knows ([password][1]), what the user has ([security token][2]) and what the user is ([biometric verification][3]). The goal of MFA is to create a layered defense and make it more difficult for an unauthorized person to access a target such as a physical location, computing device, network or database. If one factor is compromised or broken, the attacker still has at least one more barrier to breach before successfully breaking into the target.

Source: [TechTarget][4]

**What is Defense in Depth?**

<span class="ILfuVd"><span class="e24Kjd"><b>Defense in Depth</b> (DiD) is an approach to cybersecurity in which a series of <b>defensive</b> mechanisms are layered in order to protect valuable data and information.<br /> </span></span>

Source: [ForcePoint][5]

Lets get started by SSH&#8217;ing into your Ubuntu machine. I am performing these steps on a Ubuntu Server 19. There are some additional steps in securing cloud instances, such as Digital Ocean headless droplets. I will not be covering such configuration.

Step 1:  Install G-Auth &#8211; The tools for MFA.

> htinoco@pi-hole:~$ sudo apt install libpam-google-authenticator

Step 2: Setup MFA on local user account.

> htinoco@pi-hole:~$ google-authenticator

At this point, carefully read through the prompts and select the options that make more sense to you. Open your Authenticator App of choice and scan the MFA QR Code that is on your screen.

Now, lets concentrate on properly storing the following information before finishing the configuration.

> Your new secret key is: 2445XXXXJ5L6MQ575PXXXXXX  
> Your verification code is XX29XX  
> Your emergency scratch codes are:  
> 8659XXXX  
> 7X0672XX  
> 5608XXXX  
> 268233XX  
> 1X890XXX

Store these scratch codes somewhere safe &#8211; Do not save these on the same local device, in case of lose or theft. I will save these to my LastPass Vault.

First, lets authenticate to LastPass using YubiKey. This is where the DiD comes in to play &#8211; Maybe I&#8217;m stretching the DiD definition here, but simply writing these codes down and throwing them in a drawer is not a good backup plan.

Insert the YubiKey to your local machine &#8211; Pictured is John Wick, ensuring no dogs are harmed during this blog.

<img loading="lazy" class="alignnone size-full wp-image-98" src="http://localhost:8000/wp-content/uploads/2019/10/20191012_153753250_ios.jpg?w=8064" alt="20191012_153753250_iOS.jpg" width="4032" height="3024" />

Now lets authenticate to LastPass  &#8211; I have previously setup my YubiKey to work as an MFA device under my LastPass account settings. See documentation on LastPass website for a quick how-to.

<img loading="lazy" class="alignnone size-full wp-image-99" src="http://localhost:8000/wp-content/uploads/2019/10/lpmfa.png" alt="lpmfa.PNG" width="1657" height="762" srcset="http://localhost:8000/wp-content/uploads/2019/10/lpmfa.png 1657w, http://localhost:8000/wp-content/uploads/2019/10/lpmfa-300x138.png 300w, http://localhost:8000/wp-content/uploads/2019/10/lpmfa-1024x471.png 1024w, http://localhost:8000/wp-content/uploads/2019/10/lpmfa-768x353.png 768w, http://localhost:8000/wp-content/uploads/2019/10/lpmfa-1536x706.png 1536w" sizes="(max-width: 1657px) 100vw, 1657px" />

Once fully authenticated, lets store the scratch keys somewhere safe. I personally created a &#8216;Home Network&#8217; folder inside the &#8216;SSH KEYS&#8221; section labeled &#8220;SCRATCH CODES&#8221;, sorted by machine host name.

_Make sure to put some thought into how want to organize your LastPass Vault._

Okay, lets get back to the nuts n bolts of the MFA configuration for SSH on the Ubuntu server.

## **Lets edit the SSHd config file and change the default <span style="text-decoration:underline;">&#8220;ChallengeResponseAuthentication&#8221;</span> to Yes.**

> htinoco@pi-hole:~$ sudo nano /etc/ssh/sshd_config
>
> \# Change to yes to enable challenge-response passwords (beware issues with  
> \# some PAM modules and threads)  
> ChallengeResponseAuthentication yes      # Change this default from no to yes!
>
> \# Kerberos options  
> #KerberosAuthentication no  
> #KerberosOrLocalPasswd yes  
> #KerberosTicketCleanup yes  
> #KerberosGetAFSToken no

Next, simply restart the SSH service:

> sudo systemctl restart ssh

Now lets edit the PAM file &#8211; The <span class="ILfuVd"><span class="e24Kjd"><b>Linux</b>&#8211;<b>PAM</b> (short for Pluggable Authentication Modules which evolved from the Unix-<b>PAM</b> architecture) is a powerful suite of shared libraries used to dynamically authenticate a user to applications (or services) in a <b>Linux</b> system.</span></span>

> sudo vi /etc/pam.d/sshd
>
> **#At the very bottom of the file, add the following line:**
>
> <p style="text-align:justify;">
>   auth required pam_google_authenticator.so
> </p>

That&#8217;s it! You can test this feature by simply running &#8216;ssh localhost&#8217; and you should see the following after authenticating with your password:

> htinoco@pi-hole:~$ ssh localhost  
> Password:  
> Verification code:                                #<<<<< Very COOL!

Now, as I said, if you&#8217;re like me and have hundreds of sessions saved on your SecureCRT application &#8211; here is what you&#8217;ll need to do to ensure a smooth login with MFA:

&nbsp;

<img loading="lazy" class="alignnone size-full wp-image-102" src="http://localhost:8000/wp-content/uploads/2019/10/ssh.png" alt="ssh.PNG" width="1061" height="629" srcset="http://localhost:8000/wp-content/uploads/2019/10/ssh.png 1061w, http://localhost:8000/wp-content/uploads/2019/10/ssh-300x178.png 300w, http://localhost:8000/wp-content/uploads/2019/10/ssh-1024x607.png 1024w, http://localhost:8000/wp-content/uploads/2019/10/ssh-768x455.png 768w" sizes="(max-width: 1061px) 100vw, 1061px" />

1. Right click on your saved session for the Ubuntu Server with MFA.
2. Select Properties
3. Category: SSH2
4. Category: Authentication
   1. Select Keyboard Interactive
   2. Select OK.

This will allow for SecureCRT to handle the Verification Code prompt:

<img loading="lazy" class="alignnone size-full wp-image-103" src="http://localhost:8000/wp-content/uploads/2019/10/mfa2.png" alt="mfa2.PNG" width="871" height="275" srcset="http://localhost:8000/wp-content/uploads/2019/10/mfa2.png 871w, http://localhost:8000/wp-content/uploads/2019/10/mfa2-300x95.png 300w, http://localhost:8000/wp-content/uploads/2019/10/mfa2-768x242.png 768w" sizes="(max-width: 871px) 100vw, 871px" />

There ya have it! you should be logged in now utilizing MFA.

If you ever lose your cell phone with the authenticator app, you can always retrieve the scratch codes from your LastPass Vault that&#8217;s encrypted on a cloud service &#8211; So it will always be available to you.. make sure you don&#8217;t lose your YubiKey the same night..

Always make sure to have a backup!

Thanks for reading,

Hugo Tinoco

&nbsp;

&nbsp;

[1]: https://searchsecurity.techtarget.com/definition/password
[2]: https://searchsecurity.techtarget.com/definition/security-token
[3]: https://searchsecurity.techtarget.com/definition/biometric-verification
[4]: https://searchsecurity.techtarget.com/definition/multifactor-authentication-MFA
[5]: https://www.forcepoint.com/cyber-edu/defense-depth
