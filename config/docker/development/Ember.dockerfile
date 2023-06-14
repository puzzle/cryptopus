FROM danlynn/ember-cli:4.11.0-node_18.14

RUN chown 1000:1000 /myapp

COPY ./ember-entrypoint /usr/local/bin

USER 1000

RUN yarn install

ENTRYPOINT ["ember-entrypoint"]
CMD [ "ember", "serve" ]
