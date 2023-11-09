#6 sides:

#- left  (positive +x or px)
#- right (negative -x or nx)
#- up    (positive +y or py)
#- down  (negative -y or ny)
#- front (positive +z or pz)
#- back  (negative -z or nz)

# this works with http://www.humus.name  , the empty.jpg has to be created manually for now as 1024x1024 in black color
montage -geometry 1024 -tile 4x3 \
  empty.jpg posy.jpg empty.jpg empty.jpg \
  negx.jpg  posz.jpg posx.jpg  negz.jpg  \
  empty.jpg negy.jpg empty.jpg empty.jpg \
  skybox.png
  
