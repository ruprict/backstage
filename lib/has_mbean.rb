module Backstage
  module HasMBean
    java_import javax.management.ObjectName

    def self.included(base)
      base.send( :attr_accessor, :mbean_name, :mbean )
      base.extend( ClassMethods )
    end

    def initialize(mbean_name, mbean)
      self.mbean_name = mbean_name
      self.mbean = mbean
    end
    
    def full_name
      mbean_name.to_s
    end

    def method_missing(method, *args, &block)
      mbean.send( method, *args, &block )
    rescue NoMethodError => ex
      super
    end
    
    module ClassMethods
      def jmx_server
        @jmx_server ||= JMX::MBeanServer.new
      end

      def all(filter_string = filter)
        jmx_server.query_names( filter_string ).collect { |name| new( name, jmx_server[name] ) }
      end

      def find(name)
        name = ObjectName.new( name ) unless name.is_a?( ObjectName )
        new( name, jmx_server[name] )
      rescue JMX::NoSuchBeanError => ex
        nil
      end

    end
  end
end
