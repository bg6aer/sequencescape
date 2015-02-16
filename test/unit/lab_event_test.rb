#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011 Genome Research Ltd.
require "test_helper"

class LabEventTest < ActiveSupport::TestCase
  context "An event" do
    should_belong_to :user, :eventful
  end
end
