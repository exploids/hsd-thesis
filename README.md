# hsd-thesis

A tool for compiling scientific works at the University of Applied Sciences Düsseldorf.

## Development

The image can be built locally using:

```sh
docker build . -t exploids/hsd-thesis:latest
```

You can access a shell within the image using:

```sh
docker run --rm -it --entrypoint /bin/sh exploids/hsd-thesis
```

## Credits

The CSL citation styles have been taken from the [Zotero Style Repository](https://www.zotero.org/styles?q=iso690).
