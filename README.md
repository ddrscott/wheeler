# Wheeler

This is a map/reduce proof of concept with a little bit of fun thrown in. 

Wheeler is a naive Wheel of Fortune solver. It does this by indexing sampled
text from where ever into every possible contiguous combination of words up
to a max phrase length.

The mapper in this project is `./bin/phrases`. Again, this is a naive program.
The phrase parser don't use any NLP or grammar logic. It simply splits words
by spaces, period, and double quotes. After splitting it outputs joined sets
of those words in descending word count.

The reducer is `./bin/reduce_fs`. It build the phrase index into the `.index`
directory inside this project. Maybe we'll make it an arg in the future.
The index structure is:
  1st word size/2nd word size/3rd word size/etc.../phrases

So for the phrase: "I love cats". An index entry would be written into
`.index/1/4/4/phrases`. The contents of phrases would be 'I LOVE CATS'

After the index are built, the guess matching is almost trivial.

1. receive a puzzle with underscores and known letters. For example: `_ ____ ___s`
2. get the word counts of the puzzle. 1, 4, 4.
3. find the phrases file based on the word counts. `.index/1/4/4/phrases`
4. perform a simple pattern match in that file. `grep -e '. .... ....' .index/1/4/4/phrases`

The `bin/guess` script will do steps 2-4 automatically: `bin/guess '_ ____ ___s'`

The more sample texts which are index, the better chance of solving any given
puzzle. This is only as good as the index it compiles.

## Build Index, 1-Liner

    # one-liner
    $ ./bin/phrases 5 samples/adventure_of_the_speckled_band.txt | sort | ./bin/reduce_fs
    
## Build Index, Usage Step by Step

    # Map text to phrases
    $ ./bin/phrases 5 samples/adventure_of_the_speckled_band.txt > phrases-unsorted.txt
    
    # Sort the mapped phrases
    $ sort phrases-unsorted.txt > phrases-sorted.txt
     
    # Reduce to counts
    $ ./bin/reduce_fs phrases-sorted.txt
    
    # view phrase indexes
    $ find .index -name phrases
    
    # view contents of a phrase
    $ less .index/9/8/4/9/3/phrases

## Solve a Puzzle

    $ ./bin/guess '____ __ _____ES'
    # grep --color=always -e '.... .. .....ES' .index/4/2/7/phrases
    # BAND OF GYPSIES

## Use a sample dictionary
    # Map text to phrases
    $ ./bin/phrases 5 samples/dict.txt > phrases-unsorted.txt
    
    # Sort the mapped phrases
    $ sort phrases-unsorted.txt > phrases-sorted.txt
     
    # Reduce to counts
    $ ./bin/reduce_fs phrases-sorted.txt

## Use full English Dictionary
    
    # Make the Index
    $ curl http://www.gutenberg.org/ebooks/29765 > dictionary.txt
    $ ./bin/phrases 5 dictionary.txt > phrases-unsorted.txt
    
    # Sort the mapped phrases
    $ sort phrases-unsorted.txt > phrases-sorted.txt
     
    # Reduce to counts
    $ ./bin/reduce_fs phrases-sorted.txt
    

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ddrscott/wheeler.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

