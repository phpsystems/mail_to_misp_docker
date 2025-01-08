FROM python:3.8.10
WORKDIR /app

# Setup an app user so the container doesn't run as the root user
RUN useradd misp

#
# Setup Dependencies.
#

RUN apt update && \
    apt -y install cmake python3-setuptools && \
    pip install setuptools 

RUN cd /app && \
    git clone https://github.com/stricaud/faup.git && \
    cd faup && \
    mkdir -p build && \
    cd build && \
    cmake .. && make && \
    make install && \
    cd ../src/lib/bindings/python && \
    python3 setup.py install && \
    echo '/usr/local/lib' | tee -a /etc/ld.so.conf.d/faup.conf && \
    ldconfig
#
# Set UP mail_to_misp
#

RUN cd /app && \
    git clone https://github.com/MISP/mail_to_misp.git && \
    cd mail_to_misp && \
    pip install --no-cache-dir -r requirements.txt && \
    mkdir -p /config && \
    chown misp:misp /config && \
    ln -s /config/mail_to_misp_config.py && \
    ln -s /config/fake_smtp_config.py && \
    if [ ! -f /config/mail_to_misp_config.py ]; then cp mail_to_misp_config.py-example /config/mail_to_misp_config.py; fi 

RUN cd /app/mail_to_misp && \ 
    apt-get -y install libfuzzy-dev && \
    pip install poetry O365 pymisp pymisp[email] pymisp[fileobjects] pymisp[openioc] pymisp[url] pymisp[virustotal] lief && \
    mv pyproject.toml pyproject.toml.orig && \
    cat pyproject.toml.orig | grep -v O365 > pyproject.toml && \
    poetry lock && poetry install -E fileobjects -E openioc -E virustotal -E email -E url

RUN cd /app/mail_to_misp && mkdir -p certs && chown -R misp certs

USER misp
# Copy in the source code
EXPOSE 25

COPY --chmod=755 entrypoint.sh /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
