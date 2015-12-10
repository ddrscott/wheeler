require 'wheeler/version'

module Wheeler

  def each_word(io, &block)
    # break on spaces instead of \n
    io.each_line(' ') do |line|
      # alphas with quote and period. We'll use the period as a hint for phrasing
      line.scan(/\b([[:word:]]+)\b/).each do |word, _|
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

        cascade_words(words, &block)

        # we can start a new phrase by resetting the words
        words.clear
      elsif words.length >= max_words
        cascade_words(words, &block)
      end
    end
    cascade_words(words, &block)
  end

  def cascade_words(words, &block)
    len = words.size
    len.times do |i|
      block.call words[0..i]
    end
    words.shift
  end

  def word_sizes(words)
    words.map{|m| m.size } * ' '
  end

  def remove_last_punctuation_if_needed(words)
    last_char = words.last[-1]
    if last_char == ',' or last_char == ';'
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

  def throttle(duration=0.1, &block)
    @last_time ||= Time.now
    if @last_time and (Time.now - duration) > @last_time
      block.call
      @last_time = Time.now
    end
  end

  def reduce_fs(io)
    last_sizes = nil
    texts = []

    io.each_line do |line|

      sizes, text = *line.split('|')

      if last_sizes and sizes != last_sizes
        write_sizes(last_sizes, texts)
        texts.clear
      end

      text = text[0..-2] # strip new line
      throttle{print "\e[0K#{sizes}|#{text}\r"}
      if texts.last != text
        texts << text
      end

      last_sizes = sizes
    end

    if texts.any?
      write_sizes(last_sizes, texts)
    end
  end

  def write_sizes(sizes, texts)
    idx_path = ".index/#{sizes.gsub(' ', '/')}"
    FileUtils.mkdir_p idx_path
    File.open("#{idx_path}/phrases", 'w') { |f| f << texts.join("\n") }
  end

  def print_count(count, line)
    print('%3d' % count)
    print('|')
    puts(line)
  end

  # @param puzzle [String] Known letters in their position and `_` underscore the unknown letters
  def guess(puzzle)
    words = []
    # split up into words
    puzzle.split(/\s+/).each do |w|
      underscore_to_dots = w.gsub('_', '.').upcase
      words << underscore_to_dots
    end

    sizes = words.map { |m| m.size }
    idx_path = ".index/#{sizes * '/'}"
    phrase_path = "#{idx_path}/phrases"

    matcher = /#{words * ' '}/
    puts "[#{phrase_path}] searching for: #{matcher.inspect}"

    if File.file?(phrase_path)
      count_matches = 0
      IO.foreach(phrase_path) do |line|
        line = line[0..-2]
        if line =~ matcher
          puts "    #{line}"
          count_matches += 1
        end
      end
      puts "matches: #{count_matches}"
      count_matches
    else
      puts "No phrases in #{idx_path}"
    end
  end
end
