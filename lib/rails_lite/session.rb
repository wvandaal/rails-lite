require 'json'
require 'webrick'

class Session
  def initialize(req)
  	cookie = req.cookies.find { |cookie| cookie.name == '_rails_lite_app' }
 		p cookie
    @session = !!cookie ? JSON.parse(cookie.value) : {}
  end

  def [](key)
  	@session[key]
  end

  def []=(key, val)
  	@session[key] = val
  end

  def csrf
    {athenticity_token: SecureRandom.urlsafe_base64}
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', JSON.generate(csrf))
  	res.cookies << WEBrick::Cookie.new('_rails_lite_app', JSON.generate(@session))
  end
end

class Flash

  def initialize
    @flash = {}
  end

  def [](key)
    @flash[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

  def store_flash(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', JSON.generate(@flash))
    @flash = {}
  end

end


