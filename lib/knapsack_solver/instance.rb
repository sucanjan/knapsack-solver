module KnapsackSolver
  # This class represents an instance of a 0/1 knapsack problem.
  class Instance
    # Initializes instance of a 0/1 knapsack problem.
    #
    # @param capacity [Integer] weight capacity of the knapsack
    # @param things [Array<Thing>] things which can be put into the knapsack
    def initialize(capacity, things)
      @weight_capacity = capacity
      @things = things
    end

    # Creates new instance of a 0/1 knapsack problem.
    #
    # @param line [String] line that describes an instance of a 0/1 knapsack problem
    # @return [Instance] instance of the 0/1 knapsack problem
    def self.parse(line)
      thing = Struct.new(:price, :weight, :index)
      # Rozdelit riadok na slova a previest na cisla
      items = split_line(line)
      # Inicializacia premennych
      things = items.drop(1).each_slice(2).with_index.each_with_object([]) do |(s, i), o|
        o << thing.new(s[0], s[1], i)
      end
      Instance.new(items[0], things)
    end

    # Splits line that describes an instance of a 0/1 knapsack problem to
    # individual numbers.
    #
    # @param line [String] line that describes an instance of a 0/1 knapsack problem
    # @return [Array<Integer>] integer numbers from the line
    def self.split_line(line)
      items = line.split.map! do |i|
        n = Integer(i)
        raise StandardError, 'dataset: instance desctiption contains negative number' if n < 0
        n
      end
      raise StandardError, 'dataset: missing knapsack capacity' if items.empty?
      raise StandardError, 'dataset: missing pairs (price, weight)' if items.size.even?
      items
    rescue ArgumentError
      raise StandardError, 'dataset: instance desctiption does not contain only integers'
    end

    attr_reader :weight_capacity, :things
  end
end
