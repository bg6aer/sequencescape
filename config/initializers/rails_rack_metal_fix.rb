#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011 Genome Research Ltd.
# By default Rails metal applications can return 404 to say that they don't handle the request.
# However, we use 404 in the API to indicate that we have handled the request but the resource
# does not exist.  So here we monkeypatch Rails so that if the 404 response has a body then we
# can return that.
class Rails::Rack::Metal
  def call(env)
    @metals.keys.each do |app|
      result = app.call(env)
      return result unless result[0].to_i == 404 and result[2].blank?
    end
    @app.call(env)
  end
end
