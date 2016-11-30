require 'minitest/autorun'

if ENV.has_key? 'RUBYMINE'
  require 'minitest/reporters'
  Minitest::Reporters.use! Minitest::Reporters::RubyMineReporter
end
