require_relative '../lib/rbvppc/hmc'
require_relative '../lib/rbvppc/nim'
require_relative '../lib/rbvppc/lpar'
require_relative '../lib/rbvppc/vio'


#Modify these for your tests
hmc_fqdn    = "dwinhmc.dub.usoh.ibm.com"
nim_fqdn    = "dwinnim.dub.usoh.ibm.com"
frame_name  = "rslppc09"
lpar_name   = "rslpl003"
vio1_name   = "rslppc09a"
vio2_name   = "rslppc09b"
vlan_id     = "74"
des_prod    = "1.0"
des_mem     = "4096"
des_vcpu    = "1"
nim_ip      = "9.55.50.248"
rslpl003_ip = "9.55.51.131"
fb_script   = "Darwin_TPM72_Key_fb_Script"
mksysb      = "ic2-aix-7100-02-04-1341-20140807"

hmc_pass    = ""
nim_pass    = ""



#Create objects        
hmc = Hmc.new(hmc_fqdn,"hscroot", {:password => hmc_pass})
nim = Nim.new(nim_fqdn,"root", {:password => nim_pass})
vio1 = Vio.new(hmc,frame_name,vio1_name)
vio2 = Vio.new(hmc,frame_name,vio2_name)
lpar = Lpar.new({:hmc => hmc, :des_proc => des_prod, :des_mem => des_mem , :des_vcpu => des_vcpu, :frame => frame_name, :name => lpar_name})

#Open connections
hmc.connect
nim.connect

#Create LPAR
lpar.create

#Add vSCSI Adapters
lpar.add_vscsi(vio1)
lpar.add_vscsi(vio2)

#Create vNIC
lpar.create_vnic(vlan_id)

#Get vSCSI Information
lpar_vscsi = lpar.get_vscsi_adapters

#Find the vHosts
first_vhost = lpar.find_vhost_given_virtual_slot(lpar_vscsi[0].remote_slot_num)
second_vhost = lpar.find_vhost_given_virtual_slot(lpar_vscsi[1].remote_slot_num)

#Attach a Disk
vio1.map_any_disk(first_vhost, vio2, second_vhost)

#Power Cycle the LPAR to assign MAC to vNIC
lpar.activate
lpar.soft_shutdown

#Define needed NIM objects
nim.define_client(lpar)
nim.create_bid(lpar)

#Deploy Mksysb, booting LPAR
nim.deploy_image(lpar,mksysb,fb_script) do |gw,snm| 
   hmc.lpar_net_boot(nim_ip, rslpl003_ip,gw,snm,lpar.name,lpar.current_profile,lpar.frame)
end

#Close connections
nim.disconnect
hmc.disconnect