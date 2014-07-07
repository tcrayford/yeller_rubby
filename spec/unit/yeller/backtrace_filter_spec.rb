require_relative '../../../lib/yeller/backtrace_filter'

describe Yeller::BacktraceFilter do
  it "filters out the defined filters (sample is project root)" do
    project_root = "/var/www/my_rails_app"
    filter = Yeller::BacktraceFilter.new(
      [[project_root, '[PROJECT_ROOT]']]
    )
    filtered= filter.filter(
      [
        ["/var/www/my_rails_app/app/controllers/foo_controller.rb",
          "10",
          "index"]
    ]
    )
    filtered.should == [
      ["[PROJECT_ROOT]/app/controllers/foo_controller.rb", "10", "index"]
    ]
  end
end
