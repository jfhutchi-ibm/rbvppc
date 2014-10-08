require_relative '../lib/rbvppc/hmc'
require_relative '../lib/rbvppc/lpar'
require_relative '../lib/rbvppc/vio'

frame_name = "frame"
lpar_name  = "lpar"
vio1_name  = "vio1"
vio2_name  = "vio2"

#Create HMC Object
hmc = Hmc.new("FQDN", "hscroot", {:password => "password goes here"})
#Connect to HMC
hmc.connect
#Populate options hash with lpar information
lpar_hash = hmc.get_lpar_options(frame_name,lpar_name)
#Create LPAR Object based on the hash
lpar = Lpar.new(lpar_hash)
#Create a VIO object for both vios
vio1 = Vio.new(hmc,frame_name,vio1_name)
vio2 = Vio.new(hmc,frame_name,vio2_name)
#Unmapp all the disks from the lpar using VIO1 passing the method the 2nd vio and the lpar
vio1.unmap_all_disks(vio2,lpar)
#Delete the LPAR
lpar.delete
#Disconnect from the hmc
hmc.disconnect
