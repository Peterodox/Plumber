local _, addon = ...

local EasingFunctions = {};
addon.EasingFunctions = EasingFunctions;


local sin = math.sin;
local cos = math.cos;
local pow = math.pow;
local pi = math.pi;


--t: total time elapsed
--b: beginning position
--e: ending position
--d: animation duration

function EasingFunctions.linear(t, b, e, d)
	return (e - b) * t / d + b;
end

function EasingFunctions.outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b;
end

function EasingFunctions.inOutSine(t, b, e, d)
	return -(e - b) / 2 * (cos(pi * t / d) - 1) + b;
end

function EasingFunctions.outQuart(t, b, e, d)
	t = t / d - 1;
	return (b - e) * (pow(t, 4) - 1) + b;
end

function EasingFunctions.outQuint(t, b, e, d)
	t = t / d;
	return (b - e)* (pow(1 - t, 5) - 1) + b;
end

function EasingFunctions.inQuad(t, b, e, d)
	t = t / d;
	t = t * t;
	return (e - b) * t + b;
end

function EasingFunctions.outQuad(t, b, e, d)
	t = t / d;
	t = 1 - (1 - t) ^ 2;
	return (e - b) * t + b;
end
