# frozen_string_literal: true

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end
end

class Hangman
  require 'yaml'

  def initialize
    @guess_array = []
    @letters = ('A'..'Z').to_a
    @misses = 0
    play_game
  end

  def play_game
    new_or_saved
  end

  def new_or_saved
    print %(
      Welcome to Hangman.  Would you like to start a
      NEW game or LOAD a SAVED game?

      1 = NEW game
      2 = LOAD a SAVED game
      3 = QUIT

      Enter 1, 2 or 3: )
    valid_answer = false
    while valid_answer == false
      @new_or_saved = gets.chomp.to_i
      if @new_or_saved == 1
        valid_answer = true
        generate_word
        explain_rules
        game_sequence
      elsif @new_or_saved == 2
        valid_answer = true
        saved_games_menu
      elsif @new_or_saved == 3
        break
      else print %(You may only enter 1, 2 or 3.  Try again.)
      end
    end
  end

  def generate_word
    valid_word = false
    while valid_word == false
      wordlist = File.open('lib/5desk.txt', 'r')
      random_num = rand(wordlist.readlines.size)
      @solution_word = File.readlines(wordlist)[random_num].strip.upcase
      valid_word = true if (5..12).to_a.include?(@solution_word.length)
    end
    wordlist.close
    @solution_word.length.times { @guess_array.push('_ ') }
    @solution_array = @solution_word.split('')
  end

  def explain_rules
    print %(
      In the game of "Hangman," you are given an
      unknown word with a known length, and your
      objective is to guess what the word is.

      On each turn, you may guess one letter. If
      you guess correctly, there is no penalty.
      However, if you guess incorrectly, it is
      considered a "miss."  If you miss six times
      you lose.)
  end

  def game_sequence
    if @misses == 6
      print 'You lost! Press [ENTER] to play again or [X] to exit.'
      replay_question
    end
    while @misses < 6
      scoreboard
      get_guess
      next unless @guess_array == @solution_array

      scoreboard
      @misses = 6
      print 'You won! Press [ENTER] to play again or [X] to exit.'
      replay_question
    end
  end

  def scoreboard
    print %(

      #{@misses} miss\(es\) out of 6 total.

      #{@guess_array.join(' ')}  #{@letters.join('')}

      )
  end

  def get_guess
    print %(
      Enter a guess, or type SAVE to save your game: )
    guess = gets.chomp.upcase
    validate_guess(guess)
  end

  def validate_guess(guess)
    if guess == 'SAVE'
      save_game
    elsif guess.length != 1
      puts %(
        You may only guess one character at a time.  Try again.
        )
      get_guess
    elsif @guess_array.include?(guess)
      puts %(
        You have already guessed that letter.  Try again.
        )
    elsif !@letters.include?(guess)
      puts %(
        You can only enter a letter.  Try again.
        )
    else
      process_guess(guess)
      end
    end

  def process_guess(guess)
    if @solution_array.include?(guess)
      @solution_array.each_with_index do |letter, index|
        @guess_array[index] = guess if letter == guess
      end
      @letters.map! do |letter|
        letter = if letter == guess.upcase
                   letter.green
                 else
                   letter
                 end
      end
    else
      @misses += 1
      @letters.map! do |letter|
        letter = if letter == guess.upcase
                   letter.red
                 else
                   letter
                 end
      end
    end
   end

  def replay_question
    play_again = gets.chomp.upcase
    Hangman.new if play_again == ''
  end

  def save_game
    time = Time.new
    default_filename = time.strftime('%Y%m%d%H%m%S')
    game_data = {}
    game_data[:solution_word] = @solution_word
    game_data[:misses] = @misses
    game_data[:guess_array] = @guess_array
    game_data[:letters] = @letters
    game_data[:solution_array] = @solution_array
    puts game_data
    File.open("./yaml/#{default_filename}.yml", 'w') { |f| f.write(game_data.to_yaml) }
  end

  def saved_games_menu
    saved_games_hash = {}
    saved_games = Dir['./yaml/*.yml'].to_a
    saved_games.map!.with_index do |f, index|
      saved_games_hash[index + 1] = f
    end
    saved_games_readable = []
    saved_games_hash.each do |key, value|
      value = value.sub('./yaml/', '')
      value = value.sub('.yml', '')
      saved_games_readable.push("#{key}: #{value}")
    end
    print %(
            Select the number corresponding to your saved game
            from the list below:

            #{saved_games_readable}

            Enter a number: )
    selected_game = gets.chomp.to_i
    selected_game = saved_games_hash.values_at(selected_game)
    load_game(selected_game)
    end

  def load_game(selected_game)
    selected_game = selected_game.join('')
    game_data = YAML.load_file(selected_game)
    @solution_word = game_data.values_at(:solution_word).join('')
    @misses = game_data.values_at(:misses).join('').to_i
    @guess_array = game_data.values_at(:guess_array).flatten
    @letters = game_data.values_at(:letters).flatten
    @solution_array = @solution_word.split('')
    game_sequence
  end

end

Hangman.new
