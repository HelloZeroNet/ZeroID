timers = {}

jQuery.fn.readdClass = (class_name) ->
	elem = @
	elem.removeClass class_name
	setTimeout ( ->
		elem.addClass class_name
	), 1
	return @

jQuery.fn.removeLater = (time = 500) ->
	elem = @
	setTimeout ( ->
		elem.remove()
	), time
	return @

jQuery.fn.hideLater = (time = 500) ->
	@.cssLater("display", "none", time)
	return @

jQuery.fn.addClassLater = (class_name, time = 5) ->
	elem = @
	if timers[class_name] then clearInterval(timers[class_name])
	timers[class_name] = setTimeout ( ->
		elem.addClass(class_name)
	), time
	return @

jQuery.fn.removeClassLater = (class_name, time = 500) ->
	elem = @
	if timers[class_name] then clearInterval(timers[class_name])
	timers[class_name] = setTimeout ( ->
		elem.removeClass(class_name)
	), time
	return @

jQuery.fn.cssLater = (name, val, time = 500) ->
	elem = @
	if timers[name] then clearInterval(timers[name])
	timers[name] = setTimeout ( ->
		elem.css name, val
	), time
	return @


jQuery.fn.toggleClassLater = (name, val, time = 10) ->
	elem = @
	if timers[name] then clearInterval(timers[name])
	timers[name] = setTimeout ( ->
		elem.toggleClass name, val
	), time
	return @