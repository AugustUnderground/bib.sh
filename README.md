# Bibliography.Shell

My script for retrieving Citations from the commandline.
Query [Google Books](https://developers.google.com/books) from the Terminal and retrieve BibTex or Roff/Refer Citation.

## Dependecies

+ [curl](https://curl.haxx.se/)
+ [jq](https://stedolan.github.io/jq/)
+ [fzy](https://github.com/jhawthorn/fzy) or [fzf](https://github.com/junegunn/fzf)

## Usage

```bash
$ ./bib.sh layout design scheible
```

This will pipe the titles retrieved from [Google Books](https://developers.google.com/books)
into fzf/fzy. After selecting one, you'll get the BibTex reference
printed to stdout.

```tex
@book{  label = scheible19,
        title = "Fundamentals of Layout Design for Electronic Circuits",
        author = "Jens Lienig", "Juergen Scheible" ,
        publisher = "Springer Nature",
        year = "2020-03-19"
}
```

To append a reference to a bibliography simply redirect the output to that file:

```bash
$ ./bib.sh -l layout design scheible >> library.bib
```

After selecting the source, there wont be any output in the terminal.

## Options

The `-l` option is the default, and produces BibTex output.
For Roff/Refer output use the `-r` flag:


```bash
$ ./bib.sh -r layout design scheible
```

## Related Work

+ [pybib](https://github.com/jgilchrist/pybib)
+ [bibtex-search](https://github.com/ekmartin/bibtex-search)
+ [isbnbib](https://github.com/mkomod/isbnbib)
+ [BibtexRetrieval](https://github.com/frrobert2/BibtexRetrieval)
