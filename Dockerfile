# https://hub.docker.com/r/pandoc/latex
FROM pandoc/latex:3.1-alpine
RUN apk add --no-cache plantuml msttcorefonts-installer fontconfig
RUN update-ms-fonts
RUN tlmgr install latexmk adjustbox acronym bigfoot xstring biblatex-iso690
WORKDIR /bin
# https://github.com/lierdakil/pandoc-crossref/releases
# must be compatible with pandoc version
RUN wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.15.2/pandoc-crossref-Linux.tar.xz -O - | tar -xJ
WORKDIR /.pandoc/templates
RUN wget https://raw.githubusercontent.com/exploids/pandoc-templates-hsd/master/default.latex
COPY ./data /pandoc_hsd
WORKDIR /data
ENTRYPOINT [ "/usr/local/bin/pandoc", "--defaults=/pandoc_hsd/defaults.yaml" ]
