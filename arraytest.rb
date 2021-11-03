=begin
array = ["poo", "butt","fart","thing","blerp","derp", "terp","sherp","nerp"]
p array
=begin
array.insert(-2,"duh")
p array
array.each_index {|i| print i}
#=end
array.insert(10, "ninth")
p array
=begin
string="124312341234142341234312431663121243142314232143342134123413412234131241342134224133241443143124312431243121444312431431234241243123412341423"
words=11
string.slice!(0...((words*6)+3))
puts string
12431234123414234123431243166312124314231423214334213412341341223413166666665241342134224133241443143124312431243121444312431431234241243123412341423
#=end

test="dfgddhfgg"
puts test
test = "8".upcase
puts test

bluy = File.open('test.out.txt', 'a') { |f|
=begin
  f << "Four score\n"
  f << "and seven\n"
  f << "years ago\n"

  46656.times do |count|
    f .puts "#{count.to_s(36)}"
  end
}
#bluy.close
=end
base = 7
rolls = 4
array = [6, 4, 3, 1, 2, 8]
total = 0
array.shift(rolls).reverse.each_with_index do |value, index|
  puts "#{value} * (#{base}**#{index})=#{value * (base**index)}"
  total += value * (base**index)
end
print total #{}"\n #{array}"
