limits = {}
window.LimitRate = (interval, fn) ->
	if not limits[fn]
		limits[fn] = setTimeout (->
			fn()
			delete limits[fn]
		), interval
