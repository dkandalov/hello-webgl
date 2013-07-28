if !Detector.webgl then Detector.addGetWebGLMessage()

stats = null

camera = null
scene = null
renderer = null
materials = []
parameters = null
particles = []

class ParticleSystem
  constructor: (@index, @config) ->
    geometry = new THREE.Geometry()
    for i in [0...10000]
      vertex = new THREE.Vector3()
      vertex.x = Math.random() * 2000 - 1000
      vertex.y = Math.random() * 2000 - 1000
      vertex.z = Math.random() * 2000 - 1000
      geometry.vertices.push(vertex)

    @material = new THREE.ParticleBasicMaterial({
      size: config[2],
      map: THREE.ImageUtils.loadTexture(config[1]),
      blending: THREE.AdditiveBlending,
      depthTest: false,
      transparent: true
    })
    color = config[0]
    @material.color.setHSL(color[0], color[1], color[2])

    @particles = new THREE.ParticleSystem(geometry, @material)
    @particles.rotation.x = Math.random() * 6
    @particles.rotation.y = Math.random() * 6
    @particles.rotation.z = Math.random() * 6

  addTo: (scene) -> scene.add(@particles)

  animate: (time) ->
    @particles.rotation.y = time * (@index < 4 ? @index + 1 : -(@index + 1))

    color = @config[0]
    h = (360 * (color[0] + time) % 360) / 360
    @material.color.setHSL(h, color[1], color[2])


init = ->
  container = document.createElement('div')
  document.body.appendChild(container)

  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000)
  camera.position.z = 1000

  scene = new THREE.Scene()
  scene.fog = new THREE.FogExp2(0x000000, 0.0008)

  parameters = [
    [[1.0, 0.2, 0.5], "sprites/class.png", 20],
    [[0.95, 0.1, 0.5], "sprites/method.png", 15],
    [[0.90, 0.05, 0.5], "sprites/interface.png", 10],
    [[0.85, 0, 0.5], "sprites/testError.png", 8],
    [[0.80, 0, 0.5], "sprites/sourceFolder.png", 5]
  ]

  for i in [0...parameters.length]
    do ->
      particleSystem = new ParticleSystem(i, parameters[i])
      particleSystem.addTo(scene)
      particles.push(particleSystem)

  renderer = new THREE.WebGLRenderer({ clearAlpha: 1 })
  renderer.setSize(window.innerWidth, window.innerHeight)
  container.appendChild(renderer.domElement)

  stats = new Stats()
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.top = '0px'
  container.appendChild(stats.domElement)

  windowState =
    halfX: window.innerWidth / 2,
    halfY: window.innerHeight / 2,
    mouseX: 0,
    mouseY: 0

  document.addEventListener('mousemove', ((event) -> onDocumentMouseMove(windowState, event)), false)
  document.addEventListener('touchstart', ((event) -> onDocumentTouchStart(windowState, event)), false)
  document.addEventListener('touchmove', ((event) -> onDocumentTouchMove(windowState, event)), false)
  window.addEventListener('resize', (-> onWindowResize(windowState)), false)

  windowState


onWindowResize = (windowState) ->
  windowState.halfX = window.innerWidth / 2
  windowState.halfY = window.innerHeight / 2

  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize(window.innerWidth, window.innerHeight)


onDocumentMouseMove = (windowState, event) ->
  windowState.mouseX = event.clientX - windowState.halfX
  windowState.mouseY = event.clientY - windowState.halfY


onDocumentTouchStart = (windowState, event) ->
  if event.touches.length == 1
    event.preventDefault()
    windowState.mouseX = event.touches[0].pageX - windowState.halfX
    windowState.mouseY = event.touches[0].pageY - windowState.halfY


onDocumentTouchMove = (windowState, event) ->
  if event.touches.length == 1
    event.preventDefault()
    windowState.mouseX = event.touches[0].pageX - windowState.halfX
    windowState.mouseY = event.touches[0].pageY - windowState.halfY


animate = (windowState) ->
  requestAnimationFrame(-> animate(windowState))
  render(windowState)
  stats.update()


render = (windowState) ->
  time = Date.now() * 0.00005

  camera.position.x += (windowState.mouseX - camera.position.x) * 0.05
  camera.position.y += (-windowState.mouseY - camera.position.y) * 0.05
  camera.lookAt(scene.position)

  for particleSystem in particles
    particleSystem.animate(time)

  renderer.render(scene, camera)


windowState = init()
animate(windowState)
