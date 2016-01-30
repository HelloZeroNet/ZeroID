class Particles
	constructor: ->
		@renderer = PIXI.autoDetectRenderer(1024, 768, {backgroundColor: 0x3F51B5, antialias: true, failIfMajorPerformanceCaveat: true})
		@renderer.view.className = "particles"
		@renderer.autoResize = true
		@renderer.view.style["transform"] = "translatez(0)"
		PIXI.ticker.shared.stop() # We dont need this
		@renderer.plugins.interaction.destroy() # We dont need this


		document.body.appendChild(@renderer.view)

		@sprites = new PIXI.ParticleContainer(500, {
    		scale: true,
    		position: true,
    		rotation: false,
    		uvs: false,
    		alpha: false
    	})
		@container = new PIXI.Container()
		@stage = new PIXI.Container()
		@bg = null

		@running = true
		@disabled = false
		@speed = 1
		@fps_timer = null
		@fps = 0


		###
		@bg = new PIXI.Graphics()
		@bg.beginFill(0x150A45, 1)
		@bg.lineStyle(1, 0x150A45, 0.5)
		@bg.drawCircle(10,10,20,20)
		@bg.endFill()
		@bg.cacheAsBitmap = true
		@bg.scale.x = 10
		@bg.scale.y = 10
		###

		@container.addChild(@sprites)
		@stage.addChild(@container)


	createBlur: ->
		@blured = new PIXI.Container()
		@render_texture = new PIXI.RenderTexture(@renderer, @width, @height)
		@output_sprite = new PIXI.Sprite(@render_texture)

		# bg blur mask
		canvas = document.createElement('canvas')
		canvas.width = 700
		canvas.height = 400
		ctx = canvas.getContext('2d')
		ctx.lineJoin = "round"
		ctx.lineWidth = 60
		ctx.shadowBlur = 40
		ctx.shadowColor = ctx.fillStyle = ctx.strokeStyle = "#FFF"
		for i in [0..5]
			ctx.beginPath();
			ctx.moveTo(100, 100);
			ctx.lineTo(100, 350);
			ctx.lineTo(600, 350);
			ctx.lineTo(600, 100);
			ctx.closePath();
			ctx.stroke();
			ctx.fill();

		# Create masked elem
		@bg = new PIXI.Graphics()
		@bg.beginFill(0x3F51B5, 1)
		@bg.drawRect(0,0,700,400)
		@bg.endFill()

		# Add mask to elem
		mask = new PIXI.Sprite(PIXI.Texture.fromCanvas(canvas))
		@bg.scale.y = 1
		@bg.scale.x = 1
		@bg.mask = mask
		@bg.addChild(mask)
		@bg.position.x = @width/2-(@bg.width/2)
		@bg.position.y = @height/2-(@bg.height/2)-10

		# Add to blured container
		@blured.addChild(@bg)
		@blured.addChild(@output_sprite)

		# Apply blur effect
		blur_x = new PIXI.filters.BlurFilter()
		blur_y = new PIXI.filters.BlurYFilter()
		blur_x.blur = blur_y.blur = 3
		blur_x.passes = blur_y.passes = 2

		@output_sprite.filters = [blur_x, blur_y]

		@stage.addChild(@blured)


	addPeers: ->
		@peers = []
		c = new PIXI.Circle(0, 0, 3);
		g = new PIXI.Graphics()
		g.beginFill(0xFFFFFF, 1)
		g.drawShape(c)
		g.endFill()
		texture = g.generateTexture()
		for i in [1..100]
			peer = new PIXI.Sprite(texture)
			peer.position.x = Math.random()*@width
			peer.position.y = Math.random()*@height
			peer.speed = {x: 0.5-Math.random(), y: 0.5-Math.random(), scale: (Math.random())/50}
			peer.anchor.set(0.5)
			#peer.cacheAsBitmap = true
			@sprites.addChild(peer)
			@peers.push(peer)

		@lines = new PIXI.Graphics()
		@container.addChild(@lines)



	update: =>
		@fps += 1
		lines = @lines
		lines.clear()
		for peer in @peers
			# Add speed
			peer.position.x += peer.speed.x*@speed
			peer.position.y += peer.speed.y*@speed
			peer_x = peer.position.x
			peer_y = peer.position.y

			# Change scale
			if Math.random() > 0.9
				peer.scale.x += peer.speed.scale
				peer.scale.y = peer.scale.x
				if peer.scale.x > 1 or peer.scale.x < 0.3
					peer.speed.scale = 0-peer.speed.scale

			# Check if out of bounds
			if peer_x > @width+100 or peer_x < -100
				if peer.speed.x > 0
					peer.position.x = -100
				else
					peer.position.x = @width+100
				peer.position.y = Math.random()*@height
			if peer_y > @height+100 or peer_y < -100
				peer.position.x = Math.random()*@width
				if peer.speed.y > 0
					peer.position.y = -100
				else
					peer.position.y = @height+100

			# Add lines
			for other in @peers
				distance = Math.max(Math.abs(peer_x-other.position.x), Math.abs(peer_y-other.position.y))
				if distance < 100
					lines.lineStyle(1, 0xFFFFFF, 1-distance/100)
					lines.moveTo(peer_x,peer_y)
					lines.lineTo(other.position.x, other.position.y)

		@render_texture.render(@container, null, true)
		#@render_texture2.render(@container, null, true)
		@renderer.render(@stage)
		if not @running then @speed -= 0.01
		else if @speed < 1 then @speed = Math.min(1, @speed+0.01)
		if @speed > 0.01 then requestAnimationFrame(@update)



	resize: =>
		@width = window.innerWidth
		@height = window.innerHeight
		#@renderer.view.style.width = @width + "px"
		#@renderer.view.style.height = @height + "px"
		@renderer.resize(@width, @height)
		if @bg
			@bg.position.x = @width/2-(@bg.width/2)
			@bg.position.y = @height/2-(@bg.height/2)


	start: ->
		if @disabled
			return false
		@running = true
		@speed = Math.max(0.02, @speed)
		clearInterval @fps_timer
		console.log "Start"
		@fps_timer = setInterval ( =>
			if @fps < 25*3 and @fps > 0
				@disabled = true
				@speed = 0
				@stop()
				console.log "Low FPS: #{@fps/3}, Disabling animation..."
			@fps = 0
		), 3000
		@update()

	stop: ->
		clearInterval @fps_timer
		@running = false


init = ->
	window.particles = new Particles()
	particles.resize()
	particles.createBlur()
	particles.addPeers()
	particles.start()
	$(".particles").css "opacity", 1
	$(window).on "resize", particles.resize

if window.innerHeight > 200
	init()
else # Not ready to init yet, delay with 20ms
	setTimeout init, 20


setInterval (->
	focus = document.hasFocus()
	if focus and particles.running == false
		particles.start()
	if not focus and particles.running == true
		particles.stop()
), 2000