module KnapsackSolver
  # This class implements methods for solving 0/1 knapsack problem using
  # simple heuristic by price to weight ratio. Things with the best price to
  # weight ratio are selected first.
  class HeuristicPriceToWeight
    # Initializes instance of 0/1 knapsack problem solver using simple
    # heuristic by price to weight ratio.
    #
    # @param instance [Instance] 0/1 knapsack problem instance
    def initialize(instance)
      @instance = instance
      @config = Array.new(instance.things.size) { 0 }
      @sorted_things = instance.things.sort do |a, b|
        (b.price.to_f / b.weight) <=> (a.price.to_f / a.weight)
      end
    end

    # Solve the instance of 0/1 knapsack problem.
    #
    # @return [Hash] resulting price and thing configuration (0 = thing is not in the knapsack, 1 = thing is there)
    def run
      solve
      { price: @best_price, config: @best_config }
    end

    protected

    # Solve the instance of 0/1 knapsack problem.
    def solve
      @sorted_things.each do |thing|
        break if (config_weight + thing.weight) > @instance.weight_capacity
        @config[thing.index] = 1
      end
      @best_price = config_price
      @best_config = @config.dup
    end

    # Gets total weight of things present in the knapsack.
    #
    # @return [Integer] total weight
    def config_weight
      @config.each_with_index.reduce(0) do |weight, (presence, index)|
        weight + presence * @instance.things[index].weight
      end
    end

    # Gets total price of things present in the knapsack.
    #
    # @return [Integer] total price
    def config_price
      @config.each_with_index.reduce(0) do |price, (presence, index)|
        price + presence * @instance.things[index].price
      end
    end
  end
end
