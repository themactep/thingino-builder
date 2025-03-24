Development Environment for Thingino firmware
---------------------------------------------

[Podman][2] container for developing [Thingino firmware][1]
in a standardized and reproducible environment.

```
git clone https://github.com/themactep/docker-worker.git ~/thingino-builder
cd ~/thingino-builder
./run.sh
```

When inside the container, run `make` to start building the firmware.

[1]: https://github.com/themactep/thingino-firmware
[2]: https://podman.io/
