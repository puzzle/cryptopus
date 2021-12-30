FROM danlynn/ember-cli:latest

USER 1000

COPY ./ember-entrypoint /usr/local/bin

RUN yarn install

ENTRYPOINT ["ember-entrypoint"]
CMD [ "ember", "serve" ]
