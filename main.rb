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
      else print %Q(You may only enter 1 or 2.  Try again.)
      end
    end
  end    
  
  def generate_word
    wordlist = File.open("lib/5desk.txt", "r")
    random_num = rand(wordlist.readlines.size)
    @solution_word = File.readlines(wordlist)[random_num].strip.upcase
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
    while @misses < 6
      scoreboard
      get_guess
    end
  end

  def scoreboard
    print %Q(
      
      #{@misses} miss\(es\) out of 6 total.
    
      #{@guess_array.join("")}  #{@letters.join("")}
    
      )

  end

  def get_guess
    print %Q(
      Enter a guess: )
    guess = gets.chomp.upcase
    if @solution_array.include?(guess)
      @solution_array.each_with_index do |letter, index|
        @guess_array[index] = guess + " " if letter == guess
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

  def load_saved
    puts "Loading saved game..."
  end

end

Hangman.new