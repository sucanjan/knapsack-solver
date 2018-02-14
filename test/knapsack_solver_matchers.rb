require 'rspec/expectations'

def comment_lines(file_path)
  File.open(file_path, 'r').each_line.select { |l| l.chars.first == '#' }
end

def data_lines(file_path)
  File.open(file_path, 'r').each_line.select { |l| l.chars.first != '#' }
end


RSpec::Matchers.define :be_a_regular_file do
  match do |actual|
    File.file?(actual)
  end
end

RSpec::Matchers.define :be_an_empty_directory do
  match do |actual|
    Dir.empty?(actual)
  end
end

RSpec::Matchers.define :be_a_valid_results_file do
  match do |actual|
    begin
      comment_lines = comment_lines(actual)
      data_lines = data_lines(actual)
      # It must have 3 lines: 2 comments and >= 1 data line
      return false if comment_lines.size != 2 || data_lines.size < 1
      # Data line must consist of non-negative numbers and array 1 and 0
      data_lines.each do |l|
        l.scan(/\[[^\]]*\]/).first.tr('[]', '').split(',').map { |n| n.to_i }.each do |i|
          return false if i != 0 && i != 1
        end
        l.scan(/[0-9\.]+/).map { |n| n.to_f }.each do |i|
          return false if i < 0
        end
      end
      true
    rescue
      false
    end
  end
end  

RSpec::Matchers.define :be_a_equal_to_results_file do |good|
  match do |actual|
    begin
      lines = data_lines(actual)
      good_lines = data_lines(good)
      return false if lines.size != good_lines.size
      lines.each_with_index do |l, i|
        # Check price and configuration
        return false if l.split(']').first != good_lines[i].split(']').first
        # Check relative error
        return false if l.split().last != good_lines[i].split().last
        return false if l.split().size != good_lines[i].split().size
      end
      true
    rescue
      false
    end
  end
end

RSpec::Matchers.define :be_a_equal_to_stats_file do |good|
  match do |actual|
    begin
      lines = data_lines(actual)
      good_lines = data_lines(good)
      return false if lines.size != good_lines.size
      lines.each_with_index do |l, i|
        # Check average price
        return false if l.split().first != good_lines[i].split().first
        # Check average relative error
        return false if l.split().last != good_lines[i].split().last
        return false if l.split().size != good_lines[i].split().size
      end
      true
    rescue
      false
    end
  end
end

RSpec::Matchers.define :be_a_valid_stats_file do
  match do |actual|
    begin
      comment_lines = comment_lines(actual)
      data_lines = data_lines(actual)
      # It must have 3 lines: 2 comments and 1 data line
      return false if comment_lines.size != 2 || data_lines.size != 1
      # Data line must consist of non-negative numbers
      data_lines.first.split.map { |i| i.to_f }.each do |n|
        return false if n < 0
      end
      true
    rescue
      false
    end
  end
end
