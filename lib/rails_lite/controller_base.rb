require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    unless already_rendered?
      @res['location'] = url  # sets the response header location to the given url
      @res.status = 302
      session.store_session(@res)
      flash.store_flash(@res)
      @already_rendered = true
    end
  end

  def render_content(content, type)
    unless already_rendered?
      @res.body = content
      @res.content_type = type
      session.store_session(@res)
      flash.store_flash(@res)
      @already_rendered = true
    end
  end

  def render(template_name)
    f = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")
    template = ERB.new(f).result(binding)
    render_content(template, 'text/html')
  end

  def invoke_action(name)
    if @params[:autheticity_token] == session[:autheticity_token] || @req.request_method.downcase.to_sym == :get
      send(name)
      render(name) unless already_rendered?
    end
  end
end
