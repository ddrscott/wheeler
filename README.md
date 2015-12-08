# Wheeler

This is a map/reduce proof of concept with a little bit of fun thrown in. 

Wheeler is a naive Wheel of Fortune solver. It does this by indexing sampled
text from where ever into every possible contiguous combination of words up
to a max phrase length.

The mapper in this project is `./bin/phrases`. Again, this is a naive program.
The phrase parser don't use any NLP or grammar logic. It simply splits words
by spaces, period, and double quotes. After splitting it outputs joined sets
of those words in descending word count.

The reduce is `./bin/count`. It simply prepends a count each line from the
mapping phase. *Tt's critical* to pre-sort the mapped phrases prior to
reducing. Therefore, we pipe the mapper to `sort` prior to using `./bin/count`


## Build Index, 1-Liner

    # one-liner
    $ ./bin/phrases 10 samples/adventure_of_the_speckled_band.txt | sort | ./bin/count | sort -t '|' -k 1n > index.txt
    
## Build Index, Usage Step by Step

    # Map text to phrases
    $ ./bin/phrases 10 samples/adventure_of_the_speckled_band.txt > phrases-unsorted.txt
    
    # Sort thee mapped phraes
    $ sort phrases-unsorted.txt > phrases-sorted.txt
     
    # Reduce to counts
    $ ./bin/count phrases-sorted.txt > counts.txt
    
    # sort the counts infrequent to frequent
    $ sort -t '|' -k 1n counts.txt > index.txt

    # view index
    $ less index.txt

## Solve a Puzzle

    $ ./bin/guess.rb '____ __ _____ES' index.txt
    #  ... grepping for: /\|4 2 7\|.... .. .....ES/
    #    1|4 2 7|BAND OF GYPSIES
    #  matches: 1

## Use an English Dictionary
    
    # Make the Index
    $ curl http://www.gutenberg.org/ebooks/29765 > dict.txt
    $ ./bin/phrases 10 dict.txt > dict.phrase
    $ sort dict.phrases > dict.sorted
    $ ./bin/count dict.sorted > dict.idx
    
    # Use the Index
    $ ./bin/guess.rb '_ C__C______' index.txt
    #  ... grepping for: /\|1 11\|. C..C....../
    #    1|1 11|A CALCULATOR.
    #  matches: 1

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddrscott/wheeler.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

