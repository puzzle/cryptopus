FROM danlynn/ember-cli:3.28.2-node_14.18

RUN chown 1000:1000 /myapp

USER 1000

COPY ./ember-entrypoint /usr/local/bin

RUN yarn install

ENTRYPOINT ["ember-entrypoint"]
CMD [ "ember", "serve" ]
