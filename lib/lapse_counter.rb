class LapseCounter
  FAILED_GRADES = ["something", "nothing", "unknown", "fail"]

  # Returns number of times a card has gone from "known" to "forgotten" after it
  # was first learned.
  #
  # https://docs.ankiweb.net/deck-options.html#lapses
  def self.count(reviews)
    # Lapses are counted when a card goes from "learned" to "forgotten". We start
    # by not counting until a card has been learned for the first time. Then we track
    # when it has been forgotten so that we only count batches of card failures once
    # per each lapse. See ./test/lapse_counter_test.rb for an example.
    lapses = 0
    learned = false
    forgotten = false
    reviews.each do |review|
      # We only want to count reviews after the first time a card was "learned"
      # so begin by skipping the failed reviews recorded while the card was still
      # in the learning phase.
      next if !learned && FAILED_GRADES.include?(review["grade"])
      learned = true

      # Here we track the first time a card is "forgotten" so we that don't count
      # multiple failures in a row which should instead represent a single lapse.
      if FAILED_GRADES.include?(review["grade"]) && !forgotten
        forgotten = true
        lapses +=1
      end

      # Reset "forgotten" when card the card is passed again
      if !FAILED_GRADES.include?(review["grade"]) && forgotten
        forgotten = false
      end
    end

    lapses
  end

  UNLEARNABLE_THRESHOLD = 8

  # unlearnable words are words that have been reviewed UNLEARNABLE_THRESHOLD times but never learned
  # OR words that have failed the last UNLEARNABLE_THRESHOLD times in a row without passing
  def self.unlearnable?(reviews)
    grades = reviews.map { |review| review["grade"] }

    # a card can't be unlearnable until it has been reviewed at least UNLEARNABLE_THRESHOLD times
    return false unless grades.size >= UNLEARNABLE_THRESHOLD

    # if all reviews have been falures
    return true if (grades.uniq - FAILED_GRADES).empty?

    # if all of the last 8 reviews have been failures
    return true if (grades.last(UNLEARNABLE_THRESHOLD).uniq - FAILED_GRADES).empty?

    false
  end
end
