# Dockerfile for binder
FROM sagemath/sagemath:9.0-py3

# Copy the contents of the repo in ${HOME}
COPY --chown=sage:sage . ${HOME}