Development Environment for Thingino firmware
---------------------------------------------

[Podman][2] container for developing [Thingino firmware][1]
in a standardized and reproducible environment.

```
sudo apt update
sudo apt install podman

git clone https://github.com/themactep/thingino-builder.git ~/thingino-builder
cd ~/thingino-builder
./run.sh
```

If you want to compile from stable branch then run
```
git checkout stable
make update
```

To launch a compilation run
```
make
```

_Use `make cleanbuild` for a clean mutithreaded compilation._

[1]: https://github.com/themactep/thingino-firmware
[2]: https://podman.io/
