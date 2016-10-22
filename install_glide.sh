#!/bin/bash -e

function installGlide() {
	local glideVersion="v0.12.3"
	echo "installing glide ${glideVersion}"

	wget --quiet https://github.com/Masterminds/glide/releases/download/${glideVersion}/glide-${glideVersion}-linux-amd64.tar.gz -O - | tar -xz
	sudo mv linux-amd64/glide /usr/local/bin/
}

installGlide