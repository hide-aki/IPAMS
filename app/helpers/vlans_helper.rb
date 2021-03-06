# All models are accessible to both helpers & views
# How to doc Ruby code:
# http://stackoverflow.com/questions/1681467/how-to-document-ruby-code
module VlansHelper
  # Creates a cache key for the vlans/index view with pagination
  # params:
  # +caller_name+:: the name of the calling template or partial
  # +offset+:: the offset of the pagination 
  def cache_key_for_vlans(caller_name, offset)
    max_updated_at = Vlan.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "vlans/#{caller_name}-#{offset}-#{max_updated_at}"
  end

  # Creates a cache key for a single VLAN.
  # params:
  # +caller_name+:: the name of the calling template or partial
  # +vlan+:: the VLAN object, a record 
  def cache_key_for_vlan(caller_name, vlan)
    updated_at = vlan.updated_at.try(:utc).try(:to_s, :number)
    "vlans/#{caller_name}-#{vlan.id}-#{updated_at}"
  end
end
