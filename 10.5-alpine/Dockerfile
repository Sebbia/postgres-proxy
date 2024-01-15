FROM postgres:10.5-alpine

COPY postgres-entrypoint.sh /
RUN [ -f /usr/local/bin/postgres-entrypoint.sh ] && rm /usr/local/bin/postgres-entrypoint.sh || true
RUN ln -s /postgres-entrypoint.sh /usr/local/bin/postgres-entrypoint.sh

ENTRYPOINT ["postgres-entrypoint.sh"]
CMD ["postgres"]