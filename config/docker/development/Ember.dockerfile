FROM danlynn/ember-cli:latest

COPY ./ember-entrypoint /usr/local/bin

RUN yarn install

ENTRYPOINT ["ember-entrypoint"]
CMD [ "ember", "serve" ]
