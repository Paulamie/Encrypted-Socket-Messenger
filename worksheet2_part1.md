bcdm---
title: "UFCFVK-15-2 Internet of Things"
author: []
date: "2024-22-01"
keywords: [Guide]
header-includes:
  - \hypersetup{colorlinks=false,
            allbordercolors={0 0 0},
            pdfborderstyle={/S/U/W 1}}
...

# An echo of communication :: Worksheet(2 part 1) 

Marking scheme

- Task 1 - 60%
- Task 2 - 40%


Worksheet 2 is worth up to 50% of this component. Part 1 is worth 30%, while part 2 is worth 70%, of the overall mark for worksheet 2.

> All work is handed in via Git/GitLab.

> Note, for all worksheet submissions, you must add the following staff to yours repos, as maintainers, and submit the git repo's URL to blackboard. 

- f4-barnes 
- br-gaster
- c-duffy
- nj2-desmond
- q-mastoi 

> You must not submit files or othermaterial, related to the worksheets, to Blackboard, only the repo's URL. Failing to do these steps, could mean your work is not marked.

Before staring this worksheet, if you have not already done so, complete the setup process. Instructions for this are on Blackboard under Learning Materials/Setup. You should have also completed worksheet 1.

## Sockets

### Summary 

A socket is a mechanism that allows communication between processes, be it programs running on
the same machine or different computers connected on a network. More specifically, Internet sockets
provide a programming interface to the network protocol stack that is managed by the operating
system. Using this API, a programmer can quickly initialise a socket and send messages without
having to worry about issues such as packet framing or transmission control.

There are a number of different types of sockets available, but we are going to focus  in two
types of Internet sockets:

- Stream sockets
- Datagram sockets

What differentiates these two socket types is the transport protocol used for data transmission.
A stream socket uses the Transmission Control Protocol (TCP) for sending messages. TCP provides
an ordered and reliable connection between two hosts. This means that for every message sent, TCP
guarantees that the message will arrive at the host in the correct order. This is achieved at the
transport layer so the programmer does not have to worry about this, it is all done for you.

A datagram socket uses the User Datagram Protocol (UDP) for sending messages. UDP is a much
simpler protocol as it does not provide any of the delivery guarantees that TCP does. Messages, called
datagrams, can be sent to another host without requiring any prior communication or a connection
having been established. As such, using UDP can lead to lost messages or messages being received
out of order. It is assumed that the application can tolerate an occasional lost message or that the
application will handle the issue of retransmission.

> We will focus on UDP socket programming for this worksheet, but it is impotant to know about TCP, as it is a very popular protocol, and widely used today. 

There are advantages and disadvantages to using either protocol and it will be highly dependant of
the application context. For example, when transferring a file you want to ensure that, upon receipt,
the file has not become corrupted. TCP will handle all the error checking and guarantee that it will
arrive as you sent it. On the other hand, imagine you are sending 1000 messages detailing player
position data every second in a computer game. The application will be able to tolerate missing
messages here so UDP would be more suitable.

Over recent years it has become clear that they are a number of shortcommings with TCP, in particular, when building TLS on top. For example, HTTPS 2 uses TSL to provide encrypreted transmission on top of HTTP, which is itself built on TCP, and it has been shown that there are a number of performance issues with this approach. HTTP 3, instead, builds on top of UDP to address many of these shortcommings. (This is covered in more detail, in lecture 6.)

### Addressing

Internet Sockets allow us to identify a host using an IP address and a port number. The IP address
uniquely identifies a machine while the port number identifies the application we want to contact at
that machine. There are a range of well known port numbers, such as port 80 for HTTP, in the range
0 - 1023. When choosing port numbers, anything above the well know port number range should be
fine, but you cannot guarantee that another application will not be already using it.

> For the worksheets we are going to use IPv4 addresses, but in general, it makes sense to move towards using IPv6. (This too is discussed in the lectures, in particular lectures 4 and 5.)

For this worksheet we assume IP4 addresses. The IPv4 address is a 32-bit number that uniquely identifies a network interface on a machine. An IPv4 address is typically written in decimal digits, formatted as four 8-bit fields separated by periods. Each 8-bit field represents a byte of the IPv4 address. This form of representing the bytes of an IPv4 address is often referred to as the dotted-decimal format.

The bytes of the IPv4 address are further classified into two parts: the network part and the host part. The following figure shows the component parts of a typical IPv4 address, 192.168.1.7:

![](./ipaddress_format.png)

The network part specifies the unique number assigned to your network. It also identifies the class of network assigned.

The host part is the part of the IPv4 address that is assigned to each host. It uniquely identifies this machine on the local network. 

> Note that for each host on a local network, the network part of the address will be the same, but the host part must be different.

Port numbers below 1000 are reserved by the OS, e.g. 23 is SSH.

The two tasks of the first part of worksheet 2, given below, will introduce programming with sockets, using an API developed at UWE, that mirrors traditional Berkely sockets, but provides some additional tools, and avoids issues with reusing ports. This API will be introduced as you work through the tasks, however, it is documented [here](https://blackboard.uwe.ac.uk/bbcswebdav/pid-10295756-dt-content-rid-44439922_2/xid-44439922_2) and something you will need to refer to.

# Tasks

Unlike worksheet 1 you are expected to create your own git repo, stored on Gitlab, and develop C++ source files, along with a makefile to build your work.

> HINT: It is recommened that you use the makefile from worksheet 1 as starting point, however, you are free to develop one from scratch.

As per worksheet 1, it is important that you document your work in your repo's ```README.md```, this is included in the marking scheme and is an imporant aspect of all the worksheets.

It is recommended at this point that you create a new repo on Gitlab, clone it onto the remote server and change into that directory. The following instructions assumes that you have done this and have access to a terminal where you can run commands in that directory.

### Task 1

In this task you will use a UDP socket to send a message to another process, which will use a socket to receive the message. Later we will extend this to be a so called echo client and server. 

> To correctly complete these tasks you must use the provided library and not another one from the internet.

The supporting libary, include files, and scripts for this worksheet can be found in:

```bash
/opt/iot/include/
  channel.hpp  
  gui.hpp  
  iot/socket.hpp
  packets.hpp  
  util.hpp
/opt/iot/lib
  libiot.a
/opt/iot/bin
  chat_client  
  chat_server  
  udp_client  
  udp_server 
  iotdump
  create_packetfile  
  packets_clear
```

The include directory is where you will find headers useful for completing the tasks, along with the library, ```libiot.a```. The bin directory includes binaries that demostate the behaviour of tasks for worksheet 2, both parts, and finally the last two, ```create_packets``` and ```packets_clear```, are utility scripts that will be useful for managing IP:port pairs for communicating between your client and servers.

In task 3, we will consider using C++ threads, but for now we will assume that the client and server are running as seperate processes, and thus can be implemented as their own programs. Let's kick things off with the client. Create a C++ source file and begin editing, and let's add the headers we will need: 

```c++
#include <util.hpp>
#include <iot/socket.hpp>

#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

```

The first two headers are part of the IoT library, while the next two are standard Linux headers for creating IP addresses, with the correct network byte order, and so on. The later two are just standard C/C++ headers for I/O and string handling.

Inside the main function we first assign an IP address to our virtual machine:

```c++
int main() {
    // set client IP address
    uwe::set_ipaddr("192.168.1.7");
```

This is used by the socket API when sending messages from this machine, we will do something similar when writing the server code.

Next we need to create a IP address and port number, so the socket knows where to send our message, and it must be encoded in network byte order.

```c++
    const int server_port = 8877;
    const char* server_name = "192.168.1.8";

    sockaddr_in server_address; // data structure for storing IPv4 or IPv6 addresses
	memset(&server_address, 0, sizeof(server_address));
	server_address.sin_family = AF_INET; // IPv4 address

	// creates binary representation of server name and stores it as sin_addr
	inet_pton(AF_INET, server_name, &server_address.sin_addr);

    // htons: port in network order format
	server_address.sin_port = htons(server_port);
```

Now we create the UDP socket, which is implied by the argument ```SOCK_DGRAM```, note again the use of ```AF_INET```, to imply an IPv4 address:

```c++
    uwe::socket sock{AF_INET, SOCK_DGRAM, 0};
```

Now we have a socket that we can send messages over, we need bind it to over client's address:

```c++
	// port for client
	const int client_port = 1001;

    // socket address used for the client
	struct sockaddr_in client_address;
	memset(&client_address, 0, sizeof(client_address));
	client_address.sin_family = AF_INET;
	client_address.sin_port = htons(client_port);
	inet_pton(AF_INET, uwe::get_ipaddr().c_str(), &client_address.sin_addr);

	sock.bind((struct sockaddr *)&client_address, sizeof(client_address));
```

Finally, we just need to send our message to the server:

```c++
	// data that will be sent to the server
	std::string message = "This is an IOT packet";

    // send data
	int len = sock.sendto(
        message.c_str(), message.length(), 0,
	    (sockaddr*)&server_address, sizeof(server_address));


    return 0;
}
```

Write a makefile to compile this program to an executable. In general, this should be very similar to the makefile you wrote for worksheet 1, however, you need to add some additional options for compiling the C++ source, where to find the headers, and when linking, where to find the libary. So you should have:

```makefile
CPPFLAGS = -std=c++17  -I/opt/iot/include -D__DEBUG__=1
LDFLAGS = -lpthread -L/opt/iot/lib -liot
```

Note, that we have added the path to where the include files are, and also we included some libraries, one for Linux threads, and one for the library provided for this module.


At this point we can try to run out client, but even without the fact that we are not yet running our server, so there is no process to receive our message, there is another issue to do with setting up our virtual IP layer. For example, here is the out of running what we have so far:

```bash
./task1_client 
could not open file ./packets/iotpacket_192.168.1.7_1001
could not open file ./packets/iotpacket_192.168.1.8_8877
Segmentation fault (core dumped)
```

As the UWE IoT layer is emulating the IP and physcial layer of the OSI network model, we need to give it some additonal help, before it will work. In particular, we need to create the streams for sending and receviving data over the socket. You will note in the above output that two files, in the local directory cannot be opened. The name of these files are built from the client and servers, respective IP addresses and port numbers. These files used to pass information between the different processes sending and receiving via a given socket. 

> Remeber an IP address specifices a machine, while a port locates a specific socket.

As noted above there are two scripts for working with packet streams:

```bash
/opt/iot/bin
  create_packetfile  
  packets_clear
```

The first script is used to create a packet stream, given an IP address and port number, and the second clears a given stream.

For now we need to first create the directory ```./packets``` and then run the command:

```bash
/opt/iot/bin/create_packetfile 192.168.1.7 1001
```

to create the packet stream for our client. Run the command again, but now for the server. Your ```packets``` directory should now look like:

```bash
ls packets/
iotpacket_192.168.1.7_1001 iotpacket_192.168.1.8_8877
```

It's worth noting at this point that both files are empty, you can see this in the following:

```bash
ls -l packets/
total 0
-rw-rw-r-- 1 benedict.gaster@uwe.ac.uk benedict.gaster@uwe.ac.uk 0 Jan 23 11:25 iotpacket_192.168.1.7_1001
-rw-rw-r-- 1 benedict.gaster@uwe.ac.uk benedict.gaster@uwe.ac.uk 0 Jan 23 11:25 iotpacket_192.168.1.8_8877
```

Now run our client again:

```bash
./a.out
```

The error message is now resolved and if we check the size of the files in packets:

```bash
./task1_client
ls -l packets/
-rw-rw-r-- 1 benedict.gaster@uwe.ac.uk benedict.gaster@uwe.ac.uk  0 Jan 23 11:25 iotpacket_192.168.1.7_1001
-rw-rw-r-- 1 benedict.gaster@uwe.ac.uk benedict.gaster@uwe.ac.uk 85 Jan 23 11:28 iotpacket_192.168.1.8_8877
```

Note, that now the servers packet stream is no longer 0, and if we look at its contents:

```bash
cat ./packets/iotpacket_192.168.1.8_8877 
AgAD6cCoAQcAAAAAAAAAAAIAIq3AqAEIAAAAAAAAAAAD6SKtABWqVVRoaXMgaXMgYW4gSU9UIHBhY2tldA==
```

We see it contains some form of encoded data. In fact, the data is encoded in [Base64](https://en.wikipedia.org/wiki/Base64), a binary to text encoding, to avoid issues with binary data in text files. Just to confirm this makes sense we can quickly, although not completly satisfactorily, decode with:

```bash
echo AgAD6cCoAQcAAAAAAAAAAAIAIq3AqAEIAAAAAAAAAAAD6SKtABWqVVRoaXMgaXMgYW4gSU9UIHBhY2tldA== | base64 --decode
���"���"��UThis is an IOT packet
```
We can see our message that we sent, but also there is a bunch of information that was encoded as binary, that cannot be displayed on the console. To make this process easier we can use the provide packet dump utility:

```bash
/opt/iot/bin/iotdump
```

This tool has a number of useful command line options, that will be useful for later part of worksheet 2, but for now we can use it to simply decode the UDP packet and its associated data, i.e. our message. To see what command line options it supports simple run the command:

```bash
/opt/iot/bin/iotdump
USAGE: /opt/iot/bin/iotdump --udp_cs --udp_header --udp_msg --ip -s <number> -c <number> --chat -f <packet_filename>
```

```--chat``` is for part 2 of the worksheet, for now we will use:

```bash
--ip    display IP address for source and destination (IP layer)
--udp_header            display UDP header for a packet
--udp_msg               display UDP data for a packet
--udp_cs                Run the UDP checksum to validate the packet
-f <packet_filename>    Path to packet file
-s <number>             Packet index to start from (default 0)
-c <number>             Maximum number of packets to read (default 1)
```

For now we just want to display the message and IP addresses, so:

```bash
/opt/iot/bin/iotdump --ip --udp_msg -f ./packets/iotpacket_192.168.1.8_8877 
IP:     192.168.1.7     192.168.1.8
**This is an IOT packet**
```

We can see that for the IP layer the source and destenation address are displayed, while our message is prefixed with ```**``` and postfixed with ```**```, as it makes it easier to see our message clearly.

Excellent, now it's time to implement the server, to be able to receive the sent message.

For this you will need to:

1. Implement a new .cpp file for the receiver
2. Extend your makefile to build the receiver
3. Check that it works by running the client and receiver

For the first part your code should look similar to the client, however, you will need to use the method:

```c++
ssize_t socket::recvfrom(void * buf, size_t len, int flags, sockaddr * src_addr, size_t *addrlen);
```

to wait and receive data from the client. Once you have received the data you should print the received message and the IP address of the receiver, with something like:

```c++
    // inet_ntoa returns user friendly representation of the ip address
    buffer[len] = '\0';
    printf("received: '%s' from client %s\n", buffer,
            inet_ntoa(client_address.sin_addr));
```
Here ```buffer``` and ```len``` are the location of the data, which was passed to ```revvfrom``` and its length, respectively.

> Note, that ```revvfrom``` does not null terminate the data, and so you must do so before passing to printf.

Before running you should clear our any old packets with the command:

```bash
/opt/iot/bin/packets_clear
```

The following screen shot shows an example of running the server and then client:

![](./ss_send_receive.png)

Finally, to complete this task, document your work in the README.md.

## Task 2

1. Extend your server to run continually and support any number of clients.
2. Add support for the server to send back the message received, i.e. echo it back, and for the client to wait until it receives the echoed message and prints it to the console.

Document your work in the README.md.