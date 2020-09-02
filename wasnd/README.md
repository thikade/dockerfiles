# WebSphere Application Server traditional and Docker

Under this directory you can find build scripts for Docker images (Dockerfiles) and related documentation for WebSphere Application Server traditional.

* [WebSphere Application Server for Developers traditional](developer)
* WebSphere Application Server traditional
  * [Base](base)
  * [Network Deployment](nd)

## Network Deployment Build Instructions for v8.5
### Prerequisites
- You will need WAS v85 binaries, obviously. Package to install will be the latest one available in the repository
  (in this example: 8.5.5.13)
- The build-script expects your repo file to contain repositories for the following package ids. These are docker build arguments and can be overriden in the compose-file build-section
    - WAS_VERSION=com.ibm.websphere.ND.v85
    - JDK_VERSION=com.ibm.websphere.IBMJAVA.v80

    e.g.:
  I am using a caddy container that serves these binaries from a bind-mount location "/INSTALL"
  See http://github.com/thikade/dockerfiles/caddy

- Build script expects these files in the following locations:
  - `${WEB_URL}/WASND/WASND_v8.5.5_1of3.zip`
  - `${WEB_URL}/WASND/WASND_v8.5.5_2of3.zip`
  - `${WEB_URL}/WASND/WASND_v8.5.5_3of3.zip`
  - `${WEB_URL}/WASND/85513/BASE/`
  - `${WEB_URL}/WASND/JDK8/8056/`

### RUN

- `./runme_was85_complete.sh http://192.168.0.100:8080`

### RESULTS
At the end you should have the following images in your `docker images` list:
- wasnd85-noprofile: WASv85 installed, but no profiles created; ie, our base image!
- wasnd85-dmgr: from base-image, with DMGR Profile (empty cell, no nodes added yet)
- wasnd85-node01: from base-image, with Custom Profile "node01" (will federate on `docker run`)
- wasnd85-node02: from base-image, with Custom Profile "node02" (will federate on `docker run`)
- Final and federated cell images:
  - wasnd85-cell-dmgr
  - wasnd85-cell-node01
  - wasnd85-cell-node02



## Network Deployment Build Instructions for v9
### Prerequisites
- You will need WAS v9 binaries, obviously. Package to install will be the latest one available in the repository
  (in this example: 9.0.0.7)

  I am using a caddy container that serves these binaries from a bind-mount location "/INSTALL"
  See http://github.com/thikade/dockerfiles/caddy

- The build-script expects your repo file to contain repositories for the following package ids. These are docker build arguments and can be overriden in the compose-file build-section
  - WAS_VERSION=com.ibm.websphere.ND.v90
  - JDK_VERSION=com.ibm.java.jdk.v8

  e.g.:
  - `${WEB_URL}/WASND/9000/BASE/`
  - `${WEB_URL}/WASND/9007`
  - `${WEB_URL}/WASND/JDK-80511/`

### RUN

- `./runme_was9_complete.sh http://192.168.0.100:8080`

### RESULTS
At the end you should have the following images in your `docker images` list:
- wasnd9-noprofile: WASv85 installed, but no profiles created; ie, our base image!
- wasnd9-dmgr: from base-image, with DMGR Profile (empty cell, no nodes added yet)
- wasnd9-node01: from base-image, with Custom Profile "node01" (will federate on `docker run`)
- wasnd9-node02: from base-image, with Custom Profile "node02" (will federate on `docker run`)
- Final and federated cell images:
  - wasnd9-cell-dmgr
  - wasnd9-cell-node01
  - wasnd9-cell-node02
