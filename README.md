# Docker Ubuntu VNC

A lightweight (519 MB) Linux workstation based on [Ubuntu](https://ubuntu.com/). Provides a **graphical desktop**, and **VNC** / **SSH** access.

## Main packages

* **xfce4**   : Graphic desktop environment
* **x11vnc**  : X vnc server
* **sshd**    : SSH server

## Users

| User   |
| ------ |
| root   |
| marek  |

## To locally build the image from the `Dockerfile`


```sh
docker build --progress=plain -t marekbykowski/ubuntu-vnc:22.04 .
```

If you want to build from pristine, eg. re-copy an updated file to an image then run with `--no-cache`
```sh
docker build --no-cache --progress=plain -t marekbykowski/ubuntu-vnc:22.04 .
```

If any of your commands in Dockerfile require proxy provide it with the build as this
```sh
docker build --build-arg HTTP_PROXY="http://proxy-us.intel.com:911" --build-arg HTTPS_PROXY="https_proxy=http://proxy-us.intel.com:912" --progress=plain -t marekbykowski/ubuntu-vnc:22.04 .
```

```sh
docker build --no-cache --build-arg HTTP_PROXY="http://proxy-us.intel.com:911" --build-arg HTTPS_PROXY="https_proxy=http://proxy-us.intel.com:912" --progress=plain -t marekbykowski/ubuntu-vnc:22.04 .
```

---

## Usage (full syntax)

**Full syntax:**

```sh
$ docker run [-it] [--rm] [--detach] [-h HOSTNAME] -p LVNCPORT:5900 -p LSSHPORT:22 [-e XRES=1280x800x24] [-e TZ={TZArea/TZCity}] [-v LDIR:DIR] marekbykowski/ubuntu-vnc:22.04
```

where:

* `LVNCPORT`: Localhost VNC port for attaching remote VNC port 5900.

* `LSSHPORT`: local SSH port for attaching remote SSH port 22. You may need to use a *non reserved* port such as port 2222. *Well known ports* (those below 1024) may be reserved by your system.

* `XRES`: Screen resolution and color depth. Default: `1200x800x24`

* `TZ`: Local Timezone Area/City, e.g. `Etc/UTC`, `America/Mexico_City`, etc.

* `LDIR:DIR`: Local directory to mount on container. `LDIR` is the local directory to export; `DIR` is the target dir on the container.  Both sholud be specified as absolute paths. For example: `-v $HOME/worskpace:/home/ubuntu/workspace`.

### Examples

```sh
docker run --rm --name marek --hostname my-docker -p 7660:22 -p 7661:5900 -p 7662:6080 --privileged -e XRES=1920x966x24 marekbykowski/ubuntu-vnc:22.04
```

#### To run a ***secured*** VNC session

This container is intended to be used as a *personal* graphic workstation, running in your local Docker engine. For this reason, no encryption for VNC is provided.

If you need to have an encrypted connection as for example for running this image in a remote host (*e.g.* AWS, Google Cloud, etc.), the VNC stream can be encrypted through a SSH connection:

```sh
$ ssh [-p SSHPORT] [-f] -L 5900:REMOTE:5900 ubuntu@REMOTE sleep 60
```
where:

* `SSHPORT`: SSH port specified when container was launched. If not specified, port 22 is used.

* `-f`: Request SSH to go to background afte the command is issued

* `REMOTE`: IP or qualified name for your remote container

This example assume the SSH connection will be terminated after 60 seconds if no VNC connection is detected, or just after the VNC connection was finished.

**EXAMPLES:**

* Establish a secured VNC session to the remote host 140.172.18.21, keep open a SSH terminal to the remote host. Map remote 5900 port to local 5900 port. Assume remote SSH port is 22:

```sh
$ ssh -L 5900:140.172.18.21:5900 ubuntu@140.172.18.21
```

* As before, but do not keep a SSH session open, but send the connecction to the background. End SSH channel if no VNC connection is made in 60 s, or after the VNC session ends:

```sh
$ ssh -f -L 5900:140.172.18.21:5900 ubuntu@140.172.18.21 sleep 60
```

Once VNC is tunneled through SSH, you can connect your VNC viewer to you specified localhot port (*e.g.* port 5900 as in this examples).


## To stop the container

* If running an interactive session:

  * Just press `CTRL-C` in the interactive terminal.

* If running a non-interactive session:

  * Just press `CTRL-C` in the console (non-interactive) terminal.


 ## Container usage

1. First run the container as described above.

2. Connect to the running host (`localhost` if running in your computer):

	* Using VNC:

		Connect to specified LVNCPORT (e.g. `localhost:0` or `localhost:5900`)

	* Using SSH:

		Connect to specified host (e.g. `localhost`) and SSHPORT (e.g. 2222)

		```sh
		$ ssh -p 2222 ubuntu@localhost
		```

## Additional files

    ./etc/supervisor.conf

### File contents:

```
[supervisord]
nodaemon = true
user = root
# loglevel = debug

[program:sshd]
command = /usr/sbin/sshd -D

[program:xvfb]
command = /usr/bin/Xvfb :1 -screen 0 %(ENV_XRES)s
priority=100

[program:x11vnc]
environment = DISPLAY=":1",XAUTHLOCALHOSTNAME="localhost"
command=/usr/bin/x11vnc -repeat -xkb -noxrecord -noxfixes -noxdamage -wait 10 -shared -permitfiletransfer -tightfilexfer
autorestart = true
priority=200

[program:startxfce4]
environment = USER="ubuntu",HOME="/home/ubuntu",DISPLAY=":1"
command = /usr/bin/startxfce4
autorestart = true
directory = /home/ubuntu
user = ubuntu
priority = 300
```
