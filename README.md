# androidx

Easy graphical Android emulaton in docker, if you are using X on the host (requires linux.)

## usage

You can run a graphical API-30 playstore emulator with this:

```
docker run --rm -it \
    --device /dev/kvm \
    -e "DISPLAY=${DISPLAY:-:0.0}" \
    -v ${XAUTHORITY}:/root/.Xauthority \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    konsumer/androidx
```

after that, if you want to connect via adb:

```
docker ps

docker exec -it ID_FROM_ABOVE adb shell
```

### volumes

There are 2 volumes you can use for persistance of your emulator (and faster boot):

- `/opt/android/system-images` - this is where the huge system-images are located
- `/root/.android` - this ios where the emulator settings are located, and they are also pretty big

So, to put all together with persistance:

```
docker run --rm -it \
    --device /dev/kvm \
    -e "DISPLAY=${DISPLAY:-:0.0}" \
    -v ${XAUTHORITY}:/root/.Xauthority \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v emulator/system-images:/opt/android/system-images \
    -v emulator/settings:/root/.android \
    konsumer/androidx
```


### dev notes

This is how to publish:

```
docker build --no-cache .

# 0c7d8d985c67 is outputted image, from above
docker tag 0c7d8d985c67 konsumer/androidx:latest
docker tag 0c7d8d985c67 konsumer/androidx:playstore-30

docker push konsumer/androidx:latest
docker push konsumer/androidx:playstore-30
```