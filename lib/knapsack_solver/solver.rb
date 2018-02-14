require 'benchmark'

require 'knapsack_solver/dataset'
require 'knapsack_solver/solving_methods/heuristic_price_weight'
require 'knapsack_solver/solving_methods/branch_and_bound'
require 'knapsack_solver/solving_methods/dynamic_programming'
require 'knapsack_solver/solving_methods/fptas'

module KnapsackSolver
  # This class solves datasets of 0/1 knapsack problem instances using a
  # requested solving methods. It measures execution time of a solving and
  # computes relative error if some exact solving method is requested.
  class Solver
    # Initializes solver for use of user selected solving methods.
    #
    # @param opts [Hash] parser command-line options
    # @param datasets [Hash] parsed sets of 0/1 knapsack problem instances
    def initialize(opts, datasets)
      @opts = opts
      @datasets = datasets
      @solver_objects = {}
      { branch_and_bound: 'KnapsackSolver::BranchAndBound',
        dynamic_programming: 'KnapsackSolver::DynamicProgramming',
        heuristic: 'KnapsackSolver::HeuristicPriceToWeight',
        fptas: 'KnapsackSolver::Fptas' }.each do |symbol, class_name|
        @solver_objects[symbol] = Object.const_get(class_name) if opts[symbol]
      end
    end

    # Solve datasets using all selected method of solving, measure their
    # execution time and compute relative errors if some exact method was
    # requested.
    #
    # @return [Hash] results of dataset solving
    def run
      results = @datasets.each_with_object({}) do |dataset, res|
        res[dataset.id] = @solver_objects.each_with_object({}) do |(solver, object), r|
          r[solver] = dataset.instances.each_with_object([]) do |inst, a|
            o = object.new(inst) unless solver == :fptas
            o = object.new(inst, @opts[:fptas_epsilon]) if solver == :fptas
            a << execution_time { o.run }
          end
        end
      end
      add_relative_error(results)
    end

    # Creates statistics (average price, execution times, relative error) from
    # results of solving.
    #
    # @param results [Hash] solving results of datasets and solving methods
    # @return [Hash] statistics for datasets and solving methods
    def stats(results)
      results.each_with_object({}) do |(dataset_id, method_results), q|
        q[dataset_id] = method_results.each_with_object({}) do |(met, res), p|
          p[met] = averages(res)
        end
      end
    end

    protected

    # Computes average values from the results.
    #
    # @param res [Hash] results for one dataset and one method
    # @return [Array<Hash>] array of computed average values
    def averages(res)
      [res.first.keys.reject { |k| k == :config }.each_with_object({}) do |v, o|
         values = res.map { |i| i[v] }
         o[('avg_' + v.to_s).to_sym] = values.reduce(:+).to_f / values.size
       end]
    end

    # Adds relative error to results of solving if some exact method of
    # solving was requested.
    #
    # @param results [Hash] results of solving using requested methods
    # @return [Hash] the results with relative error added
    def add_relative_error(results)
      return results unless @opts[:branch_and_bound] || @opts[:dynamic_programming]
      exact_method = @opts[:branch_and_bound] ? :branch_and_bound : :dynamic_programming
      results.each_value do |method_results|
        method_results.each_value do |res|
          res.each_with_index do |r, i|
            r[:relative_error] = relative_error(method_results[exact_method][i][:price], r[:price])
          end
        end
      end
      results
    end

    # Measure execution time of provided block so that measured time is non-zero.
    #
    # @yieldparam block for which execution time will be measured
    # @return [Hash] solving results with cpu time and wall clock time of execution
    def execution_time
      exec_count = 1
      result = nil
      cpu_time = wall_clock_time = 0.0
      while cpu_time.zero? || wall_clock_time.zero?
        b = Benchmark.measure { exec_count.times { result = yield } }
        cpu_time += b.total
        wall_clock_time += b.real
        exec_count *= 2
      end
      result.merge(cpu_time: cpu_time, wall_clock_time: wall_clock_time)
    end

    # Computes relative error of approximate solution.
    #
    # @param opt [Numeric] Optimal price.
    # @param apx [Numeric] Approximate price.
    # @return [Float] Relative error.
    def relative_error(opt, apx)
      (opt.to_f - apx.to_f) / opt.to_f
    end
  end
end
