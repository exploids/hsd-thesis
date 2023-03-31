FROM pandoc/latex:latest
RUN tlmgr install latexmk adjustbox acronym bigfoot xstring
WORKDIR /.pandoc/templates
RUN wget https://raw.githubusercontent.com/exploids/pandoc-templates-hsd/master/default.latex
COPY ./data /pandoc_hsd
WORKDIR /data
ENTRYPOINT [ "/usr/local/bin/pandoc", "--defaults=/pandoc_hsd/defaults.yaml" ]
