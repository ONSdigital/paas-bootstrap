FROM ubuntu

RUN apt-get update && apt-get install -y bash jq curl wget ssh
RUN apt-get install -y awscli
RUN wget -O /usr/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 \
&& chmod +x /usr/bin/bosh
RUN wget -O cf-cli.deb 'https://packages.cloudfoundry.org/stable?release=debian64&version=6.36.1&source=github-rel' \
  && dpkg -i cf-cli.deb \
  && rm -f cf-cli.deb 
