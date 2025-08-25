#!/bin/bash
#
# Dockerized building environment for use with Thingino firmware
#
# 2022, Paul Philippov <paul@themactep.com>

APP=

install_docker() {
	echo "Installing Docker from its offical repository."
	echo "This operation requires superuser privileges."

	# install required packages
	command -v curl >/dev/null || sudo apt install curl

	# retrive official Docker repository key if missing
	local gpg_key=/usr/share/keyrings/docker-archive-keyring.gpg
	if [ ! -f "$gpg_key" ]; then
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
			sudo gpg --dearmor -o $gpg_key
	fi

	# add Docker official repository
	local distro=$(lsb_release -si | tr 'A-Z' 'a-z')
	local codename=$(lsb_release -sc)
	[ "$codename" = "trixie" ] && codename="bookworm"
	echo "deb [arch=amd64 signed-by=${gpg_key}] https://download.docker.com/linux/$distro $codename stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# update packages
	sudo apt-get update

	# install official version of Docker
	sudo apt-get --assume-yes install docker-ce docker-ce-cli containerd.io
	sudo usermod -a -G docker $USER

	need_docker=0
	APP=docker
	echo "Done"
	echo "You might need to re-login to pick up the new docker group rights."
}

install_podman() {
	echo "Installing Podman from the distro repository."
	echo "This operation requires superuser privileges."

	# update packages
	sudo apt-get update

	# install official version of Docker
	sudo apt-get --assume-yes install podman

	need_docker=0
	DOCKER=podman
	echo "Done"
}

# Check for podman/docker
need_docker=0
if command -v podman >/dev/null; then
	echo "Found Podman"
	APP=podman
elif command -v docker >/dev/null; then
	echo "Found Docker"
	APP=docker

	docker_ver=$(docker -v | awk -F '[ ,.]' '{print $3}')
	if [ "$docker_ver" -lt 20 ]; then
		echo "Installed Docker is outdated."
		need_docker=1
	fi
else
	echo "No Podman or Docker was found."
	need_docker=2
fi

while [ "$need_docker" -gt 0 ]; do
	echo
	read -p "Do you want to install Podman? [y/n] " yn
	case $yn in
		[yY]*)
			install_podman
			;;
		[nN]*)
			echo "Aborted."
			exit 1
			;;
		*)
			echo "Please answer only yes or no."
	esac
done

while [ "$need_docker" -gt 0 ]; do
	read -p "Do you want to install Docker from its official repository? [y/n] " yn
	case $yn in
		[yY]*)
			install_docker
			;;
		[nN]*)
			echo "Aborted."
			exit 1
			;;
		*)
			echo "Please answer only yes or no."
	esac
done

# Build a Docker image with selected development environment
$APP build -t thingino-dev .

[ -d workspace/thingino ] || git clone --recurse-submodules \
	https://github.com/themactep/thingino-firmware.git \
	workspace/thingino

[ -z "$BR2_DL_DIR" ] && BR2_DL_DIR="$(pwd)/workspace/downloads"

[ -d "$BR2_DL_DIR" ] || mkdir -p "$BR2_DL_DIR"

# Run container in interactive mode and mount the source files in it
case "$APP" in
	docker)
		echo me:x:$(id -u):$(id -g):My User:/home/me:/bin/bash >passwd
		$APP run --rm -it --user $(id -u):$(id -g) \
			-v $(pwd)/passwd:/etc/passwd:ro \
			-v $(pwd)/workspace:/home/me \
			-v $BR2_DL_DIR:/home/me/downloads \
			thingino-dev:latest
		;;
	podman)
		$APP run --rm -it --userns=keep-id \
			-v $(pwd)/workspace:/home/me \
			-v $BR2_DL_DIR:/home/me/downloads \
			thingino-dev:latest
		;;
esac

exit 0
