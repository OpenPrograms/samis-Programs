local core = require("nidus/core")
print(core)
print("NiDuS Frontend 1.0 loading...")
local component = require("component")
local event = require("event")
local fs = require("filesystem")
local modem = component.modem
assert(modem, "No modem found")

if modem.isWireless() then
  modem.setStrength(400)
end

print("Loading the NiDuS core...")

local server = core.  NiDuS.new('/etc/nidus/nidus.conf')

print("NiDuS core has been loaded!")

modem.open(53)

function handleConnection(localaddr, remoteaddr, port, data)
    if port ~= 53 then
	    print("Recieved message from non-DNS port. Ignoring.")
		return
	end
	print("Got a request.")
	print("localaddr:" .. localaddr .. "remoteaddr:" .. remoteaddr .. "Port:" .. port .. "Data:" .. data)
	local output = server:handle(remoteaddr, data)
	print("Output to send:" .. output)
	modem.send(output)
end

while true do
    local _, localaddr, remoteaddr, port, data
    _, localaddr, remoteaddr, port, _, data = event.pull( "modem_message" )
    handleConnection( localaddr, remoteaddr, port, data)
end