case node[:platform]
when 'debian','ubuntu'
  package 'xfsprogs'
  package 'xfsdump'
  package 'xfslibs-dev'
when 'amazon','fedora'
  # xfsdump is not an Amazon Linux package at this moment.
  package 'xfsprogs'
  package 'xfsprogs-devel'
when 'redhat','centos'
  # RedHat 6 does not provide xfsprogs
end

# VirtIO device name mapping
if BlockDevice.on_kvm?
  cookbook_file '/usr/local/bin/virtio-to-scsi' do
    source 'virtio-to-scsi'
    owner 'root'
    mode 0755
  end

  cookbook_file '/etc/udev/rules.d/65-virtio-to-scsi.rules' do
    source '65-virtio-to-scsi.rules'
    owner 'root'
    mode 0644
  end

  execute 'Reload udev rules' do
    command 'udevadm control --reload-rules'
  end

  execute 'Let udev reprocess devices' do
    command 'udevadm trigger'
  end
end

include_recipe 'ebs::volumes'
unless node[:ebs][:raids].empty?
  include_recipe 'ebs::raids'
end
