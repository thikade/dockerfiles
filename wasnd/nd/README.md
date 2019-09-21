# Building an IBM WebSphere Application Server Network Deployment traditional container image from binaries

An IBM WebSphere Application Server Network Deployment traditional image can be built by obtaining the following binaries:
* IBM Installation Manager binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html)

  IBM Installation Manager 1.8.5 (Linux x86-64) binaries:
  * agent.installer.lnx.gtk.x86_64_1.8.5.zip

* IBM WebSphere Application Server Network Deployment traditional binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)

  IBM WebSphere Application Server Network Deployment traditional V8.5.5 binaries:
  * WASND_v9*.zip (Cxxxxxxx)

  Fixpack V9.0.0.X binaries:
  * 9.0.0-WS-WAS-FP00000X.zip

  IBM WebSphere SDK Java Technology Edition V7.1.3.0 binaries:
  * 8.0.5.40-WS-IBMWASJAVA.zip

## An IBM WebSphere Application Server Network Deployment traditional install image is created in few steps:

1. Edit file .env and specify version (and WAS version ID) you want to install  
1. docker-compose-build-was9.yml
2. run wasnd/runme_was9_complete.sh


The shell script `runme_was9_complete` will perform the following actions:
- expect a caddy running container serving install, with WAS binaries server under URL specified in .env
- Check for existing image: wasnd9-noprofile:${IMAGE_VERSION}
  - if no image is found, it will build it by running docker-compose:
    `docker-compose -f docker-compose-build-was9.yml build wasnd_chained_build`
    The resulting image contains the WAS ND installation inside `/opt/IBM/WebSphere/ApplicationServer`
  -
