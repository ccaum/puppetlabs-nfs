Puppet::Type.newtype(:exportnfs) do
  @doc = "The exportnfs type"

  ensurable

  #We can have two namevars that are equal
  @isomorphic = false

  newparam(:name) do
    desc "The name of the export"
  end

  newproperty(:host, :array_matching => :all) do
    desc "The host(s) to permit access to the export"

    defaultto ''

    munge do |value|
      value.to_a.sort
    end
  end

  newproperty(:parameters) do
    desc "The parameters to use with the given host(s)"

    defaultto []

    munge do |value|
      value.to_a.sort
    end
  end

=begin
  newproperty(:subnet) do
    desc "The subnet to assign to given network."

    defaultto :undef

    validate do |value|
      unless value =~ /[0-9]+/ or value == :undef
        raise ArgumentError, "#{value} is not in the correct subnet format"
      end
    end
  end

  newproperty(:network) do
    desc "The network(s) to permit access to the export"

    #self[:host] = @resource[:network]

    validate do |value|
      unless value =~ /[0-9]+.[0-9]+.[0-9]+.[0-9]+/
        raise ArgumentError, "#{value} is not in the correct network format"
      end
    end
  end

  #newparam(:export, :namevar => true) do
  #  desc "The directory path to export"
  #
  #  validate do |value|
  #    unless value =~ /^\//
  #      raise ArgumentError, "#{value} is not an absolute path"
  #    end
  #  end
  #end
=end
end
