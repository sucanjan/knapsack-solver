require 'knapsack_solver/solving_methods/dynamic_programming'

module KnapsackSolver
  # This class implements methods for solving 0/1 knapsack problem using Fully
  # Polynomial Time Approximation Scheme.
  class Fptas
    # Initializes 0/1 knapsack FPTAS solver.
    #
    # @param instance [Instance] Instance of a 0/1 knapsack problem.
    # @param epsilon [Instances] Maximum allowed relative error of the resulting price.
    def initialize(instance, epsilon)
      @instance = instance
      @epsilon = epsilon.to_f
      @orig_prices = @instance.things.map(&:price)
    end

    # Solve the instance of 0/1 knapsack problem using FPTAS.
    #
    # @return [Hash] resulting price and thing configuration (0 = thing is not in the knapsack, 1 = thing is there)
    def run
      modify_prices_for_epsilon!
      r = DynamicProgramming.new(@instance).run
      p = get_normal_price_from_fptas(r[:config])
      { price: p, config: r[:config] }
    end

    protected

    # Modifies prices of the things according to the supplied epsilon constant
    # to achieve max. allowed relative error.
    def modify_prices_for_epsilon!
      m = @instance.things.max_by(&:price).price
      k = (@epsilon * m) / @instance.things.size
      @instance.things.each { |t| t.price = (t.price.to_f / k).floor }
    end

    # Computes resulting price using original unmodified prices of things.
    #
    # @param presenve [Array] configuration variables vector
    # @return [Integer] total price of things in the knapsack
    def get_normal_price_from_fptas(presence)
      @instance.things.reduce(0) do |price, t|
        price + ((presence[t.index] != 0 ? @orig_prices[t.index] : 0))
      end
    end
  end
end
