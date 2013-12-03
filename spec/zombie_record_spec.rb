require 'spec_helper'

describe ZombieRecord do
  it 'should have a version number' do
    ZombieRecord::VERSION.should_not be_nil
  end

  it 'should do something useful' do
    false.should be_true
  end
end
