if !Detector.webgl then Detector.addGetWebGLMessage()

stats = null

camera = null
scene = null
renderer = null
materials = []
parameters = null


init = ->
  container = document.createElement('div')
  document.body.appendChild(container)

  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 2000)
  camera.position.z = 1000

  scene = new THREE.Scene()
  scene.fog = new THREE.FogExp2(0x000000, 0.0008)

  geometry = new THREE.Geometry()
  for i in [0...10000]
    vertex = new THREE.Vector3()
    vertex.x = Math.random() * 2000 - 1000
    vertex.y = Math.random() * 2000 - 1000
    vertex.z = Math.random() * 2000 - 1000
    geometry.vertices.push(vertex)

  sprite1 = THREE.ImageUtils.loadTexture("sprites/interface.png")
  sprite2 = THREE.ImageUtils.loadTexture("sprites/class.png")
  sprite3 = THREE.ImageUtils.loadTexture("sprites/method.png")
  sprite4 = THREE.ImageUtils.loadTexture("sprites/sourceFolder.png")
  sprite5 = THREE.ImageUtils.loadTexture("sprites/testError.png")
  parameters = [
    [[1.0, 0.2, 0.5], sprite2, 20],
    [[0.95, 0.1, 0.5], sprite3, 15],
    [[0.90, 0.05, 0.5], sprite1, 10],
    [[0.85, 0, 0.5], sprite5, 8],
    [[0.80, 0, 0.5], sprite4, 5]
  ]

  for i in [0...parameters.length]
    do ->
      parameter = parameters[i]
      color = parameter[0]
      sprite = parameter[1]
      size = parameter[2]

      materials[i] = new THREE.ParticleBasicMaterial({
        size: size,
        map: sprite,
        blending: THREE.AdditiveBlending,
        depthTest: false,
        transparent: true
      })
      materials[i].color.setHSL(color[0], color[1], color[2])

      particles = new THREE.ParticleSystem(geometry, materials[i])
      particles.rotation.x = Math.random() * 6
      particles.rotation.y = Math.random() * 6
      particles.rotation.z = Math.random() * 6

      scene.add(particles)

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

  for i in [0...scene.children.length]
    object = scene.children[i]
    if object instanceof THREE.ParticleSystem
      object.rotation.y = time * (i < 4 ? i + 1 : -(i + 1))

  for i in [0...materials.length]
    color = parameters[i][0]
    h = (360 * (color[0] + time) % 360) / 360
    materials[i].color.setHSL(h, color[1], color[2])

  renderer.render(scene, camera)


windowState = init()
animate(windowState)
