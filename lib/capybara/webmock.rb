require 'capybara'
require 'capybara/webmock/version'
require 'capybara/webmock/proxy'

module Capybara
  module Webmock

    class << self

      def start
        log_file   = File.join('log', 'test.log')
        gem_path   = File.dirname(__FILE__)
        proxy_file = File.join(gem_path, 'webmock', 'config.ru')
        IO.popen("rackup #{proxy_file} >> #{log_file} 2>&1")
      end

      def stop
        if File.exists?(Capybara::Webmock::Proxy::PID_FILE)
          rack_pid = File.read(Capybara::Webmock::Proxy::PID_FILE).to_i
          Process.kill('HUP', rack_pid)
        end
      end

    end
  end
end

Capybara.register_driver :capybara_webmock do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["network.proxy.type"] = 1
  profile["network.proxy.http"] = '127.0.0.1'
  profile["network.proxy.http_port"] = 9292
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end
