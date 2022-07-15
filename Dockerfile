FROM node:14

ENV NODE_PATH=/usr/local/lib/node_modules

LABEL com.github.actions.name="GitHub Action for Firebase"
LABEL com.github.actions.description="Wraps the firebase-tools CLI to enable common commands."
LABEL com.github.actions.icon="package"
LABEL com.github.actions.color="gray-dark"

ARG FIREBASE_VERSION=11.2.2
RUN npm i -g firebase-tools@${FIREBASE_VERSION}

COPY LICENSE README.md /
COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
