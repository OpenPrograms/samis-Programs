id  'nidus'
name 'NiDuS DNS Server'
description 'A DNS server that is light and easy to use. Uses its own protocol.'

install 'nidus.lua' => '/bin'
install 'core.lua' => '/lib/nidus'
install 'hosts.db' => '//var/lib/nidus'

depend 'oop-system' => '/'

authors 'samis'
