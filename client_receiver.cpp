#include <util.hpp>
#include <iot/socket.hpp>

#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <iostream>

int main() {
    // set client IP address
    uwe::set_ipaddr("192.168.1.67");

    int server_port = 8877;

    struct sockaddr_in server_address; // data structure for storing IPv4 or IPv6 addresses
	memset(&server_address, 0, sizeof(server_address));
	server_address.sin_family = AF_INET; // IPv4 address

    // htons: port in network order format
	server_address.sin_port = htons(server_port);

    // creates binary representation of server name and stores it as sin_addr
	inet_pton(AF_INET, uwe::get_ipaddr().c_str(), &server_address.sin_addr);

    uwe::socket sock{AF_INET, SOCK_DGRAM, 0};

    sock.bind((struct sockaddr *)&server_address, sizeof(server_address));


    struct sockaddr_in client_address;
    size_t client_address_len = 0;
    
    char buffer[1024];
    int len = sock.recvfrom(buffer, sizeof(buffer),0, (struct sockaddr *)& client_address, &client_address_len);

    //inet_ntoa returns user friendly representation of the ip address
    buffer[len] = '\0';
    printf("received: '%s' from client %s\n", buffer, inet_ntoa(client_address.sin_addr));
    }

    return 0;
}
    