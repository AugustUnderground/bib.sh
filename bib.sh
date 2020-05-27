#!/bin/sh

FORMAT="LATEX"
ENGINE="BIBTEX"

nofuzzy()
{
    PROMPT="Cite: "
    INDEX=0
    while [ "$INDEX" -ne "$LENGTH" ]
    do
        TITLE=$(jq ".items[$INDEX].volumeInfo.title" $RESULTS_DB)
        AUTHOR=$(jq ".items[$INDEX].volumeInfo.authors[0]" $RESULTS_DB)
        printf '%s: %s, by %s\n' "$INDEX" "$TITLE" "$AUTHOR"
        INDEX=$((INDEX + 1))
    done

    printf '%s' "$PROMPT"
    read SELECTION

    ISBN=$(jq ".items[$SELECTION].volumeInfo.industryIdentifiers[0].identifier" $RESULTS_DB)
    ISBN="${ISBN%\"}"
    ISBN="${ISBN#\"}"
}

fuzzy()
{
    RES=$(jq ".items[] | .id + \"; \" + .volumeInfo.title + \"; \" + .volumeInfo.authors[]" $RESULTS_DB | $1)
    RES="${RES%\"}"
    RES="${RES#\"}"
    ID=$(echo $RES | awk -F";" '{print $1}')
    ISBN=$(jq ".items[] | select(.id == \"$ID\")\
                        | .volumeInfo.industryIdentifiers[]\
                        | select(.type == \"ISBN_13\")\
                        | .identifier" $RESULTS_DB)
    ISBN="${ISBN%\"}"
    ISBN="${ISBN#\"}"
}

bibify()
{
    JSON=$(curl -sL "https://www.googleapis.com/books/v1/volumes?q=isbn:$ISBN&maxResults=1")

    TYPE="$(echo $JSON | jq ".items[0] | .volumeInfo.printType" | tr '[:upper:]' '[:lower:]')"
    TYPE="${TYPE#\"}"
    TYPE="${TYPE%\"}"

    TITLE="$(echo $JSON | jq ".items[0] | .volumeInfo.title")"

    AUTHORS="$(echo $JSON | jq ".items[0] | .volumeInfo.authors")"
    AUTHORS="${AUTHORS#\[}"
    AUTHORS="${AUTHORS%\]}"

    PUBLISHER="$(echo $JSON | jq ".items[0] | .volumeInfo.publisher")"

    YEAR="$(echo $JSON | jq ".items[0] | .volumeInfo.publishedDate")"

    YLABEL="$(echo $YEAR | awk -F"-" '{print $NF}')"
    YLABEL="${YLABEL#\"}"
    YLABEL="${YLABEL%\"}"
    ALABEL="$(echo $AUTHORS | awk '{print $NF}' | tr '[:upper:]' '[:lower:]')"
    ALABEL="${ALABEL#\"}"
    ALABEL="${ALABEL%\"}"
    LABEL="$ALABEL$YLABEL"

    if [ "$FORMAT" = "LATEX" ]; then
        LABEL="$ALABEL$YLABEL"
        TITLE="title = {$(echo $TITLE | tr -d "\"")}"
        AUTHOR="author = {$(echo $AUTHORS |  tr "\n" " " | tr -d "\"")}"
        PUBLISHER="publisher = {$(echo $PUBLISHER | tr -d "\"")}" 
        YEAR="year = {$(echo $YEAR | tr -d "\"")}"
        printf '@%s{\t%s,\n\t%s,\n\t%s,\n\t%s,\n\t%s\n}\n\n'\
               "$TYPE" "$LABEL" "$TITLE" "$AUTHOR" "$PUBLISHER" "$YEAR"
    elif [ "$FORMAT" = "ROFF" ]; then
        LABEL="%L $ALABEL$YLABEL"
        TITLE="%T $(echo $TITLE | tr -d "\"")"
        AUTHOR="$(echo $AUTHORS | tr "," "\n" | sed -e 's/^[ \t]*//' | awk '{print "%A " $0}' | tr -d "\"")"
        PUBLISHER="%I $(echo $PUBLISHER | tr -d "\"")"
        YEAR="%D $(echo $YEAR | tr -d "\"")"
        printf '%s\n%s\n%s\n%s\n%s\n\n'\
               "$LABEL"  "$TITLE" "$AUTHOR" "$PUBLISHER" "$YEAR"
    fi
}

bibtex_search()
{
    URL=http://bibtexsearch.com/search\?auth\=web\&q\=
    
    JSON=$(curl -sL $URL$QUERY | jq | sed 's/\\n/\n/g; s/\\t/\t/g')

    SELECT=$(echo $JSON | jq '.[] | ._source.bibtex + ";" + ._id' \
                        | awk -F'[@{}]' '{print $2 ": " $4 " " $6 " " $NF}' \
                        | fzf)

    ID=$(echo $SELECT | cut -d\; -f2 | tr -d "\"")

    RES=$(echo $JSON | jq --arg ID $ID '.[] | select(._id == $ID) | ._source.bibtex' \
                     | tr -d "\"" \
                     | sed -Ee 's/ , / ,\n\t/g' \
                     | sed -Ee 's/} }/}\n}/g')
    printf "$RES\n\n"
}

google_search()
{
    RESULTS_DB="/tmp/bibterm.json"

    curl -s https://www.googleapis.com/books/v1/volumes?q=$QUERY | jq > $RESULTS_DB

    LENGTH=$(jq ".items | length" $RESULTS_DB)


    if command -v fzf > /dev/null; then
        fuzzy fzf
    elif command -v fzy > /dev/null; then
        fuzzy fzy
    else
        nofuzzy
    fi

    bibify

    rm $RESULTS_DB
}

main()
{
    if [ "$ENGINE" = "BIBTEX" ]; then
        QUERY=$(echo "$@" | sed -Ee 's/ /%20/g')
        bibtex_search
    elif [ "$ENGINE" = "GOOGLE" ]; then
        QUERY=$(echo $@ | sed -Ee 's/ /+/g')
        google_search
    else
        exit 1
    fi

    exit 0
}

help() {
    echo "USAGE: $0 [-l|r] <query>
        [-l] BibTex output (default)
        [-r] Roff/Refer output
        [-b] use http://www.bibtexsearch.com/ (default)
        [-g] use https://www.googleapis.com/books/v1/volumes

        <query> is some text related to the book you're searching for."
    exit 0
}

OPTIONS='hlrgb'
while getopts $OPTIONS OPT; do
    case $OPT in
        h) help ;;
        l) FORMAT="LATEX" ;;
        r) FORMAT="ROFF" ;;
        g) ENGINE="GOOGLE" ;;
        b) ENGINE="BIBTEX" ;;
        \?)
            echo "Unknown option: -${OPTARG}" >&2
            exit 1
            ;;
        *)
            echo "Unimplemented option: -${OPTARG}" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

main "$@"
