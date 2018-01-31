RSpec.configure do |config|
  # include this module if you don't want to have to type FactoryGirl for each build, create, etc:
  config.include FactoryGirl::Syntax::Methods

  config.before :suite do
    begin
      FactoryGirl.reload # make sure factories aren't cached by Spring
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end
end
