# See Intro to Rake by Shneems: https://www.youtube.com/watch?v=gR0YfJrg9pg
# Dependency task :environment which is a Rails rake task loading models, etc.

# Initializes table vlans (IPAMS-specific)
# TODO: Seems this should be enabled on the web UI.
namespace :init do

  # Assigns the initial IP Addresses to NOBODY who belongs to department NONEXISTENT
  desc "Initializes table vlans (IPAMS-specific)"
  task vlans: :environment do
    # Intializes VLAN by VLAN by populating with the IP addresses
    vlans = Vlan.all # ActiveRecord::Relation
    #vlans = Vlan.find_by(vlan_name: 'home-test')
    #[vlans].each do |vlan|
    vlans.each do |vlan|
      #puts vlan.vlan_name   
      init_a_single_vlan(vlan)      
    end

    puts "*** Table vlans initialized: #{vlans.count} VLANs."
  end
  
  # Initializes a specified VLAN. Usage: rake init:vlan_selected[VLAN_name] (e.g., init:vlan_selected[vlan_1])
  # See https://stackoverflow.com/questions/1357639/rails-rake-how-to-pass-in-arguments-to-a-task-with-environment
  # Notes:
  #  You may omit the #with_defaults call, obviously.
  #  You have to use an Array for your arguments, even if there is only one.
  #  The prerequisites do not need to be an Array.
  #  args is an instance of Rake::TaskArguments.
  #  t is an instance of Rake::Task.
  desc "Initializes a specified VLAN"
  task :vlan_selected, [:vlan_name] => :environment do |t, args|
    puts "*** selected VLAN to be initialized: #{args.vlan_name}"    
    
    vlan = Vlan.find_by(vlan_name: args.vlan_name)
    if vlan
      init_a_single_vlan(vlan)
    else
      puts "ERROR: #{args.vlanname} not found!"
    end
    
    puts "--- Done! ---"
  end # task
  
  private
  
    # Finds department NONEXISTENT & returns it
    def find_nonexistent_department
      # Creates department named NONEXISTENT
      # TODO: This department should be read-only once created
      dept1 = Department.create(dept_name: "NONEXISTENT", location: "NOWHRER")
      dept1 = Department.find_by(dept_name: "NONEXISTENT") unless dept1.valid?
      dept1
    end

    # Finds user NOBODY & returns it
    def find_user_nobody    
      # Makes sure that department NONEXISTENT
	  dept1 = find_nonexistent_department
    
      # Creates user NOBODY who belongs to department NONEXISTENT
      # TODO: This user should be read-only once created
      user1 = User.create(department_id: dept1.id, name: "NOBODY")
      # Or create this way
      #user1 = dept1.users.create(department_id: dept1.id, name: "NOBODY")
      user1 = User.find_by(name: "NOBODY") unless user1.valid?
      user1
    end

    # Retrieves the IP address range & converts them to integers
    # Note: validates the addresses in the model  
    def init_a_single_vlan(vlan)
      user1 = find_user_nobody
    
      ip1 = vlan.static_ip_start.split('.') # string split to string arrays
      ip2 = vlan.static_ip_end.split('.')
      (ip1[0].to_i..ip2[0].to_i).each do |i0|
        s0 = i0.to_s + '.'
        (ip1 [1].to_i..ip2[1].to_i).each do |i1|
          s1 = s0 + i1.to_s + '.'
          (ip1 [2].to_i..ip2[2].to_i).each do |i2|
            s2 = s1 + i2.to_s + '.'
            (ip1 [3].to_i..ip2[3].to_i).each do |i3|
              addr = s2 + i3.to_s 
              vlan.addresses.create(user_id: user1.id, ip: addr)
            end
          end
        end
      end
    end # def init_a_single_vlan
    
end
