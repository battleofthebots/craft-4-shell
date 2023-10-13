# Mine4shell

This challenge requires challengers to log into a minecraft server and send a chat message to trigger the log4shell vulnerability. They also need to implement an LDAP and HTTP server to host the malicious class file.

## Infra

The container downloads the minecraft 1.16.5 server from Mojang, copies over the local JRE version 8u43, and installs the healthcheck binary. It also copies the server.properties config file with optimizations for performance. When running, the minecraft server starts on port 25565

## Static Challenges
Question: What is the protocol version number in decimal?
Answer: 754
Question: What is the protocol version number encoded as a VarInt? Write your format as a hex string without 0x
Answer: f205


## Building
```sh
docker build -t craft-4-shell .
```

## Running
```sh
docker run -it --memory=1g -p 25565:25565 --ulimit nofile=65536:65536 craft-4-shell
```

## Solution

To get command execution, one needs to set up an LDAP and HTTP server to serve a malicious class file, similar to all log4shell exploits. Recommended toolkits are: https://github.com/artsploit/rogue-jndi and https://github.com/black9/Log4shell_JNDIExploit (confirmed working with PoC). More details about manual exploitation are in a comment in the python script
The intended chain is Login -> Chat message -> LDAP redirect to HTTP Server -> Command Execution

## Exploiting
The -i flag should be the ip of the machine that the exploit is run on. If it is not 172.17.0.1, change the IP in the message variable. The jar file comes from the above repository, confirmed working with java 8, unsure about other versions.
```sh
java -jar JNDIExploit-1.2-SNAPSHOT.jar -i 172.17.0.1
python ExploitPwntools.py
```

## Troubleshooting

#### For all questions:
Make sure that they are looking at the documentation for the proper version (Found here https://wiki.vg/index.php?title=Protocol&oldid=16681)
Make sure that their lengths are all correct, the packet length should the size of the packet without the length
Make sure you are properly converting values to a VarInt like here https://wiki.vg/VarInt_And_VarLong
Make sure that you send keep alive packets when needed

#### Is your minecraft player connected to the server? 
To Confirm: make sure "username joined the game" message in chat after login start packet
If not:
Make sure that they have the correct protocol version (754) for minecraft 1.16.5, and
Make sure that their username is max length 16, and is alphanumeric

#### Is your message not appearing in chat?
To confirm: nothing appears in chat after chat packet sent
Make sure that they have properly sent at least one keep alive packet within 10 seconds of the server sending it's keep alive packet
Double check lengths, they are super tricky!
Try a normal chat message before any log4shell trickery

#### Are you not receiving any hits on your LDAP/HTTP server?
To confirm: Nothing is sent on port 1389
Make sure that the chat message is sending properly, maybe preface the exploit with a couple characters to see if you receive something back
Make sure that you are sending the ldap request to an ip reachable by from the box
Make sure it is responding with a redirect to the correct location of the HTTP server