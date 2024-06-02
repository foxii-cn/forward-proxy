FROM ubuntu:latest as builder
WORKDIR /workspace
RUN apt-get update -qq && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing jq wget curl xz-utils ca-certificates && \
wget -t5 -T10 -O caddy-forwardproxy-naive.tar.xz \
$(curl --retry 10 --connect-timeout 60 --silent 'https://api.github.com/repos/klzgrad/forwardproxy/releases/latest' | jq -r '.assets[].browser_download_url') && \
tar xvf caddy-forwardproxy-naive.tar.xz --strip-components 1

FROM scratch
COPY --from=builder /workspace/caddy /usr/bin/caddy
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs/
VOLUME ["/etc/naive"]
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/naive/Caddyfile", "--adapter", "caddyfile"]
