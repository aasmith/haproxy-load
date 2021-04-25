# Setup specific to the proxy role

if [ ! -d "~/haproxy-2.3" ]; then
  git clone -b master http://git.haproxy.org/git/haproxy-2.3.git/ --depth=1
  pushd haproxy-2.3
  make clean && make TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE2=1 \
    CC=/usr/bin/gcc-10 CPU_CFLAGS="-march=armv8.2-a+fp16+rcpc+dotprod+crypto -mtune=neoverse-n1 -O3" CPU=custom V=1
  ./haproxy -vv
  popd
fi

if [ ! -d "~/haproxy-dev" ]; then
  mkdir haproxy-dev
  curl -L "https://github.com/haproxy/haproxy/tarball/master" | tar -zx --strip-components=1 -C haproxy-dev
  pushd haproxy-dev
  make clean && make TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE2=1 \
    CC=/usr/bin/gcc-10 CPU_CFLAGS="-march=armv8.2-a+fp16+rcpc+dotprod+crypto -mtune=neoverse-n1 -O3" CPU=custom V=1
  ./haproxy -vv
  popd
fi
