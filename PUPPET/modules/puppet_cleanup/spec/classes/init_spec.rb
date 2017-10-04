require 'spec_helper'
describe 'puppet_cleanup' do

  context 'with defaults for all parameters' do
    it { should contain_class('puppet_cleanup') }
  end
end
