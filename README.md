# androidx

Easy graphical Android emulaton in docker, if you are using X on the host (requires linux.)

## usage

You can run a graphical API-30 playstore emulator with this:

```
docker run --rm -it \
    --device /dev/kvm \
    -e "DISPLAY=${DISPLAY:-:0.0}" \
    -v ${XAUTHORITY}:/root/.Xauthority \
    -v /tmp/.X11-unix:/tmp/.X11-unix\
    konsumer/androidx 
```

after that, if you want to connect via adb:

```
docker exec -it konsumer/androidx adb shell
```