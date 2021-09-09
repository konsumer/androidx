> *MOVED* This was some experiments around phone-hacking that have all been organized and moved to [phone-home](https://gitlab.com/gummicube/phone-home)

## usage

### emulator

The emulator is meant to connect to the X-server of the host (or you can also start a VNC X-server in another docker, and give it access via display.)

first build it like this:

```
docker build -t androidx:30 --build-arg API=30 .

docker build -t androidx:31 --build-arg API=31 .
```

On a linux host, you can start it like this:

```
docker run -it \
    --privileged \
    --device /dev/kvm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    -h $HOSTNAME \
    -v $HOME/.Xauthority:/home/lyonn/.Xauthority \
    androidx:30
```

Currently, this doesn't quite work.

Something to look into is [x11docker](https://github.com/mviereck/x11docker).

```
./x11docker -i  --runasroot="emulator @playstore-30" \
    --share=/dev/kvm \
    --share=/etc/group:ro \
    --share=/etc/passwd:ro \
    --share=/etc/shadow:ro \
    androidx:30
```

I am also working on `docker-compose up`.



#### useful commands

- `docker exec -it androidx bash` - this will give you a shell after you have run the parent. You can use this with `adb`/`frida`/`objection`/etc
