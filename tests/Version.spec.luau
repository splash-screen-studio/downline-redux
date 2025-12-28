--!strict
local process = require("@lune/process")

-- Simple test runner
local passed = 0
local failed = 0

local function test(name: string, fn: () -> ())
	local success, err = pcall(fn)
	if success then
		passed += 1
		print("✓ " .. name)
	else
		failed += 1
		print("✗ " .. name)
		print("  " .. tostring(err))
	end
end

local function expect(value: any)
	return {
		toBe = function(expected: any)
			assert(value == expected, `Expected {expected}, got {value}`)
		end,
		toBeTruthy = function()
			assert(value, `Expected truthy value, got {value}`)
		end,
		toBeType = function(expectedType: string)
			assert(typeof(value) == expectedType, `Expected type {expectedType}, got {typeof(value)}`)
		end,
	}
end

-- Load Version module
local Version = require("../src/shared/Version")

print("\n=== Version Tests ===\n")

test("Version module exists", function()
	expect(Version).toBeTruthy()
end)

test("Version.client is a string", function()
	expect(Version.client).toBeType("string")
end)

test("Version.server is a string", function()
	expect(Version.server).toBeType("string")
end)

test("Version.shared is a string", function()
	expect(Version.shared).toBeType("string")
end)

test("Version.log is a function", function()
	expect(Version.log).toBeType("function")
end)

test("Version.logAll is a function", function()
	expect(Version.logAll).toBeType("function")
end)

print("\n=== Results ===")
print(`Passed: {passed}`)
print(`Failed: {failed}`)

if failed > 0 then
	process.exit(1)
end
