local Version = {
	client = "1.0.0",
	server = "1.0.0",
	shared = "1.0.0",
	ReplicatedFirst = "1.0.0",
}

function Version.log(subsystem: string)
	local version = Version[subsystem]
	if version then
		print(string.format("[%s] v%s", subsystem, version))
	end
end

function Version.logAll()
	print("=== Subsystem Versions ===")
	Version.log("ReplicatedFirst")
	Version.log("client")
	Version.log("server")
	Version.log("shared")
	print("==========================")
end

return Version
