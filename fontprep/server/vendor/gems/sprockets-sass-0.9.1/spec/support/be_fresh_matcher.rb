RSpec::Matchers.define :be_fresh do |env|
  match do |actual|
    if actual.method(:fresh?).arity == 1
      actual.fresh?(env)
    else
      actual.fresh?
    end
  end
  
  failure_message_for_should do |env|
    'expected asset to be fresh'
  end
  
  failure_message_for_should_not do |env|
    'expected asset to be stale'
  end
end
