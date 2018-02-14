module KnapsackSolver
  # This class implements methods for solving 0/1 knapsack problem using
  # Branch and Bound method.
  class BranchAndBound
    # Initializes instance of Brand and Bound 0/1 knapsack problem solver.
    #
    # @param instance [Instance] 0/1 knapsack problem instance
    def initialize(instance)
      @instance = instance
      @config = Array.new(instance.things.size)
    end

    # Solve the instance of 0/1 knapsack problem.
    #
    # @return [Hash] resulting price and thing configuration (0 = thing is not in the knapsack, 1 = thing is there)
    def run
      solve(0)
      { price: @best_price, config: @best_config }
    end

    protected

    # Solve the problem starting at specified thing.
    #
    # @param index [Integer] index of thing which will be decided (put in or out from the knapsack) the next
    def solve(index)
      @config[index] = 0
      solve(index + 1) unless stop(index)
      @config[index] = 1
      solve(index + 1) unless stop(index)
    end

    # Determine if solving of current branch should continue.
    #
    # @param index [Integer] index of the last decided thing so far
    # @return [true, false] weather to continue with solving current branch.
    def stop(index)
      # Update of the best price so far
      weight = config_weight(0, index)
      price = config_price(0, index)
      update_best_price(price, weight, index)
      # No more things to put into the knapsack
      return true if index >= (@instance.things.size - 1)
      # The knapsack is overloaded, do not continue this branch
      return true if weight > @instance.weight_capacity
      if instance_variable_defined?('@best_price') &&
         ((price + get_price_of_remaining_things(index + 1)) <= @best_price)
        # Adding all the ramining things does not produce better price
        return true
      end
      false
    end

    # Update the best price achieved so far.
    #
    # @param price [Integer] price of the current configuration
    # @param weight [Integer] weight of the current configuration
    # @param index [Integer] index of the next thing presence of which will be decided
    def update_best_price(price, weight, index)
      if !instance_variable_defined?('@best_price') ||
         ((weight <= @instance.weight_capacity) && (price > @best_price))
        @best_price = price
        valid_len = index + 1
        remaining = @config.size - index - 1
        # All undecided things will not be put into the knapsack
        @best_config = @config.slice(0, valid_len).fill(0, valid_len, remaining)
        @best_config_index = index
      end
    end

    # Gets weight of set of things. The set is subset of the things ordered by
    # their index.
    #
    # @param start_index [Integer] index of the first thing included in the set
    # @param end_index [Integer] index of the last thing included in the set
    # @return [Integer] weight of the things
    def config_weight(start_index, end_index)
      weight = 0
      @config[start_index..end_index].each_with_index do |presence, index|
        weight += presence * @instance.things[index].weight
      end
      weight
    end

    # Gets price of set of things. The set is subset of the things ordered by
    # their index.
    #
    # @param start_index [Integer] index of the first thing included in the set
    # @param end_index [Integer] index of the last thing included in the set
    # @return [Integer] price of the things
    def config_price(start_index, end_index)
      price = 0
      @config[start_index..end_index].each_with_index do |presence, index|
        price += presence * @instance.things[index].price
      end
      price
    end

    # Gets sum of prices of things for which their presence in the knapsack
    # was not decided yet.
    #
    # @param from_index [Integer] index of the first undecided thing
    # @return [Integer] price of the remaining things
    def get_price_of_remaining_things(from_index)
      price = 0
      to_index = @instance.things.size - 1
      @instance.things[from_index..to_index].each { |t| price += t.price }
      price
    end
  end
end
