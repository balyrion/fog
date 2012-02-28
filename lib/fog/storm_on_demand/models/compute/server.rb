require 'fog/compute/models/server'

module Fog
  module Compute
    class StormOnDemand

      class Server < Fog::Compute::Server
        identity :uniq_id

        attribute :accnt
        attribute :backup_enabled
        attribute :backup_plan
        attribute :backup_quota
        attribute :backup_size
        attribute :bandwidth_quota
        attribute :config_description
        attribute :config_id
        attribute :create_date
        attribute :domain
        attribute :image_id
	attribute :ip
        attribute :ip_count
        attribute :manage_level
        attribute :subaccnt
        attribute :template
        attribute :template_description
        attribute :zone
        attribute :active

        attr_writer :password, :username

        def initialize(attributes={})
          self.config_id ||= 3 # 2 GB
	  self.template ||= 'UBUNTU_1004_UNMANAGED' #Ubuntu 10.04
	  self.backup_enabled ||= 0 #No backups
	  self.bandwidth_quota ||= 0 #Pay as you go
	  self.ip_count ||= 1
	  self.zone ||= 12 #US Central Zone B
	  super
        end

#        def create(options)
#          data = connection.create_server(options).body['servers']
#          load(data)
#        end

        def destroy
          requires :identity
          connection.delete_server(:uniq_id => identity)
          true
        end

        def ready?
          active == 1
        end

        def reboot
          requires :identity
          connection.reboot_server(:uniq_id => identity)
          true
        end

	def save
	  raise Fog::Errors::Error.new('Resaving an existing object may create a duplicate') if identity
	  requires :domain
	  options = {
	    'zone' => zone,
	    'template' => template,
	    'image_id' => image_id,
	    'config_id' => config_id,
#	    'password' => password,
	    'ip_count' => ip_count,
	    'backup_enabled' => backup_enabled,
	    'bandwidth_quota' => bandwidth_quota
	  }
	  options.delete_if {|key, value| value.nil?}

	  data = connection.create_server(domain, options)
	  merge_attributes(data.body['server'])
	  true
	end

#        def save
#	  requires :template, :config_id
#	  options = {
#	    :name	=> domain
#	    :zone	=> zone
#
#	  }
#	  options = options.reject {|key, value| value.nil?}
#	  data = connection.create_server(template, config_id, options)
#	  merge_attributes(data.body['server'])
#	  true
#	end

        def username
          @username ||= 'root'
        end

        def clone(options)
          requires :identity
          connection.clone_server({:uniq_id => identity}.merge!(options))
          true
        end
        def resize(options)
          requires :identity
          connection.resize_server({:uniq_id => identity}.merge!(options))
          true
        end
      end

    end
  end
end
