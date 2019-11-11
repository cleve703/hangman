require 'yaml'

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

  def initialize
    @guess_array = []
    @letters = ("A".."Z").to_a
    @misses = 0
    play_game
  end

  def play_game
    new_or_saved
  end
  
  def new_or_saved
    print %Q(
      Welcome to Hangman.  Would you like to start a 
      NEW game or LOAD a SAVED game?
      
      1 = NEW game
      2 = LOAD a SAVED game
      3 = QUIT
      
      Enter 1 or 2: )
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
        load_saved
      elsif @new_or_saved == 3
        break
      else print %Q(You may only enter 1, 2 or 3.  Try again.)
      end
    end
  end    
  
  def generate_word
    wordlist = File.open("lib/5desk.txt", "r")
    valid_word = false
    while valid_word == false
      random_num = rand(wordlist.readlines.size)
      @solution_word = File.readlines(wordlist)[random_num].strip.upcase
      if (5..12).to_a.include?(@solution_word.length)
        valid_word = true
      end
    end
    wordlist.close
    puts @solution_word
    (@solution_word.length).times {@guess_array.push("_ ")}
    @solution_array = @solution_word.split("")
  end

  def explain_rules
    print %Q(
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
      print "You lost! Press [ENTER] to play again or [X] to exit."
      replay_question
    end
    while @misses < 6
      scoreboard
      get_guess
      if @guess_array == @solution_array
        scoreboard
        @misses = 6
        print "You won! Press [ENTER] to play again or [X] to exit."
        replay_question
      end
    end
  end

  def scoreboard
    print %Q(
      
      #{@misses} miss\(es\) out of 6 total.
    
      #{@guess_array.join(" ")}  #{@letters.join("")}
    
      )

  end

  def get_guess
    print %Q(
      Enter a guess, or type SAVE to save your game: )
    guess = gets.chomp.upcase
    validate_guess(guess)
  end

  def validate_guess(guess)
    case
      when guess == "SAVE"
        save_game  
      when guess.length != 1
        puts %Q(
      You may only guess one character at a time.  Try again.
          )
        get_guess
      when !@letters.include?(guess)
        puts %Q(
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
        if letter == guess.upcase
          letter = letter.green
        else
          letter = letter
        end
      end
    else
      @misses += 1
      @letters.map! do |letter| 
        if letter == guess.upcase
          letter = letter.red
        else
          letter = letter
        end
      end
    end
  end

  def replay_question
    play_again = gets.chomp.upcase
    if play_again == ""
      Hangman.new
    end
  end

  def save_game
    time = Time.new
    default_filename = time.strftime("%Y%m%d%H%m%S")
    puts "Default filename is #{default_filename}"
    puts self.inspect
    File.open("#{default_filename}.bin", "wb") {|f| f.write(Marshal.dump(self))}
  end

  def load_saved
    puts "Loading saved game..."
  end

end

Hangman.new