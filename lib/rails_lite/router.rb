require_relative 'session'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
    generate_helper
  end

  def matches?(req)
    @http_method == req.request_method.downcase.to_sym && req.path =~ @pattern
  end

  def run(req, res)
    matches = @pattern.match(req.path)
    params = {}

    matches.names.each { |k| params[k.to_sym] = matches[k] }
    @controller_class.new(req, res, params).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.find {|route| route.matches?(req)}
  end

  def run(req, res)
    route = match(req) 
    if route 
      route.run(req, res)
    else
      res.status = 404
    end
  end
end

module URLHelper


  def generate_helper
    if [:show, :edit, :destroy, :update].includes?(@action_helper)
      define_method(method_name.join('_').to_sym) do |*args|
        "#{method_name[-2].pluralize}/#{args[0]}"
      end
    else
      define_method(method_name.join('_').to_sym) do

  end

  private

  def method_name
    name = {}
    name[:controller] = @controller_class.underscore.split('_').first}
    if @action_name == :index || @action_name == :create
      name[:controller] = name[:controller].pluralize
    elsif [:new, :edit].includes?(@action_name) 
      name[:action] = @action_name
    end
    name[:path_name] = "#{name[:action]}_#{name[:controller]}_path"
  end



end
