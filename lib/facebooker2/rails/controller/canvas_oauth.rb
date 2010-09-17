module Facebooker2
  module Rails
    module Controller
      module CanvasOAuth
        def self.included(controller)
          controller.extend(CanvasOAuthClass)

          class << controller
            attr_accessor :_facebooker_oauth_callback_url, :_facebooker_scope
          end
        end

        protected
          def canvas_oauth_connect
            raise "Canvas page name not defined! Define it in config/facebooker.yml as #{::Rails.env}: canvas_page_name: <your url>." if !Facebooker2.canvas_page_name
            if params[:error]
              raise Facebooker2::OAuthException.new(params[:error][:message])
            else
              redirect_to ('http://apps.facebook.com/' + Facebooker2.canvas_page_name) if params[:code]
            end
            return false
          end

          def ensure_canvas_connected
            case self.class._facebooker_oauth_callback_url
              when Symbol
                callback_url = send(self.class._facebooker_oauth_callback_url)
            end

            if current_facebook_user == nil && !params[:code] && !params[:error]
              render :text => "<script>top.location.href = 'https://graph.facebook.com/oauth/authorize?client_id=#{Facebooker2.app_id}&redirect_uri=#{callback_url}&scope=#{[ self.class._facebooker_scope ].flatten * ','}'</script>"
              return false
            end
          end
      end

      module CanvasOAuthClass
        def ensure_canvas_connected_to_facebook(oauth_callback_url, *scope)
          self._facebooker_oauth_callback_url = oauth_callback_url
          self._facebooker_scope = scope

          before_filter :ensure_canvas_connected
        end

        def create_facebook_oauth_callback(method_name)
          self.class_eval(<<-EOT)
            def #{method_name}
              return canvas_oauth_connect
            end
          EOT
        end
      end
    end
  end
end
