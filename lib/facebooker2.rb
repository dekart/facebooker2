# Facebooker2
require "mogli"

module Facebooker2

  @oauth2 = true
  @cookie_prefix = 'fbsr_'

  class NotConfigured < Exception; end


  class << self
    attr_accessor :api_key, :secret, :app_id, :canvas_page_name, :callback_url, :callback_domain, :cookie_prefix, :oauth2
  end


  def self.secret
    @secret || raise_unconfigured_exception
  end

  def self.app_id
    @app_id || raise_unconfigured_exception
  end

  def self.canvas_page_url(protocol = nil)
    "#{ protocol || 'http://' }apps.facebook.com/#{canvas_page_name}"
  end
  
  def self.callback_url(protocol = nil)
    @callback_domain ? "#{ protocol || 'http://' }#{@callback_domain}" : @callback_url
  end

  def self.raise_unconfigured_exception
    raise NotConfigured.new("No configuration provided for Facebooker2. Either set the app_id and secret or call Facebooker2.load_facebooker_yaml in an initializer")
  end

  def self.configuration=(hash)
    self.api_key = hash[:api_key]
    self.secret = hash[:secret]
    self.app_id = hash[:app_id]
    self.canvas_page_name = hash[:canvas_page_name]
    self.callback_url = hash[:callback_url]
    self.callback_domain = hash[:callback_domain]
    self.cookie_prefix = 'fbsr_' unless hash[:oauth2].blank?
    self.oauth2 = hash[:oauth2].blank? ? false : true
  end


  def self.load_facebooker_yaml
    config = YAML.load(
      ERB.new(
        File.read(::Rails.root.join("config", "facebooker.yml"))
      ).result
    )[::Rails.env]

    raise NotConfigured.new("Unable to load configuration for #{::Rails.env} from facebooker.yml. Is it set up?") if config.nil?

    self.configuration = config.with_indifferent_access
  end


  def self.cast_to_facebook_id(object)
    if object.kind_of?(Mogli::Profile)
      object.id
    elsif object.respond_to?(:facebook_id)
      object.facebook_id
    else
      object
    end
  end
end

require "facebooker2/rails/controller"
require "facebooker2/rails/controller/canvas_oauth"
require "facebooker2/rails/controller/url_rewriting"
require "facebooker2/rails/helpers/facebook_connect"
require "facebooker2/rails/helpers/javascript"
require "facebooker2/rails/helpers/request_forms"
require "facebooker2/rails/helpers/user"
require "facebooker2/rails/helpers"
require "facebooker2/rack/post_canvas"
require "facebooker2/oauth_exception"
