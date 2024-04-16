require_relative "../lib/lapse_counter"
require_relative "../lib/string_utils"

# Test LapseCounter.count() method
reviews = [
  { "grade" => "unknown" },
  { "grade" => "nothing" },
  { "grade" => "nothing" },
  { "grade" => "okay" }, # learned
  { "grade" => "okay" },
  { "grade" => "okay" },
  { "grade" => "nothing" }, # lapse 1
  { "grade" => "something" }, # not re-learned yet
  { "grade" => "okay" }, # re-learned
  { "grade" => "okay" },
  { "grade" => "okay" },
  { "grade" => "nothing" }, # lapse 2
  { "grade" => "something" }, # not re-learned yet
  { "grade" => "okay" }, # re-learned
  { "grade" => "okay" },
  { "grade" => "okay" },
]
test_name = "LapseCounter ignores initial learning period and doesn't count multiple failed grades per lapse"

if LapseCounter.count(reviews) == 2
  puts "PASS: #{test_name}".green
else
  puts "FAIL: #{test_name}".red
end

# Test LapseCounter.unlearnable?() method
reviews = [
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "something" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
]
test_name = "LapseCounter counts a card as unlearnable if it has been reviewed 8 times and they are all failures"

if LapseCounter.unlearnable?(reviews)
  puts "PASS: #{test_name}".green
else
  puts "FAIL: #{test_name}".red
end

reviews = [
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "okay" },
  { "grade" => "something" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
  { "grade" => "unknown" },
]
test_name = "LapseCounter does not count a card as unlearnable if it has ever passed"

unless LapseCounter.unlearnable?(reviews)
  puts "PASS: #{test_name}".green
else
  puts "FAIL: #{test_name}".red
end
