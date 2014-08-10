id :'nidus'
name 'NiDuS DNS Server'
description 'A DNS server that is light and easy to use. Uses its own protocol.'

install 'nidus.lua' => '/usr/bin'
install 'core.lua' => '/usr/lib/nidus'
install 'hosts.db' => '/var/lib/nidus'
