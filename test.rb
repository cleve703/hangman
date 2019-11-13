valid_word = false
100.times do
  wordlist = File.open('lib/5desk.txt', 'r')
  random_num = rand(wordlist.readlines.size)
  puts random_num
  @solution_word = File.readlines(wordlist)[random_num].strip.upcase
  valid_word = true if (5..12).to_a.include?(@solution_word.length)
  puts valid_word
  random_num = nil
end
wordlist.close
@solution_array = @solution_word.split('')
puts @solution_word