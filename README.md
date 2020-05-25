# Bibliography.Shell

My script for retrieving Citations from the commandline.
Query [Google Books](https://developers.google.com/books) from the Terminal and retrieve BibTex or Roff/Refer Citation.

## Dependecies

+ [curl](https://curl.haxx.se/)
+ [jq](https://stedolan.github.io/jq/)
+ [fzy](https://github.com/jhawthorn/fzy) or [fzf](https://github.com/junegunn/fzf)

## Usage

```{bash}
$ ./bib.sh c programming language ritchie
```

This will pipe the titles retrieved from [Google Books](https://developers.google.com/books)
into fzf/fzy. After selecting one, you'll get the BibTex reference
printed to stdout.

```{bash}
@book{  label = ritchie22,
        title = "C Programming Language",
        author = "Brian W. Kernighan", "Dennis Ritchie" ,
        publisher = "Prentice Hall",
        year = "1988"
}
```

To append a reference to a bibliography simply redirect the output to that file:

```{bash}
$ ./bib.sh -l c programming language ritchie >> library.bib
```

After selecting the source, there wont be any output in the terminal.

## Options

The `-l` option is the default, and produces BibTex output.
For Roff/Refer output use the `-r` flag:


```{bash}
$ ./bib.sh -r c programming language ritchie
```

## Related Work

+ [pybib](https://github.com/jgilchrist/pybib)
+ [bibtex-search](https://github.com/ekmartin/bibtex-search)
+ [isbnbib](https://github.com/mkomod/isbnbib)
+ [BibtexRetrieval](https://github.com/frrobert2/BibtexRetrieval)
