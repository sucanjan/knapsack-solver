require 'rspec'
require 'tmpdir'
require_relative 'spec_helper'
require_relative 'knapsack_solver_matchers'
require_relative '../lib/knapsack_solver/cli.rb'
require_relative '../lib/knapsack_solver/version.rb'

module FileHelper
  def file_list(directory, files)
    files.map { |f| File.join(directory, f) }
  end
end

module ArgumentHelper
  def args(args_string = nil)
    return [] if args_string.nil?
    args_string.split
  end

  def args_in_dataset_out_file(args_string, tmpdir)
    args(args_string) + ['-o', tmpdir, 'test/datasets/size_4.dataset', 'test/datasets/size_10.dataset']
  end
end

describe KnapsackSolver::CLI do
  include FileHelper
  include ArgumentHelper

  subject(:cli) { KnapsackSolver::CLI }

  context 'options' do
    it 'recognizes invalid options' do
      expect { cli.run(args('-a')) }.to raise_error(OptionParser::InvalidOption)
      expect { cli.run(args('-k -h')) }.to raise_error(OptionParser::InvalidOption)
      expect { cli.run(args('-x -b')) }.to raise_error(OptionParser::InvalidOption)
    end

    it 'detects missing arguments' do
      expect { cli.run(args('-o')) }.to raise_error(OptionParser::MissingArgument)
      expect { cli.run(args('-g')) }.to raise_error(OptionParser::MissingArgument)
    end
    
    it '-h has the top priority among valid options' do
      expect { cli.run(args('-b -v -h')) }.to output(/Usage:/).to_stdout
      expect { cli.run(args('-b -h -v')) }.to output(/Usage:/).to_stdout
      expect { cli.run(args('-h -b -v')) }.to output(/Usage:/).to_stdout
    end

    it '-v has a second from the top priority among valid options' do
      expect { cli.run(args('-v -h')) }.to output(/Usage:/).to_stdout
      expect { cli.run(args('-v -b')) }.to output(/knapsack_solver #{KnapsackSolver::VERSION}/).to_stdout
    end

    it 'at least one method of solving must be selected' do
      Dir.mktmpdir() do |tmpdir|
        expect { cli.run(args()) }.to raise_error(/At least one method of solving must be requested/)
        expect { cli.run(args_in_dataset_out_file('-b', tmpdir)) }.not_to raise_error
      end
    end
    
    it 'FPTAS must have epsilon constant provided' do
      Dir.mktmpdir() do |tmpdir|
        expect { cli.run(args_in_dataset_out_file('-f', tmpdir)) }.to raise_error(/Missing FPTAS epsilon constant/)
        expect { cli.run(args_in_dataset_out_file('-f -e 0.5', tmpdir)) }.not_to raise_error
      end      
    end

    it 'FPTAS epsilon constant must be number from range (0,1)' do
      Dir.mktmpdir() do |tmpdir|
        expect { cli.run(args_in_dataset_out_file('-f -e asdf', tmpdir)) }.to raise_error(/FPTAS epsilon must be number from range \(0,1\)/)
        expect { cli.run(args_in_dataset_out_file('-f -e 0.5x', tmpdir)) }.to raise_error(/FPTAS epsilon must be number from range \(0,1\)/)
        expect { cli.run(args_in_dataset_out_file('-f -e -0.3', tmpdir)) }.to raise_error(/FPTAS epsilon must be number from range \(0,1\)/)
        expect { cli.run(args_in_dataset_out_file('-f -e 0', tmpdir)) }.to raise_error(/FPTAS epsilon must be number from range \(0,1\)/)
        expect { cli.run(args_in_dataset_out_file('-f -e 0.01', tmpdir)) }.not_to raise_error
        expect { cli.run(args_in_dataset_out_file('-f -e 0.99', tmpdir)) }.not_to raise_error
        expect { cli.run(args_in_dataset_out_file('-f -e 1', tmpdir)) }.to raise_error(/FPTAS epsilon must be number from range \(0,1\)/)
      end      
    end

    it 'epsilon constant must not be provided when FPTAS is not selected' do
      Dir.mktmpdir() do |tmpdir|
        expect { cli.run(args_in_dataset_out_file('-b -e 0.5', tmpdir)) }.to raise_error(/epsilon constant must not be provided when FPTAS is not selected/)
        expect { cli.run(args_in_dataset_out_file('-b -f -e 0.5', tmpdir)) }.not_to raise_error
      end      
    end

  end
  
  context 'positional arguments' do
    it 'must have at least one dataset provided' do
      expect { cli.run(args('-b')) }.to raise_error(/Missing datset file\(s\)/)
    end

    it 'dataset path must be a path to a regular file' do
      Dir.mktmpdir do |tmpdir|
        expect { cli.run(args('-b ' + tmpdir)) }.to raise_error(/is not a regular file/)
      end      
    end

    it 'dataset file must exist' do
      Dir.mktmpdir do |tmpdir|
        not_existent_file = File.join(tmpdir, 'size_4.dataset')
        expect { cli.run(args('-b ' + not_existent_file)) }.to raise_error(/does not exists/)
      end      
    end
    
    it 'dataset file must be readable' do
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp('test/datasets/size_4.dataset', tmpdir)
        not_readable_file = File.join(tmpdir, 'size_4.dataset')
        FileUtils.chmod('a-r', not_readable_file)
        expect { cli.run(args('-b ' + not_readable_file)) }.to raise_error(/is not readable/)
      end      
    end

    it 'dataset file must have correct format' do
      Dir.mktmpdir do |tmpdir|
        invalid_files = %w(invalid_1.dataset
                           invalid_2.dataset
                           invalid_3.dataset
                           invalid_4.dataset
                           invalid_5.dataset
                           invalid_6.dataset
                           invalid_7.dataset
                           invalid_8.dataset)
        error_messages = ['missing ID',
                          'first line does not contain ID',
                          'ID is negative',
                          'ID is not an integer',
                          'missing knapsack capacity',
                          'missing pairs \(price, weight\)',
                          'instance desctiption contains negative number',
                          'instance desctiption does not contain only integers']
        file_list('test/invalid_datasets', invalid_files).each_with_index do |f, i|
          expect { cli.run(args('-d ' + f)) }.to raise_error(/#{error_messages[i]}/)
        end
      end      
    end
  end
  
  context 'output of results' do
    it 'directory for the output logs must exist' do
      Dir.mktmpdir do |tmpdir|
        not_existent_file = File.join(tmpdir, 'size_4.dataset')
        expect { cli.run(args('-b -o ' + not_existent_file)) }.to raise_error(/does not exists/)
      end      
    end

    it 'path to a directory for the output logs must point to a directory' do
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp('test/datasets/size_4.dataset', tmpdir)
        file = File.join(tmpdir, 'size_4.dataset')
        expect { cli.run(args('-b -o ' + file)) }.to raise_error(/is not a directory/)
      end      
    end

    it 'directory for the output logs must be writable' do
      Dir.mktmpdir do |tmpdir|
        not_writable_dir = File.join(tmpdir, 'dir')
        Dir.mkdir(not_writable_dir)
        FileUtils.chmod('a-w', not_writable_dir)
        expect { cli.run(args('-b -o ' + not_writable_dir)) }.to raise_error(/is not writable/)
      end      
    end

    it 'directory for the graph files must exist' do
      Dir.mktmpdir do |tmpdir|
        not_existent_file = File.join(tmpdir, 'size_4.dataset')
        expect { cli.run(args('-b -g ' + not_existent_file)) }.to raise_error(/does not exists/)
      end      
    end

    it 'path to a directory for the graph files must point to a directory' do
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp('test/datasets/size_4.dataset', tmpdir)
        file = File.join(tmpdir, 'size_4.dataset')
        expect { cli.run(args('-b -g ' + file)) }.to raise_error(/is not a directory/)
      end      
    end

    it 'directory for the graph files must be writable' do
      Dir.mktmpdir do |tmpdir|
        not_writable_dir = File.join(tmpdir, 'dir')
        Dir.mkdir(not_writable_dir)
        FileUtils.chmod('a-w', not_writable_dir)
        expect { cli.run(args('-b -g ' + not_writable_dir)) }.to raise_error(/is not writable/)
      end      
    end

    it 'writes graph files' do
      Dir.mktmpdir do |tmpdir|
        png_files = %w(avg_price.png avg_cpu_time.png avg_wall_clock_time.png avg_relative_error.png)
        gnuplot_files = %w(avg_price.gnuplot avg_cpu_time.gnuplot avg_wall_clock_time.gnuplot avg_relative_error.gnuplot)
        files = png_files + gnuplot_files
        cli.run(args_in_dataset_out_file('-b -g ' + tmpdir, tmpdir))
        expect(file_list(tmpdir, files)).to all be_a_regular_file
      end      
    end

    it 'writes results and stats to files' do
      Dir.mktmpdir do |tmpdir|
        results_files = %w(size_4_branch_and_bound.results size_10_branch_and_bound.results)
        stats_files = %w(size_4_branch_and_bound.stats size_10_branch_and_bound.stats)
        files = results_files + stats_files
        cli.run(args_in_dataset_out_file('-b', tmpdir))
        expect(file_list(tmpdir, files)).to all be_a_regular_file
      end
    end

    it 'writes results and stats to stdout' do
      results_files = %w(size_4_branch_and_bound.results size_10_branch_and_bound.results)
      stats_files = %w(size_4_branch_and_bound.stats size_10_branch_and_bound.stats)
      files = results_files + stats_files
      files.each do |f|
        expect { cli.run(args('-b test/datasets/size_4.dataset test/datasets/size_10.dataset')) }.to output(/#{f}/).to_stdout
      end
    end

    it 'adds relative error if an exact solving method is selected' do
      expect { cli.run(args('-r test/datasets/size_4.dataset test/datasets/size_10.dataset')) }.not_to output(/avg_relative_error/).to_stdout
      expect { cli.run(args('-f -e 0.5 -r test/datasets/size_4.dataset test/datasets/size_10.dataset')) }.not_to output(/avg_relative_error/).to_stdout
      expect { cli.run(args('-b -r test/datasets/size_4.dataset test/datasets/size_10.dataset')) }.to output(/avg_relative_error/).to_stdout
      expect { cli.run(args('-d -r test/datasets/size_4.dataset test/datasets/size_10.dataset')) }.to output(/avg_relative_error/).to_stdout
    end

    it 'produces correct results' do
      Dir.mktmpdir do |tmpdir|
        results_files = %w(size_10_dynamic_programming.results
                           size_10_fptas.results
                           size_10_heuristic.results
                           size_4_dynamic_programming.results
                           size_4_fptas.results
                           size_4_heuristic.results)
        stats_files = %w(size_10_dynamic_programming.stats
                         size_10_fptas.stats
                         size_10_heuristic.stats
                         size_4_dynamic_programming.stats
                         size_4_fptas.stats
                         size_4_heuristic.stats)
        good_results_files = results_files.map { |f| File.join('test/output_logs', f) }
        good_stats_files = stats_files.map { |f| File.join('test/output_logs', f) }
        files = results_files + stats_files
        cli.run(args_in_dataset_out_file('-b -d -r -f -e 0.5', tmpdir))
        expect(file_list(tmpdir, files)).to all be_a_regular_file
        expect(file_list(tmpdir, results_files)).to all be_a_valid_results_file
        expect(file_list(tmpdir, stats_files)).to all be_a_valid_stats_file

        file_list(tmpdir, results_files).each_with_index do |f, i|
          expect(f).to be_a_equal_to_results_file(good_results_files[i])
        end

        file_list(tmpdir, stats_files).each_with_index do |f, i|
          expect(f).to be_a_equal_to_stats_file(good_stats_files[i])
        end
      end
     
    end

  end

end
