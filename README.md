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

### dev notes

This is how to publish:

```
docker build --no-cache .

# b3735ec62760 is outputted image, from above
docker tag b3735ec62760 konsumer/androidx:latest
docker tag b3735ec62760 konsumer/androidx:playstore-30

docker push konsumer/androidx:latest
docker push konsumer/androidx:playstore-30
```