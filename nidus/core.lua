local class = require('oop-system').class
local NiDuS = class('NiDuS')
local serializer = require("serialization")

function NiDuS:init(file)
    self.cfgfile = file
	self.version = 1.0
	self.protocol_string = "DNS 1 A"
	self.hosts = {}
	self.currentfeatures = {}
    self:reloadConfig()
	self:readHosts()
	self:loadData()
end

function NiDuS:reloadConfig()
    print("Configuration of NiDuS is not currently implemented.")
end

function NiDuS:sendError(code, description)
    local error = "ERROR" .. code .. description
    print("Sent:" .. error)
    return error
end

function NiDuS:sendRecordError(rnumber, code, description)
    local error = "ERROR" .. number .. code .. description
	print("Sent:" .. error)
	return error
end

function NiDuS:getRecord(domain, recordtype)
    return self.hosts[domain][recordtype]
end

function NiDuS:negoiateFeatures(protocolstring)
    print("Feature neogiation is not currently implemented.")
	return protocol_string
end

function NiDuS:readHosts()
    print("Reading from the hosts file is not currently implemented.")
end

local function contains(text, str)
    return not string.find(text, str)
end

local function mysplit(inputstr, sep)
        sep = sep or "%s"
        local t={} ; local i=1 ;
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function NiDuS:handle(from, message)
    if contains(message, "DNS") then
	    return self:negoiateFeatures(message)
	end
	if contains(message, "QUERY") then
	    return self:handleQuery(message)
	end
	if contains(message, "REGISTER") then
	    return self:handleRegistration(from, message)
	end
	if contains(message, "UNREGISTER") then
	    return self:handleUnregistration(from, message)
	end
	return self:sendError(400, "")
end

function NiDuS:handleQuery(message)
    local queryparts = mysplit(message, " ")
	if queryparts[1] ~= "QUERY" then
	    return self:sendError(400, "Word QUERY found but request is not a query")
	end
	local record = queryparts[2]
	if record ~= "A" then
	    return self:sendError(501, "Server does not support this record type")
	end
	local domain = queryparts[3]
	return self:resolve(record, domain)
end

function NiDuS:resolve(record, domain)
    local error_string = "NXDOMAIN" .. domain
	if not self:getRecord(domain, record) then
	    return error_string
	else
	    result = self:getRecord(domain, record)
		return "RESPONSE" .. domain .. record .. result
	end
end

function NiDuS:handleRegistration(from, message)
    local parts = mysplit(message, " ")
	if parts[1] ~= "REGISTER" then
	    return self:sendError(400, "Word REGISTER found but is not a registration request")
	end
	local domain = parts[2]
	local record = parts[3]
	if record ~= "A" then
	    return self:sendError(501, "Server does not support this record type")
	end
	self.hosts[domain][record] = parts[4] or from
	self:saveData()
	return self:resolve(record, domain)
end

function NiDuS:handleUnregistration(from, message)
    local parts = mysplit(message, " ")
	if parts[1] ~= "UNREGISTER" then
	    return self:sendError(400, "Word UNREGISTER found but is not a unregistration request")
	end
	local domain = parts[2]
	local assignedhost = self:getRecord(domain, "A")
	if not assignedhost == from then
	    return self:sendError(400, "Only the address that registered a domain is allowed to unregister it.")
	end
	hosts[domain] = nil
	self:saveData()
	return self:sendError(200, "The domain has been unregistered.")
end

function NiDuS:saveData()
    local hostsdb = io.open("/var/lib/nidus/hosts.db", wb)
	local serialized_hosts = serializer.serialize(hosts)
	hostsdb:write(serialized_hosts)
	hostsdb:close()
end

function NiDuS:loadData()
    local hostsdb, error = io.open("/var/lib/nidus/hosts.db", "rb")
	if not hostsdb then
	    print("Unable to initially open hosts database. Reason:" .. error)
        print("Attempting to create file...")
        hostsdb = io.open("/var/lib/nidus/hosts.db", "w")
        if not hostsdb then
            hostsdb:close() 
		    print("Unable to open hosts database. Exiting now")
            os.exit()
        end
    end
	local serialized_hosts = hostsdb:read("*a")
	self.hosts = serializer.unserialize(serialized_hosts)
end
return {NiDuS = NiDuS}