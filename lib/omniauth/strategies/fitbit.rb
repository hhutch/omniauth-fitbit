require 'omniauth'
require 'omniauth/strategies/oauth'

module OmniAuth
  module Strategies
    class Fitbit < OmniAuth::Strategies::OAuth

      DEFAULT_DISPLAY = "touch"
      
      option :name, "fitbit"

      option :client_options, {
          :site               => 'https://api.fitbit.com',
          :request_token_path => '/oauth/request_token',
          :access_token_path  => '/oauth/access_token',
          :authorize_path     => '/oauth/authorize'
      }

      option :authorize_options, [:scope, :display, :auth_type]
      
      uid do
        access_token.params['encoded_user_id']
      end

      info do
        {
            :name         => raw_info['user']['displayName'],
            :full_name    => raw_info['user']['fullName'],
            :display_name => raw_info['user']['displayName'],
            :nickname     => raw_info['user']['nickname'],
            :gender       => raw_info['user']['gender'],
            :about_me     => raw_info['user']['aboutMe'],
            :city         => raw_info['user']['city'],
            :state        => raw_info['user']['state'],
            :country      => raw_info['user']['country'],
            :dob          => !raw_info['user']['dateOfBirth'].empty? ? Date.strptime(raw_info['user']['dateOfBirth'], '%Y-%m-%d'):nil,
            :member_since => Date.strptime(raw_info['user']['memberSince'], '%Y-%m-%d'),
            :locale       => raw_info['user']['locale'],
            :timezone     => raw_info['user']['timezone']
        }
      end

      extra do
        {
            :raw_info => raw_info
        }
      end

      def raw_info
        if options[:use_english_measure] == 'true'
          @raw_info ||= MultiJson.load(access_token.request('get', 'https://api.fitbit.com/1/user/-/profile.json', { 'Accept-Language' => 'en_US' }).body)
        else
          @raw_info ||= MultiJson.load(access_token.get('https://api.fitbit.com/1/user/-/profile.json').body)
        end
      end

      # You can pass +display+, +scope+, or +auth_type+ params to the auth request, if you need to set them dynamically.
      # You can also set these options in the OmniAuth config :authorize_params option.
      #
      # For example: /auth/fitbit?display=popup
      def authorize_params
        super.tap do |params|
          %w[display scope auth_type].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:display] ||= DEFAULT_DISPLAY
        end
      end
      
    end
  end
end
