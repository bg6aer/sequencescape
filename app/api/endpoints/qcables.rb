class ::Endpoints::Qcables < ::Core::Endpoint::Base
  model do

  end

  instance do
    belongs_to(:asset,  :json => 'asset')
  end

end
