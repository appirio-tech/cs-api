require 'spec_helper'

describe Member do 

	it 'says hello' do
		Member.hello.should == 'hello world'
	end

end