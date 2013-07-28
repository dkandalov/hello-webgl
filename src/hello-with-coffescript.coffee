init = ->
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
  camera.position.z = 500

  scene = new THREE.Scene()

  geometry = new THREE.CubeGeometry(200, 200, 200, 10, 10, 10)
  material = new THREE.MeshBasicMaterial({ color: 0x0f0f0f, wireframe: true })
  mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  renderer = new THREE.CanvasRenderer()
  renderer.setSize(window.innerWidth, window.innerHeight)
  document.body.appendChild(renderer.domElement)

  renderFunction = -> renderer.render(scene, camera)
  [renderFunction, mesh]

animate = (renderFunction, mesh) ->
  # note: three.js includes requestAnimationFrame shim
  requestAnimationFrame(-> animate(renderFunction, mesh))

  mesh.rotation.x += 0.03
  mesh.rotation.y += 0.02

  renderFunction()


[renderFunction, mesh] = init()
animate(renderFunction, mesh)
