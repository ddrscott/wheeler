require 'wheeler/version'

module Wheeler

  def each_word(io, &block)
    io.each_line('.') do |line|
      line.split(/[\s"]+/).each do |word|
        stripped = word.strip
        if stripped.size > 0
          block.call stripped.upcase
        end
      end
    end
  end

  def each_phrase(io, max_words=4, &block)
    words = []
    each_word(io) do |word|
      words << word
      if words.length >= max_words
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
end
