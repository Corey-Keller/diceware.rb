require_relative 'nomod_functions'
require_relative 'symbol_list'
require_relative 'word_list'

# CONSTANTS
# Taken from the character count of all of the values in wordlist.rb and divided
# by the number of elements, rounded up.
$Average_word_length = 8
# Number of decimal places for BigMath calculations to round to
$BigMath_precision = 100
# Number of sides the dice being used have
$Die_sides = 6
# Number of words to add to the rolled value, to prevent too
# few total words
$Add_num_words = 17
# Add this percent (as decimal) of $Number_of_words(rounded up)
# to each modifier type to prevent too few modifiers being available
$Mod_percent = 0.0
# Number of dice needed to get each word from the word list
$Dice_per_word = rolls_for_combo Word_list.length
# Number of dice needed to get each symbol from the symbol list
$Dice_per_symbol = rolls_for_combo Symbol_list.length
# Assume this percent of rolls will need to be rerolled
$Reroll_percent = 5
# Convert #{$Reroll_percent} to a multiplier
$Reroll_multiple = ((100.0 + $Reroll_percent) / 100)
# The separator between each roll during input
$Separator = ''

# GLOBAL VARIABLES
$words_array = []
$rolls_array = []

def main
  roll_dice get_min_rolls
  initialize_variables
  roll_dice $Num_dice
  get_words_from_list
  get_capitals
  get_symbols
  puts $words_array
  puts "extra numbers:#{$rolls_array}"
end

main
