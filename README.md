# Custom Ansible Semaphore on Docker (Free Ansible Tower)

* Taken from https://github.com/ansible-semaphore/semaphore
* [Ansible Tower](http://docs.ansible.com/ansible/tower.html) (formerly ‘AWX’) is a web-based solution that makes Ansible even more easy to use for IT teams of all kinds. It’s designed to be the hub for all of your automation tasks.

## Prerequisites

* Install [Docker Engine](https://docs.docker.com/engine/installation/)
* Choose an option:

*Option 1:* Create SSL certificates by running the next command:

```shell
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout proxy/cert/semaphore.key \
    -out proxy/cert/semaphore.crt
```

*Option 2:* Enable variable [CERT](docker-compose.sh) and change [cert_subject](docker-compose.sh) as needed.

```shell
CERT=true
cert_subject="/C=Country/ST=State/L=City/O=Organization/CN=Common.Name"
```

## Configuration

* Review and change file [`docker-compose.sh`](docker-compose.sh).
* Review and change file [`nginx.conf`](./proxy/nginx.conf).

## Start infrastructure

* **Run:** `./docker-compose.sh`
* Deprecated (missing container launch priority): `docker-compose up`

## Accessing via browser

* SSL disabled: `http://<domain_name>`
* SSL enabled: `https://<domain_name>`
