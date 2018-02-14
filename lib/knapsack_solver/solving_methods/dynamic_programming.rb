module KnapsackSolver
  # This class implements methods for solving 0/1 knapsack problem using
  # dynamic programming with decomposition by price.
  class DynamicProgramming
    # Initializes instance of 0/1 knapsack problem solver based on dynamic
    # programming with decomposition by price.
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
      solve
      { price: @best_price, config: @best_config }
    end

    protected

    # Solve the instance of 0/1 knapsack problem using dynamic programming.
    def solve
      # Dynamic programming table
      c = all_things_price + 1 # height of array from 0 to max. price
      n = @instance.things.size + 1 # width of array, from 0th thing to Nth
      # Value used as infinity in the dynamic programming table
      @infinity = (all_things_weight + 1).freeze
      @weight_array = Array.new(n) { Array.new(c, @infinity) }
      @weight_array[0][0] = 0
      fill_table
      find_best_price
      configuration_vector
    end

    # Fill the dynamic programming table.
    def fill_table
      (1..@instance.things.size).each do |ni|
        (0..all_things_price).each do |ci|
          @weight_array[ni][ci] = minimum_weight(ni, ci)
        end
      end
    end

    # Find the value of cell in dynamic programming table.
    #
    # @param ni [Integer] X axis coordinate
    # @param ci [Integer] Y axis coordinate
    # @return [Integer]
    def minimum_weight(ni, ci)
      b = weight_of(ni - 1, ci - @instance.things[ni - 1].price)
      b += @instance.things[ni - 1].weight
      [weight_of(ni - 1, ci), b].min
    end

    # Find the best price from the filled dynamic programming table.
    def find_best_price
      @best_price = @weight_array.last[0]
      (1..all_things_price).each do |i|
        @best_price = i if @weight_array.last[i] <= @instance.weight_capacity
      end
    end

    # Reconstructs configuration vector from dynamic programming table.
    def configuration_vector
      @best_config = []
      ci = @best_price
      @instance.things.size.downto(1) do |i|
        ci = determine_config_variable(i, ci)
      end
    end

    # Determine value of one scalar for the configuration vector.
    #
    # return [Integer] next Y index to the dynamic programming table
    def determine_config_variable(i, ci)
      if @weight_array[i][ci] == @weight_array[i - 1][ci]
        @best_config[i - 1] = 0
      else
        @best_config[i - 1] = 1
        ci -= @instance.things[i - 1].price
      end
      ci
    end

    # Gets weight from dynamic programming table.
    #
    # @param i [Integer] Y index of dynamic programming table
    # @param c [Integer] X index of dynamic programming table
    # @return [Integer] the value from the array
    def weight_of(i, c)
      return @infinity if (i < 0) || (c < 0)
      @weight_array[i][c]
    end

    # Computes total price of all things of the instance.
    #
    # @return [Integer] total price
    def all_things_price
      price = 0
      @instance.things.each { |t| price += t.price }
      price
    end

    # Computes total weight of all things of the instance.
    #
    # @return [Integer] total weight
    def all_things_weight
      weight = 0
      @instance.things.each { |t| weight += t.weight }
      weight
    end
  end
end
