FROM debian:stable-slim as builder

RUN apt update && apt install wget openssl ca-certificates -y

WORKDIR /src

ARG CRYPTO_ARCH=x86_64
ENV CRYPTO_VERSION=1.14.7
ENV CRYPTO_ARCH=$CRYPTO_ARCH
ENV DOWNLOAD_URL=https://github.com/dogecoin/dogecoin/releases/download/v${CRYPTO_VERSION}/dogecoin-${CRYPTO_VERSION}-${CRYPTO_ARCH}-linux-gnu.tar.gz

RUN wget $DOWNLOAD_URL && \
    tar -xf dogecoin-${CRYPTO_VERSION}-${CRYPTO_ARCH}-linux-gnu.tar.gz && \
    mv dogecoin-${CRYPTO_VERSION}/bin/dogecoind /src/dogecoind && \
    echo ${CRYPTO_VERSION} > /src/dogecoin.version

FROM debian:stable-slim

COPY --from=builder /src/dogecoind /usr/bin/dogecoind
COPY --from=builder /src/dogecoin.version /opt/dogecoin.version

ENTRYPOINT ["/usr/bin/dogecoind"]

CMD [ "-testnet", \
      "-datadir=/blockchain/data", \
      "-rpcallowip=172.17.0.0/16", \
      "-rpcuser=user", \
      "-rpcpassword=pass", \
      "-printtoconsole=1", \
      "-prune=2500", \
      "-txconfirmtarget=2" ]
