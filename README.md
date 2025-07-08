# Introduction
This repository holds a Docker container for running SonicWall's ConnectTunnel on not officially supported systems (e.g.
nixos).

## Requirements:
- Docker
- super user privileges
- The `run.sh` scripts expects two files in the working directory containing the username and the password for
connecting to the vpn: `.username.secret`, `.password.secret`.

## Usage
Build the container from the project's directory with
```bash
docker build -t sonicwall-connect-tunnel .
`````````````````````````````````

Then simply run it with
```bash
sudo ./run.sh
```

## Troubleshoot
Sometimes the vpn might fail to connect and ask for the credentials again, simply restart the script and try again until
it works.
