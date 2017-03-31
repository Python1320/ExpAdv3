local compFunc = EXPR_WIKI.COMPILER.Function
local compOper = EXPR_WIKI.COMPILER.Operator

local prefabFunc = EXPR_WIKI.COMPILER.PrefabFunction
local prefabOper = EXPR_WIKI.COMPILER.PrefabOperator

local states = {
	[0] = "server",
	[1] = "shared",
	[2] = "client"
}

local operators = {
	["eq"] = "==",
	["neq"] = "!=",
	["lth"] = "<",
	["leg"] = "<=",
	["gth"] = ">",
	["geq"] = ">=",
	["add"] = "+",
	["sub"] = "-",
	["mul"] = "*",
	["div"] = "/",
	["is"] = "",
	["not"] = "!",
	["neg"] = "-",
	["len"] = "#",
	["bxor"] = "^^",
	["and"] = "&&",
	["or"] = "||",
	["exp"] = "^",
	["mod"] = "%",
	["bor"] = "|",
	["band"] = "&",
	["neq*"] = "!=",
	["eq*"] = "==",
	["bshl"] = "<<",
	["bshr"] = ">>",
}

local function remLine(s)
	if istable(s) then
		local t = {}
		
		for k, v in pairs(s) do
			t[k] = string.Replace(v, "_", "")
		end
		
		return t
	else
		return string.Replace(s, "_", "")
	end
end

hook.Add("Expression3.LoadWiki", "Expression3.Wiki.RegisterFunction.autogen", function()
	--print("Autogenerated "..table.Count(EXPR_LIB.GetEnabledExtensions()).." extention wiki pages!")
	
	for lib, data in pairs(EXPR_LIB.GetEnabledExtensions()) do
		if data.enabled then
			for func, data2 in pairs(data.constructors) do
				local class = data2.extension
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				EXPR_WIKI.RegisterConstructor(lib, remLine(func), compFunc(prefabFunc(states[data2.state], class, args, rtns)), states[data2.state])
			end
			
			for func, data2 in pairs(data.methods) do
				local class = data2.extension
				local name = data2.name
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				EXPR_WIKI.RegisterMethod(lib, remLine(func), compFunc(prefabFunc(states[data2.state], class.."."..name, remLine(args), rtns)), states[data2.state])
			end
			
			for func, data2 in pairs(data.operators) do
				local name = data2.name or " "
				local args = data2.parameter
				local rtns = string.rep(data2.result, data2.rCount or 0, ",")
				
				if string.find("+-*/!=<>", string.sub(name, 1, 1)) then
					EXPR_WIKI.RegisterOperator(lib, remLine(func), compOper(prefabOper(states[data2.state], name, args, rtns)), states[data2.state])
				else
					if operators[name] then
						local func_ = ""
						local args_ = string.Explode(",", args)
						
						if #args_ == 2 then
							func_ = args_[1] .. " " .. operators[name] .. " " .. args_[2]
						elseif #args_ == 1 then
							func_ = operators[name] .. args_[1]
						end
						
						EXPR_WIKI.RegisterOperator(lib, remLine(func_), compOper(prefabOper(states[data2.state], operators[name], args, rtns), w, h), states[data2.state])
					elseif name == "ten" then
						local args_ = string.Explode(",", args)
						local func_ = args_[1] .. "?" .. args_[2] .. ":" .. args_[3]
						
						EXPR_WIKI.RegisterOperator(lib, remLine(func), compOper(prefabOper(states[data2.state], name, args, rtns), w, h), states[data2.state])
					else
						EXPR_WIKI.RegisterOperator(lib, remLine(func), compFunc(prefabFunc(states[data2.state], name, args, rtns)), states[data2.state])
					end
				end
			end
		end
	end
	
	for lib, data in pairs(EXPR_LIBRARIES) do
		for func, data2 in pairs(data._functions) do
			local name = data.name .. "." .. data2.name
			local args = data2.parameter
			local rtns = string.rep(data2.result, data2.rCount or 0, ",")
			
			EXPR_WIKI.RegisterFunction(lib, remLine(func), compFunc(prefabFunc(states[data2.state], name, remLine(args), rtns)), states[data2.state])
		end
	end
	
	for func, data2 in pairs(EXPR_LIB.WikiEvents) do
		local name = func
		local args = data2.parameter or "_nil"
		local rtns = data2.result or "_nil"
		
		EXPR_WIKI.RegisterEvent(func, compFunc(prefabFunc(states[data2.state], name, args, rtns)), states[data2.state])
	end
end)

--PrintTable(EXPR_WIKI)