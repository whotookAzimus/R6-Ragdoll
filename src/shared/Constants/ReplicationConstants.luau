local ReplicationConstants = {
	InterpolationDelay = 0.1,
	CircularBufferLength = 10,
	SendRate = 20,
	SmoothingFactor = 1, -- (0 = full smoothing, 1 = no smoothing)
	InterpolationSmoothingConstant = 100,
}

table.freeze(ReplicationConstants)
return ReplicationConstants
