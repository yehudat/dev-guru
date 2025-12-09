## Table of Terms and Acronyms

| Term/Acronym | Description |
|--------------|-------------|
| Docker | An open-source platform that automates the deployment, scaling, and management of applications using containerization. Containers package an application and its dependencies into a standardized unit for software development. |
| Container | A lightweight, standalone, and executable software package that includes everything needed to run a piece of software, including the code, runtime, libraries, and system tools. |
| Docker Image | A read-only template used to create Docker containers. Images include the application and all its dependencies. |
| Dockerfile | A script containing a series of instructions on how to build a Docker image. Each instruction in a Dockerfile creates a layer in the image. |
| Docker-in-Docker (DinD) | A Docker setup where a Docker container runs inside another Docker container. This is often used in CI environments to build and test Docker images within a containerized pipeline. |
| GitLab Runner | An application that works with GitLab CI/CD to run jobs in a pipeline. Runners can be configured to run in different environments, including Docker containers. |
| Nginx | A high-performance HTTP server and reverse proxy server. In the context of Docker, Nginx can be used to route traffic to different containers based on the request. |
| Reverse Proxy | A server that sits between client devices and a web server, forwarding client requests to the web server and returning the server’s responses to the clients. Nginx is commonly used as a reverse proxy. |
| TCP Socket | An endpoint for sending or receiving data across a computer network using the Transmission Control Protocol (TCP). TCP sockets provide reliable, ordered, and error-checked delivery of a stream of data between applications. |
| Unix Socket | A data communication endpoint for exchanging data between processes running on the same operating system. Unix sockets are faster than TCP sockets for inter-process communication on the same host because they bypass the network stack. |
| Bridge Network | A default network driver in Docker that allows containers to communicate with each other through a virtual network bridge. Each container connected to the bridge network gets an IP address, and they can communicate using these IPs. |
| Host Network | A networking mode in Docker where a container shares the network stack of the host system. This means the container’s network interfaces are directly connected to the host’s network interfaces. |
| Overlay Network | A distributed network that Docker uses to enable communication between containers running on different Docker hosts. Overlay networks are commonly used in Docker Swarm setups. |

## Differences Between TCP Sockets and Unix Sockets

Understanding the differences between TCP sockets and Unix sockets is crucial, especially when configuring inter-process communications in Docker environments.

### Communication Scope

•	Unix Sockets: Used for communication between processes on the same host system. They are ideal for local inter-process communication (IPC) without involving the network stack.
•	TCP Sockets: Designed for communication between processes over a network, allowing interaction between applications on different machines or across different networks.

### Performance

•	Unix Sockets: Generally offer better performance for local IPC because they bypass the network stack, resulting in lower latency and overhead.
•	TCP Sockets: Incur more overhead due to the complexities of network protocols, making them slightly slower for local communications compared to Unix sockets.

### Security
•	Unix Sockets: Access is controlled by file system permissions, allowing fine-grained control over which processes can communicate.
•	TCP Sockets: Security is managed through network configurations and firewall rules, which can be more complex to configure correctly.

### Use Cases

•	Unix Sockets: Commonly used for local services like databases (e.g., MySQL, PostgreSQL) where client and server reside on the same machine.
•	TCP Sockets: Suitable for services that need to be accessible over a network, such as web servers and networked applications.

## Networking Between Containers

In a Dockerized CI environment, understanding how containers communicate is essential. Let’s explore the typical topology and networking configurations:

### Host Machine

•	Runs the Docker daemon, which manages containers.
•	May host services like Nginx to route traffic to various containers.

### GitLab Runner

•	A service that executes CI/CD jobs.
•	Can be configured to run inside a Docker container on the host machine.

### Docker-in-Docker (DinD) Container

•	A Docker container that runs its own Docker daemon inside.
•	Used by GitLab Runner to create isolated environments for building and testing Docker images.

### Build Containers

•	Spawned by the DinD instance to perform specific CI/CD tasks, such as building Docker images or running tests.

## Communication Flow

### Host to Nginx (Reverse Proxy)

•	The host machine runs Nginx, which listens for incoming HTTP requests.
•	Nginx forwards these requests to appropriate services running in containers based on routing rules.
•	Nginx to Services:
•	Nginx communicates with service containers using Unix sockets or TCP sockets, depending on configuration.
•	Unix sockets are preferred for performance when Nginx and the service containers are on the same host.

### GitLab Runner to DinD

•	GitLab Runner interacts with the DinD container to spawn build containers.
•	This interaction typically uses TCP sockets, with the DinD daemon listening on a specific port.

### DinD to Build Containers

•	The DinD daemon manages build containers, assigning them IP addresses within a bridge network.
•	Build containers can communicate with each other over this bridge network using their assigned IPs.

## Why Use Reverse Proxies and Prefixes?

### Reverse Proxy (Nginx)

•	Simplifies routing by directing incoming requests to the appropriate containerized services.
•	Enhances security by acting as a single point of entry, allowing for centralized access control and SSL termination.

### Prefixes in DinD

•	When using DinD, build containers may need to access services running on the host or other containers.
•	Prefixes (e.g., specifying http://host.docker.internal) help containers resolve and connect to services correctly, especially when DNS resolution is complex in nested Docker environments.