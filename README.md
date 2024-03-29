# socket
Author: Ana Paula Goncalves 

## Description
</details>
This project aims to create a socket which is able to send a message from the client side and receive the same message already decrypted. The project should be able to run continually and support any number of users. The server should also send the message received back to the client. 

## Usage
To compile the program type 'make' into the terminal. To run the program, first run './build/receiver',to run the task 1 client_receiver file, or './build/server' to run the optimized version (task 2) and then run the client_send file by typing './build/client'.

## Production  
In the Makefile i have implemented the following:
The Makefile is very similar to the makefile previously created in worksheet 1. The main differrent is the file that are being compiled and run, as shown in the image below:

![IMAGE_DESCRIPTION](Makefile.png)

In this version, the files being compiled are client_send.cpp as APP, client_receiver.cpp as RECEIVER and receiver2.cpp as RECEIVER2.

<hr>

In the client_send.cpp i have made the following changes, these changes have been made to optimize the client_send file so that the client can now received the message that is echoed back to itself from the server. 

![IMAGE_DESCRIPTION](client_.png)

I have also implemented a 4th file (receiver2.cpp), this file is an improvement on the client_receiver file. As this file continually receives messages from the client and echo a message back to the client.

![IMAGE_DESCRIPTION](server.png)

This was achieved by adding the while loop and telling it to run while true.

## Program outcome 
This is what the outcome of this program should look like. 

For task 1:
![IMAGE_DESCRIPTION](task_1.png)

in this image we can see that the server sucessfully received the message from the client, however, the client does not continually run and the server does not send the message back to the client.

For task 2:
![IMAGE_DESCRIPTION](task_2.png)

In this image we can see that the server is now continuously running as well as the client receiving multiple messages from the client. we are also able to see on the client side (right) that the server is also echoing a message back.

## Project status
completed 
