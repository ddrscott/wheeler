require 'wheeler/version'

module Wheeler

  INDEX_PATH = '.index'

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

  # ensure the block is called at most once per duration
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

      # write out when the size of the words changes
      if last_sizes and sizes != last_sizes
        write_sizes(last_sizes, texts)
        texts.clear
      end

      text = text[0..-2]                                 # strip new line
      throttle{$stderr.print "\e[0K#{sizes}|#{text}\r"}  # some debug output
      if texts.last != text
        texts << text           # text that matches the word size pattern
      end

      last_sizes = sizes
    end

    if texts.any?          # make sure we write out the remaining phrases
      write_sizes(last_sizes, texts)
    end
  end

  def write_sizes(sizes, texts)
    idx_path = "#{INDEX_PATH}/#{sizes.gsub(' ', '/')}"
    FileUtils.mkdir_p idx_path
    File.open("#{idx_path}/phrases", 'w') { |f| f << texts.join("\n") }
  end

  # @param puzzle [String] Known letters in their position and `_` underscore the unknown letters
  def guess(puzzle)
    # split up into words and replace _ with dot
    words = puzzle.split(/\s+/).map{|w| w.gsub('_', '.').upcase}

    # Example: "_ ____ ____" should constuct `.index/1/4/4/phrases`
    phrase_path = "#{INDEX_PATH}/#{words.map(&:size) * '/'}/phrases"

    cmd = "grep --color=always -e '#{words * ' '}' #{phrase_path}"
    puts cmd
    puts `#{cmd}`
    if $?.exitstatus == 1
      puts "Phrases not found in #{phrase_path}"
    end
  end
end
