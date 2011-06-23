Puppet::Type.type(:exportnfs).provide(:linux) do

  def self.instances
    @instances ||= get_exports

    @instances
  end

  def prefetch
    Puppet.debug "Prefetching exportnfs resources"

    #instances.each do |export|
      #p export
    #end
  end

  def exists?
    return true
    @resource.provider.instances.each do |export|
      @resource[:export].to_a.each do |exp|
        unless @property_hash[:exports].has_key? exp
          return false
        end
      end
    end
  end

  def parameters
    @property_hash[:parameters]
  end

  def host
    @property_hash[:hosts]
  end

=begin
  def create
    @resource[:export].to_a.each do |exp|
      add_export exp
    end
  end

  def destroy
    @resource[:export].to_a.each do |exp|
      @resource[:export].delete exp
    end
  end

  def add_export( name )
    @property_hash[:exports][name] = { :hosts => Hash.new }
  end

  def add_host( params )
    #Make sure our exports exists
    @params[:exports].to_a.each do |exp|
      unless @property_hash[:exports].has_key? exp
        add_export exp
      end
    end

    #Add our host to the hash
    @params[:exports].to_a.each do |exp|
      unless @property_hash[:exports][exp][:hosts].has_key? params[:name]
        @property_hash[:exports][exp][:hosts][ params[:name] ] = Hash.new
      end

      #Add its parameters
      @property_hash[:exports][exp][:hosts][ params[:name] ] = {
        :name    => params[:name],
        :subnet  => params[:subnet],
        :params  => params[:parameters],
      }
    end
  end
=end

  def self.get_exports
    exports   = Hash.new
    instances = Array.new

    File.open( '/etc/exports','r' ).readlines.reject do |line|
      line =~ /^\s*#/
    end.map do |export|
        exports[export] = Hash.new

        export_line  = export.strip.split
        export_name  = export_line[0]
        export_hosts = export_line[1..-1]

        unless exports.has_key? export_name
          exports[export_name] = Hash.new
        end

        export_hosts.each do |host|
          parsed_host = parse_host(host)

          #We need to group the hosts in an export based on whether their parameter list matches.
          ## Then we create a separate exportnfs resource instance with a single :parameters value
          ## This worked because the parameters are always sorted
          params_id = parsed_host[:parameters].join

          if params_id.empty?
            params_id = 'empty'
          end

          unless exports[export_name].has_key? params_id
            exports[export_name][params_id] = Hash.new
            exports[export_name][params_id][:params] = parsed_host[:parameters]
          end

          unless exports[export_name].has_key? parsed_host[:name]
            exports[export_name][params_id][ parsed_host[:name] ] = Hash.new
          end

          exports[export_name][params_id][ parsed_host[:name] ][:parameters] = parsed_host[:parameters]
          exports[export_name][params_id][ parsed_host[:name] ][:subnet]     = parsed_host[:subnet]
        end

        exports.each do |e_name,export|
          export.each do |p_name, param_ids|
            instances << new(
              :name       => "#{e_name}-#{p_name}",
              :hosts      => param_ids.keys.reject{ |k| k == :params },
              #:parameters => param_ids[:params],
              :parameters => param_ids,
              :provider   => :linux,
              :ensure     => :present
            )
          end
        end

    end

    instances
  end

  def flush
    Puppet.debug 'Flushing /etc/exports'

    File.open( '/etc/exports', 'w' ) {
      buildexports
    }
  end

  def self.parse_host(host)
    if host.include? '('
      (host_details,parameters) = host.split('(')
      parameters = parameters.chop.split(',').sort #Splits off the ) character
    else
      host_details = host
      parameters = Array.new
    end

    #Determine if we have a subnet and split it out
    if host_details.include? '/'
      (host_name,host_subnet) = host_details.split('/')
    else
      host_subnet = ''
      host_name = host_details
    end

    { :name => host_name, :parameters => parameters, :subnet => host_subnet }
  end
end
