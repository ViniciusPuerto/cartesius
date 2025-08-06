# frozen_string_literal: true

require "bundler/setup"
require "rspec/expectations"

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect
  end

  # This allows you to limit a spec run to individual examples or groups
  # by tagging them with `:focus` metadata. When nothing is tagged with
  # `:focus`, all examples get run. RSpec also provides aliases for `it`,
  # `describe`, and `context` that include the `:focus` metadata.
  config.filter_run_when_matching :focus

  # This setting allows the user to run an individual example or group by
  # appending `:focus` to the example or group description. When no such
  # examples exist, all examples get run.
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://rspec.info/blog/2012/06/rspecs-new-mock-syntax/
  config.disable_monkey_patching!

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
