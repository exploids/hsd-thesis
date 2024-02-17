# https://hub.docker.com/r/pandoc/latex
FROM pandoc/latex:3.1-alpine
# msttcorefonts-installer and fontconfig are required by plantuml
RUN apk update && apk add --no-cache msttcorefonts-installer fontconfig
# plantuml somehow won't work without doing that
RUN update-ms-fonts
# chromium, npm is required by mermaid
# java and graphviz are required by plantuml
RUN apk add --no-cache font-noto-emoji font-adobe-source-code-pro font-liberation chromium npm
# install mermaid
ENV CHROME_BIN="/usr/bin/chromium-browser" \
	PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
RUN npm install -g @mermaid-js/mermaid-cli --unsafe-perm=true --allow-root
# install packages for latex
RUN tlmgr install adjustbox acronym bigfoot xstring nowidow upquote microtype pdfpages
# install plantuml
RUN apk add --no-cache openjdk17-jre graphviz
ENV PLANTUML_VERSION=1.2023.8
WORKDIR /opt/plantuml
RUN wget "https://github.com/plantuml/plantuml/releases/download/v$PLANTUML_VERSION/plantuml-$PLANTUML_VERSION.jar" -O plantuml.jar
RUN wget "http://beta.plantuml.net/elk-full.jar"
# install pandoc-crossref
WORKDIR /bin
# https://github.com/lierdakil/pandoc-crossref/releases
# must be compatible with pandoc version
RUN wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.15.2/pandoc-crossref-Linux.tar.xz -O - | tar -xJ
# pull adjusted pandoc template 
WORKDIR /.pandoc/templates
RUN wget https://raw.githubusercontent.com/exploids/pandoc-templates-hsd/master/default.latex
# add files
COPY ./root /
# make sure fonts are working
RUN fc-cache --really-force
WORKDIR /data
RUN mkdir -p /cache/hsd-thesis && chmod 777 /cache/hsd-thesis
ENV FILTER_CACHE=/cache/hsd-thesis
ENTRYPOINT [ "/usr/local/bin/pandoc", "--defaults=/pandoc_hsd/defaults.yaml" ]
