# How to install?
Put `CustomQueue` inside Workspace or ServerScriptService
# How do I customize the queue screen?
Inside `CustomQueue` there is a ModuleScript named `Setup`, you can edit value's there such as font, position, size, ...
# What if I'm already using Private Servers?
If the jobId the client sent is not a valid 36 character jobId string then the GUI will not appear, therefore if you are using your private server for other purposes the Custom Queue will not activate. The same can not be said on your scripting side. 
<br> For compatibility reasons a StringValue called `IsQueueServer` will be created and set to `true` whenever a client gives a jobId to the server.
# Found a bug?
Report it in Issues, I will try my best to fix them.
