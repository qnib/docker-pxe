docker-pxe
==========

DHCP server to provide boot via PXE

## Start the container
```
$ docker run --privileged -ti --rm --net=none --name pxe -h pxe \
             -v /tftp/:/data/tftp -v /repo:/data/repo \
             qnib/pxe:latest bash
```

## Attach network device

```
<DOCKER_HOST> # pipework eth0 $(docker inspect -f '{{ .Id }}' pxe) 192.168.1.3/24@192.168.1.1
```
