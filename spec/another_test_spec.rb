require File.dirname(__FILE__) + '/../lib/slmc'
require 'spec_helper'

describe "SLMC :: Regression of Issues for PhilHealth" do

  attr_reader :selenium_driver
  alias :slmc :selenium_driver

  before(:all) do
    @selenium_driver = SLMC.new
    @selenium_driver.start_new_browser_session



  end

  it "itest mo" do

  end

    it "itest mo" do

  end
end

