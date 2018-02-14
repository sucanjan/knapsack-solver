require File.expand_path('lib/knapsack_solver/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'knapsack_solver'
  s.version     = KnapsackSolver::VERSION
  s.homepage    = 'https://github.com/sucanjan/knapsack-solver'
  s.license     = 'MIT'
  s.author      = 'Jan Sucan'
  s.email       = 'sucanjan@fit.cvut.cz'

  s.summary     = '0/1 knapsack problem solver.'
  s.description = <<-EOF
This gem contains command-line utility for solving 0/1 knapsack problem using
branch-and-bound method, dynamic programming, simple heuristic (weight/price)
and fully polynomial time approximation scheme.

It can measure CPU and wall-clock time spent by solving a problem, compute
relative error of the result and generate graphs from those values.
EOF

  s.files       = Dir['bin/*', 'lib/**/*', '*.gemspec', 'LICENSE*', 'README*', 'test/*']
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }
  s.has_rdoc    = 'yard'

  s.required_ruby_version = '>= 2.2'
  
  s.add_runtime_dependency 'gnuplot', '~> 2.6'

  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.50.0'
  s.add_development_dependency 'yard', '~> 0.9'
end
