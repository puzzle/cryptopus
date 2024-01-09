FROM danlynn/ember-cli:5.2.1-node_18.17

RUN chown 1000:1000 /myapp

COPY ./ember-entrypoint /usr/local/bin

USER 1000

RUN yarn install

ENTRYPOINT ["ember-entrypoint"]
CMD [ "ember", "serve" ]
