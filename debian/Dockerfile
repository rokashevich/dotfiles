FROM debian
RUN apt update \
&& apt -y install --no-install-recommends --no-install-suggests \
curl \
git \
jq \
&& rm -rf /var/lib/apt/lists/*