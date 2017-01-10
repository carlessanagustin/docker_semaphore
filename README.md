# Custom Ansible Semaphore on Docker (Free Ansible Tower)

* Taken from https://github.com/ansible-semaphore/semaphore
* [Ansible Tower](http://docs.ansible.com/ansible/tower.html) (formerly ‘AWX’) is a web-based solution that makes Ansible even more easy to use for IT teams of all kinds. It’s designed to be the hub for all of your automation tasks.

## Prerequisites

* Install [Docker Engine](https://docs.docker.com/engine/installation/)
* Create SSL certificates by running the command:

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout proxy/cert/semaphore.key \
    -out proxy/cert/semaphore.crt
```

## Configuration

* Review and change file [`docker-compose.sh`](docker-compose.sh).
* Review and change file [`nginx.conf`](./proxy/nginx.conf).

## Running

* **Active**

```
./docker-compose.sh
```

* Deprecated (missing container launch priority)

```
docker-compose up
```

## Accessing

* SSL disabled: http://localhost
* SSL enabled: https://localhost

* Only when semaphore_api ports are enabled: http://localhost:8081

```
semaphore_api:
  ports:
    - 8081:3000
```
