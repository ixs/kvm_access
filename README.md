# kvm_access
Docker container with NoVNC, Palemoon, Flash and JRE8 (Webstart/Apple) for KVM Access to legacy hardware

Yes, this is as terrible as it sounds. But throwing away working hardware just because the vendor EOL'd it is worse.

# What it looks like
<img width="85%" alt="screenshot" src="https://github.com/user-attachments/assets/e6eb5e21-3b50-4414-885d-8634b101e628" />

# Contents
 - Fedora 43 (latest and greatest OS release)
 - Pale Moon 33.9.1 SSE2 gtk3 (SSE2 build to allow running on rosetta2-enabled MacOS)
 - Oracle JDK 8u261 (linux/x64) (last JRE release with applet functionality)
 - CleanFlash 34.0.0.137 (last release for Linux)


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
 - Disable JRE Upate nags.
 - Fix openbox menu error
 - Work on some better authentication if this wants to be run centrally by an engineering team

# Thanks
Inspired by https://github.com/paimpozhil/docker-novnc/
