FROM docker.io/library/perl:5.40

RUN apt-get update && apt-get install -y gpsbabel vim bash-completion && apt-get clean
RUN echo "source /etc/profile.d/bash_completion.sh" >> /root/.bashrc

# Set locale to prevent perl complaining
ENV LC_ALL=C

# Install dependencies
COPY cpanfile /tmp/cpanfile
RUN cpanm --installdeps --with-develop /tmp/ && rm /tmp/cpanfile
