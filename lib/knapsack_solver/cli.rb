require 'knapsack_solver/solver'
require 'knapsack_solver/version'
require 'knapsack_solver/cli_option_parser'
require 'knapsack_solver/output_printer'
require 'knapsack_solver/graph_printer'

module KnapsackSolver
  # This class implements a command-line interface for the 0/1 knapsack
  # problem solver.
  class CLI
    # Suffix of a text file which will containg results of dataset solving
    # (price, knapsack things presence, cpu time, wall clock time,
    # relative_error).
    RESULTS_FILNEMAE_SUFFIX = '.results'.freeze

    # Suffix of a text file which will containg statistic data (average price,
    # execution times, relative error)
    STATS_FILNEMAE_SUFFIX = '.stats'.freeze

    # Processes command-line arguments. If no option is given, converts arabic
    # number to roman number and prints it to stdout.
    #
    # @param args [Array] the command-line arguments
    def self.run(args)
      options = CliOptionParser.parse(args)
      return if options.nil?
      datasets = args.each_with_object([]) do |file, sets|
        sets << Dataset.parse(File.new(file))
      end
      s = Solver.new(options, datasets)
      results = s.run
      print_results(results, s.stats(results), options, args)
    end

    # Prints output of datasets solving. Results and statistics are printed to
    # stdout or to a text files. Graphs of statistic values can be created.
    #
    # @param results [Hash] results of dataset solvings
    # @param stats [Hash] statistics from the results of dataset solvings
    # @param options [Hash] Command-line line options supplied to the CLI
    # @param args [Array] array of the positional command-line arguments
    def self.print_results(results, stats, options, args)
      OutputPrinter.new(args, RESULTS_FILNEMAE_SUFFIX, results).print(options[:output_dir])
      OutputPrinter.new(args, STATS_FILNEMAE_SUFFIX, stats).print(options[:output_dir])
      return unless options[:graphs_dir]
      GraphPrinter.new(args, stats, options[:graphs_dir]).print
    end
  end
end
