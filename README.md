# Docker Debian Build Image

A Debian image that includes the standard build tools.

Avoids setting up build tools for all source installs. 

## Usage

```
FROM deployable/debian-build:8

RUN set -uex ;\
    cd /tmp ;\
    curl https://app.com/release/1.2.3.tar.gz | tar -xvf - ;\
    cd 1.2.3 ;\
    ./configure ;\
    make install ;\
    rm -rf /tmp/1.2.3
``` 

