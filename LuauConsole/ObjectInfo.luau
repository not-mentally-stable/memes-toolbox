--!strict
const ReflectionService = game:GetService("ReflectionService")

export type PropertyDetails = {
	Name: string,
	Type: string,
	Value: any,
	IsDeprecated: boolean,
	DeprecationMessage: string?
}

export type MethodDetails = {
	Name: string,
	Signature: string,
	CanYield: boolean,
	IsDeprecated: boolean,
	DeprecationMessage: string?
}

export type SignalDetails = {
	Name: string,
	Signature: string,
	IsDeprecated: boolean,
	DeprecationMessage: string?
}

export type ObjectReport = {
	Info: {
		ClassName: string,
		Superclass: string,
		Name: string
	},
	Properties: { [string]: PropertyDetails },
	Methods: { [string]: MethodDetails },
	Signals: { [string]: SignalDetails }
}

const ObjectInfo = {}

const getTypeString = function(typeData: any): string
	if not typeData then
		return "any"
	end
	return typeData.InstanceType or typeData.EngineType or typeData.ScriptType or "any"
end

ObjectInfo.getReport = function(object: Instance): ObjectReport?
	const className = object.ClassName
	const successClass, classData = pcall(function()
		return ReflectionService:GetClass(className)
	end)
	const superclass = if successClass and classData then classData.Superclass or "Instance" else "Instance"
	const report: ObjectReport = {
		Info = {
			ClassName = className,
			Superclass = superclass,
			Name = object.Name
		},
		Properties = {},
		Methods = {},
		Signals = {}
	}
	const successProps, props = pcall(function()
		return ReflectionService:GetPropertiesOfClass(className)
	end)
	if successProps and props then
		for _, prop in props do
			const propName = prop.Name
			const successVal, val = pcall(function()
				return (object :: any)[propName]
			end)
			const isDeprecated = if prop.Display and prop.Display.DeprecationMessage then true else false
			const depMessage = if prop.Display then prop.Display.DeprecationMessage else nil
			report.Properties[propName] = {
				Name = propName,
				Type = getTypeString(prop.Type),
				Value = if successVal then val else "UnReadable",
				IsDeprecated = isDeprecated,
				DeprecationMessage = depMessage
			}
		end
	end
	const successMethods, methods = pcall(function()
		return ReflectionService:GetMethodsOfClass(className)
	end)
	if successMethods and methods then
		for _, method in methods do
			const methodName = method.Name
			const paramsList = {}
			if method.Parameters then
				for _, param in method.Parameters do
					table.insert(paramsList, param.Name .. ": " .. getTypeString(param.Type))
				end
			end
			const paramsStr = "(" .. table.concat(paramsList, ", ") .. ")"
			const returnStr = getTypeString(method.ReturnType)
			const signature = `:{methodName}{paramsStr}: {returnStr}`
			const isDeprecated = if method.Display and method.Display.DeprecationMessage then true else false
			const depMessage = if method.Display then method.Display.DeprecationMessage else nil
			report.Methods[methodName] = {
				Name = methodName,
				Signature = signature,
				CanYield = method.CanYield or false,
				IsDeprecated = isDeprecated,
				DeprecationMessage = depMessage
			}
		end
	end
	const successEvents, events = pcall(function()
		return ReflectionService:GetEventsOfClass(className)
	end)
	if successEvents and events then
		for _, event in events do
			const eventName = event.Name
			const paramsList = {}
			if event.Parameters then
				for _, param in event.Parameters do
					table.insert(paramsList, param.Name .. ": " .. getTypeString(param.Type))
				end
			end
			const paramsStr = "(" .. table.concat(paramsList, ", ") .. ")"
			const signature = `.{eventName}{paramsStr}`
			const isDeprecated = if event.Display and event.Display.DeprecationMessage then true else false
			const depMessage = if event.Display then event.Display.DeprecationMessage else nil
			report.Signals[eventName] = {
				Name = eventName,
				Signature = signature,
				IsDeprecated = isDeprecated,
				DeprecationMessage = depMessage
			}
		end
	end
	return report
end

return table.freeze(ObjectInfo)
