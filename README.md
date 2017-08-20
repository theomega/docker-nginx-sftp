docker-nginx-sftp
=================

Purpose
-------
The image provides an http server which serves static files. The static files
can be modified using sftp. This is done by launching both, an http server
(nginx) and an sftp server (openssh-sftp) inside the docker container. The
static files can be persisted on a volume to make the surive restarts of the
container.

Usage
-----
To run this container use

     docker run -ti -e USER=myuser -e PASSWORD=mypassword -p 2222:22 -p 8888:80 -v
     /tmp/data_for_container:/data -v /tmp/keys_for_container:/etc/ssh/keys/
     bdominik/docker-nginx-sftp:latest

Configuration
-------------
There are two environment variables which you have to provide when launching the
container to specify the username and the password which can then be used to log
into the sftp server. These are called `USER` and `PASSWORD.

Volumes
-------
You can mount two volumes to the docker-images as in the example above:

  * `/data` is the folder which contains the static files which are served from
    the nginx http server and can be modified via sftp.
  * `/etc/ssh/keys` is the folder which contains the ssh host keys for the sftp
    server. If the host keys are not existing, they are created on start. If you
    don't mount this volume, you will get new ssh host keys everytime the
    container launches which will lead into connection error for the users of
    the sftp server.

Internals
---------
The internals of this image are quiet straight forward. The container is based
on alpine linux and contains the following additional packages:
  * `openssh-server` and `openssh-sftp-server` to provide the sftp server
  * `nginx` to provide the http server
  * `supervisord` to orchestrate the two processes (nginx + openssh) and keep
    them running.
The packages are configured using the configuration files in this repo.
Supervisord is configured to fail the whole container is either of the two
processes fail. All the logging goes to the docker output, so you will see both,
the nginx access log and the sftp connection output.

Anti-Pattern
------------
To have two processes in a docker container is an anti-pattern, so think twice
before using this image. The normal way to do this would be to have two separate
docker images, one for the sftp server and one for the http server and have a
shared volume. This container takes another approach for experimentation
purposes.
