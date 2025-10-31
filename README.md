# kvm_access

Docker container with NoVNC, Palemoon, Flash and JRE8 (Webstart/Apple) for KVM Access to legacy hardware

Yes, this is as terrible as it sounds. But throwing away working hardware just because the vendor EOL'd it is worse.


# Contents

 - Fedora 43
 - Pale Moon 33.9.1 SSE2 gtk3
 - Oracle JDK 8u261 (linux/x64)
 - CleanFlash 34.0.0.137


# Notes

This is a build in progress and should be seen as a tech-preview.
The docker container can be generated using `./build.sh` and then started with `./run.sh`.
Access is then possible at http://localhost:6080/.

# Host Whitelist

In order to save some clicks on confirming security exceptions, there's a function to whitelist a number of
hosts on container startup.
Populate the `host_whitelist` file accordingly

# Todo

 - Whitelisting of entries
   - Flash Access
 - Fix openbox menu error
 - Work on some better authentication if this wants to be run centrally by an engineering team


# Thanks

Inspired by https://github.com/paimpozhil/docker-novnc/
