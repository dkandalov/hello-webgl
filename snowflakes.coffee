if !Detector.webgl then Detector.addGetWebGLMessage()

stage = null
particles = []
stats = null

class ParticleSystem
  constructor: (@index, @config) ->
    amount = @config[4]
    geometry = new THREE.Geometry()
    for i in [0...amount]
      vertex = new THREE.Vector3()
      vertex.x = Math.random() * 2000 - 1000
      vertex.y = Math.random() * 2000 - 1000
      vertex.z = Math.random() * 2000 - 1000
      geometry.vertices.push(vertex)

    @rotationSpeed = config[3]
    @material = new THREE.ParticleBasicMaterial({
      size: config[2],
      map: THREE.ImageUtils.loadTexture(config[1]),
      blending: THREE.AdditiveBlending,
      depthTest: false,
      transparent: true,
      opacity: 0.8
    })
    color = config[0]
    @material.color.setHSL(color[0], color[1], color[2])

    @particles = new THREE.ParticleSystem(geometry, @material)
    @particles.rotation.x = Math.random() * 6
    @particles.rotation.y = Math.random() * 6
    @particles.rotation.z = Math.random() * 6

  addTo: (scene) -> scene.add(@particles)

  animate: (time) ->
    time = time * 0.00005
    @particles.rotation.y = time * @rotationSpeed

    color = @config[0]
    h = (360 * (color[0] + time) % 360) / 360
    @material.color.setHSL(h, color[1], color[2])


class Stage
  constructor: ->
    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000)
    @camera.position.z = 1000

    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2(0x000000, 0.0012)

    @renderer = new THREE.WebGLRenderer()
    @renderer.setClearColor(0x000000, 1)
    @renderer.setSize(window.innerWidth, window.innerHeight)

    @mouseX = 0
    @mouseY = 0

  appendTo: (container) ->
    container.appendChild(@renderer.domElement)

  onWindowSizeChange: (window) ->
    @windowHalfX = window.innerWidth / 2
    @windowHalfY = window.innerHeight / 2

    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()
    @renderer.setSize(window.innerWidth, window.innerHeight)

  onNewMousePosition: (x, y) ->
    @mouseX = x - @windowHalfX
    @mouseY = y - @windowHalfY

  render: ->
    @camera.position.x += (@mouseX - @camera.position.x) * 0.05
    @camera.position.y += (-@mouseY - @camera.position.y) * 0.05
    @camera.lookAt(@scene.position)

    @renderer.render(@scene, @camera)



init = (showStats = false) ->
  rootContainer = document.createElement('div')
  document.body.appendChild(rootContainer)

  stage = new Stage()

  parameters = [
    [[1.0, 0.2, 0.5], "sprites/class.png", 20, 1.5, 6000],
    [[1.0, 0.2, 0.5], "sprites/abstractClass@2x.png", 20, 1.5, 1000],
    [[0.95, 0.1, 0.5], "sprites/method.png", 15, 2, 7000],
    [[0.90, 0.05, 0.5], "sprites/interface.png", 10, 2, 5000],
    [[0.85, 0, 0.5], "sprites/testError.png", 8, 4, 3000],
    [[0.60, 0, 0.5], "sprites/sourceFolder.png", 5, 3, 3000],
    [[0.60, 0, 0.5], "sprites/exceptionClass@2x.png", 5, 2, 3000],
    [[0.60, 0, 0.5], "sprites/error_notifications@2x.png", 15, 2, 3000],
    [[0.60, 0, 0.5], "sprites/debug@2x_dark.png", 15, 2, 1000],
    [[0.60, 0, 0.5], "sprites/warning@2x.png", 15, 2, 3000],
    [[0.60, 0, 0.5], "sprites/antInstallation@2x_dark.png", 10, 2, 300],
    [[0.60, 0, 0.4], "sprites/xsdFile@2x.png", 15, 0.4, 400],
    [[0.60, 0, 0.4], "sprites/ejbClass.png", 10, 1, 400],
    [[0.60, 0, 0.4], "sprites/ejb@2x.png", 10, 1, 400],
    [[0.60, 0, 0.4], "sprites/home.png", 10, 1, 400],
  ]

  for i in [0...parameters.length]
    do ->
      particleSystem = new ParticleSystem(i, parameters[i])
      particleSystem.addTo(stage.scene)
      particles.push(particleSystem)

  if showStats
    stats = new Stats()
    stats.domElement.style.position = 'absolute'
    stats.domElement.style.top = '0px'
    rootContainer.appendChild(stats.domElement)

  stage.appendTo(rootContainer)
  stage.onWindowSizeChange(window)

  onDocumentTouch = (event) ->
    if event.touches.length == 1
      event.preventDefault()
      stage.onNewMousePosition(event.touches[0].pageX, event.touches[0].pageY)

  document.addEventListener('touchstart', onDocumentTouch, false)
  document.addEventListener('touchmove', onDocumentTouch, false)
  document.addEventListener('mousemove', ((event) -> stage.onNewMousePosition(event.clientX, event.clientY)), false)
  window.addEventListener('resize', (-> stage.onWindowSizeChange(window)), false)


animate = ->
  requestAnimationFrame(animate)

  time = Date.now()
  for particleSystem in particles
    particleSystem.animate(time)

  stage.render()

  if stats != null
    stats.update()


init()
animate()
