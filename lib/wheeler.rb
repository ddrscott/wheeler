require 'wheeler/version'

module Wheeler

  def test
    each_phrase('a b. c d', 10) do |words|
      puts words.join ' '
    end
  end

  def each_word(io, &block)
    # break on spaces instead of \n
    io.each_line(' ') do |line|
      # alphas with quote and period. We'll use the period as a hint for phrasing
      line.scan(/([a-zA-Z'.]+)/).each do |word, _|
        block.call word.upcase
      end
    end
  end

  def each_phrase(io, max_words=4, &block)
    words = []
    each_word(io) do |word|
      words << word
      if word[-1] == '.'
        # remove period
        words[-1] = words[-1][0..-2]

        unroll_words(words, &block)

        # we can start a new phrase by resetting the words
        words.clear
      elsif words.length >= max_words
        unroll_words(words, &block)
      end
    end
    unroll_words(words, &block)
  end

  def unroll_words(words, &block)
    len = words.size
    len.times do |i|
      block.call words[i..len]
    end
    words.shift
  end

  def word_sizes(words)
    words.map{|m| m.size } * ' '
  end

  def remove_last_punctuation_if_needed(words)
    last_char = words.last[-1]
    if last_char == ',' or last_char == '.' or last_char == ';'
      words[-1] = words[0..-2]
    end
    words
  end

  def map_phrases(io, max_words)
    each_phrase(io, max_words) do |words|
      row = [
          word_sizes(words),
          words * ' '
       ]

      puts row * '|'
    end
  end

  def reduce_count(io)
    last_line = nil
    count = 0
    io.each_line do |line|
      count += 1
      if last_line and line != last_line
        print_count(count, last_line)
        count = 0
      end
      last_line = line
    end
    if last_line and count > 0
      print_count(count, last_line)
    end
  end

  def print_count(count, line)
    print('%3d' % count)
    print('|')
    puts(line)
  end

  # @param puzzle [String] Known letters in their position and `_` underscore the unknown letters
  def guess(puzzle, index)
    words = []
    # split up into words
    puzzle.split(/\s+/).each do |w|
      underscore_to_dots = w.gsub('_', '.').upcase
      words << underscore_to_dots
    end

    matcher = /\|#{word_sizes(words)}\|#{words * ' '}/
    puts "... grepping for: #{matcher.inspect}"
    count_matches = 0
    index.each_line do |line|
      if line =~ matcher
        puts line
        count_matches += 1
      end
    end
    puts "matches: #{count_matches}"
    count_matches
  end
end
