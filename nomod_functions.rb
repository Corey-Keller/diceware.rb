require 'bigdecimal/math'
include BigMath

# #ROLLS FUNCTIONS
# Checks the current number of dice available, and sees if there are
# enough to guarantee we won't run out before the end, and if not, roll for more
def check_num_rolls(just_rolled = 0) # , rolls_per_action = 5)
  $rolls_left -= just_rolled
  # If there
  minimum_rolls_left = $steps_left < 5 ? (just_rolled * 1.5).ceil : just_rolled * 4
  puts "rolls still needed: #{$rolls_left}     available:#{$rolls_array.length}", "STEPS LEFT:#{$steps_left}"
  if ($rolls_array.length < $rolls_left) && $rolls_array.length <= minimum_rolls_left
    ammount_to_fetch = ($rolls_left * $Reroll_multiple).ceil # (1.00 + $Reroll_percent*5/100)).ceil# + $rolls_array.length
    puts "Insufficient rolls available to guarantee completion! Grab #{ammount_to_fetch}"
    roll_dice ammount_to_fetch
  end
end

def get_min_rolls
  # set to {$Add_num_words + 1} because 1 is the smallest number you can roll on a die.
  min_num_words = $Add_num_words + 1
  # the minimum number of modifiers possible
  min_num_mod = (min_num_words * $Mod_percent).ceil + 1
  (rolls_needed words: min_num_words, symbols: min_num_mod, capitals: min_num_mod) #+ 3
end

def rolls_for_combo(size)
  # gets the minimum number of dice rolls to make {size} number of combinations
  # puts "GETTING NUMBER OF ROLLS NEEDED FOR #{size} COMBINATIONS"
  minimum_rolls = bigmath_log(size, $Die_sides).ceil
  additional_dice_needed = bigmath_log((bigmath_log(Math::E * size / 2) / 2), $Die_sides).floor
  minimum_rolls = 1 if minimum_rolls <= 1; additional_dice_needed = 0 if additional_dice_needed < 0
  number_of_dice = minimum_rolls + additional_dice_needed
  number_of_dice
end

def roll_dice(number)
  return if ($rolls_array.length - number) >= 0
  print "Roll #{number - $rolls_array.length} dice and enter the values here:"
  until $rolls_array.length >= number
    current_input_array = string_to_int_array gets.chomp
    unless current_input_array.reject { |value| value.between?(1, $Die_sides) }.empty?
      print 'Not valid dice rolls! Check your input and try again:'
      next
    end
    $rolls_array.concat(current_input_array)
    if $rolls_array.length < number
      print "Not enough dice! Please roll #{number - $rolls_array.length} more:"
    end
  end
end

def rolls_needed(avg_length: $Average_word_length, words:, symbols:, capitals:)
  # NUMBER OF DICE = [DICE TO GET WORDS] + ([NUMBER OF MODIFIERS] * ([DICE TO SELECT WORD]
  # + [DICE TO SELECT CHAR]) * [ASSUMED REROLLS PERCENT])
  # rolls_needed = \
  # DICE TO GET WORDS: number of dice required to get the words from the wordlist
  (((words * $Dice_per_word) + \

  # NUMBER OF MODIFIERS: the total number of modifiers
  # multiply by DICE TO SELECT WORD and DICE TO SELECT CHAR because both happen
  # every time you modify
  (symbols + capitals) * \
  # DICE TO SELECT WORD: gets the minimum number of dice rolls to have at least as many
  # possible combinations as there are words
  ((rolls_for_combo words) + \

  # DICE TO SELECT CHAR: gets the minimum number of dice rolls to have at least as many
  # possible combinations as there are letters in the average word
  (rolls_for_combo $Average_word_length)) + \

  symbols * $Dice_per_symbol) * \

  # ASSUMED REROLLS PERCENT: Increase total number of dice by {$Reroll_multiple} percent
  # to minimize reprompting for input of additional rolls
  $Reroll_multiple).ceil # / 5).ceil * 5#.ceil
end

def initialize_variables
  # Take {$Add_num_words} and add the value of your first roll
  $Num_words = $rolls_array.shift + $Add_num_words
  # Then multiply that by the {$Mod_percent} and round up to get the minimum number of
  # modifiers, and add the second roll to it for capitals
  $Num_caps = 0
  # Do the same as above with the third roll for symbols
  $Num_sym = 0
  $Num_dice = rolls_needed words: $Num_words, capitals: $Num_caps, symbols: $Num_sym
  $steps_left = $Num_words + $Num_caps + $Num_sym
  puts "There will be #{$Num_words} words"
  puts "There will be #{$Num_caps} capital letters"
  puts "There will be #{$Num_sym} symbols"
  puts "You'll need #{$Num_dice} dice"
end

def string_array_avg_len(array)
  total = 0
  array.each { |string| total += string.length }
  (total / array.length)
end

# Converts an integer array into a single number
def int_array_to_single_number(array = $rolls_array)
  total = 0
  # take each element, and subtract 1 so that any number is between 0 and ($Die_sides -1)
  # which can be thought of as a single digit in base $Die_sides, then reverse the order of the
  # array so that each 'digit' is is in it's 'place' (eg: ones, tens, hundreds)
  array.map(&:pred).reverse.each_with_index do |value, index|
    total += value * ($Die_sides**index)
  end
  # puts "total is: #{total}"
  total
end

# gets the log base #{base} of #{number} using $BigMath_precision digits of precision
def bigmath_log(number, base = Math::E)
  Float(BigMath.log(number, $BigMath_precision) / BigMath.log(base, $BigMath_precision))
end

def get_capitals
  puts 'GETTING CAPITALS'
  $rolls_left = $Num_caps * ((rolls_for_combo $Num_words) + (rolls_for_combo $Average_word_length))
  $Num_caps.times do |_count|
    # begin
    # print:"count: #{count}"
    # \A[a-z]*\Z
    selected_word_position = get_position $words_array.length
    unless $words_array[selected_word_position].index(/[a-z]/)
      puts "#{$words_array[selected_word_position]} DOESN'T HAVE LOWERCASE LETTERS!"
      # selected_word_position = get_position $words_array.length
      check_num_rolls (rolls_for_combo $words_array.length) * -1
      redo
    end
    selected_word = $words_array[selected_word_position]
    first_lowercase_letter_index = selected_word.index(/[a-z]/)
    lowercase_letters_array = selected_word.slice(first_lowercase_letter_index..-1).chars
    capitalized_char_relative_position = get_position lowercase_letters_array.length
    unless lowercase_letters_array[capitalized_char_relative_position].upcase!
      puts 'already capital!'
      check_num_rolls (rolls_for_combo lowercase_letters_array.length) * -1
      redo
    end
    lowercase_letters_array[capitalized_char_relative_position].upcase!
    $words_array[selected_word_position] = selected_word.slice(0...first_lowercase_letter_index) + lowercase_letters_array.join
    # check_num_rolls ((rolls_for_combo $Num_words)+(rolls_for_combo lowercase_letters_array.length))
    $steps_left -= 1
  end
  # puts $words_array
  #  end
end

# converts a string of numbers separated by #{$Separator} into an array of base 10 integers
def string_to_int_array(string)
  string.split($Separator).map(&:to_i)
end

def get_symbols
  puts 'GETTING SYMBOLS'
  $rolls_left = $Num_sym * ((rolls_for_combo $Num_words) + (rolls_for_combo $Average_word_length)) + $Num_sym * $Dice_per_symbol
  $Num_sym.times do
    selected_word_position = get_position $words_array.length
    selected_word = $words_array[selected_word_position]
    selected_symbol = get_position Symbol_list.length
    index_to_insert_symbol = get_position selected_word.length
    selected_word.insert(index_to_insert_symbol, Symbol_list[selected_symbol])
    $steps_left -= 1
    # check_num_rolls ((rolls_for_combo $Num_words)+(rolls_for_combo selected_word.length)+$Dice_per_symbol)
  end
end

def get_position(size)
  begin
    # puts "GETTING POSITION"
    number_of_dice = rolls_for_combo size
    roll_combinations = $Die_sides**number_of_dice
    # grab the number of dice we're going to use
    roll_result = int_array_to_single_number $rolls_array.shift(number_of_dice) # array.slice!(0...number_of_dice)#.chars.map(&:to_i).map(&:pred).join.to_i($Die_sides)
    quotient, remainder = roll_result.divmod(size)
    # puts "number_of_dice = #{number_of_dice}", "roll_combinations=#{roll_combinations}", "roll_result:#{roll_result}", "quotient:#{quotient}", "remainder:#{remainder}"
    raise RangeError, 'Quotient is out of bounds' if quotient == (roll_combinations / size).floor
    check_num_rolls number_of_dice
  rescue RangeError
    puts 'Quotient is out of bounds! Retrying with new rolls!'
    retry
  end
  # puts "POSITION IS:#{remainder}"
  remainder
end

def get_words_from_list(_array = $rolls_array)
  $rolls_left = $Num_words * $Dice_per_word
  $Num_words.times do
    # $words_array.push(Word_list[int_array_to_single_number array.shift($Dice_per_word)])
    $words_array.push(Word_list[get_position Word_list.length])
    # check_num_rolls $Dice_per_word
    $steps_left -= 1
  end
  puts 'BASE WORD LIST:'
  $words_array.each { |element| print element, ' ' }
  print "\n"
end
