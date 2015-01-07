
local Sprites = {}

Sprites.loading = {
  source = "img/sprLoading.png",
  frames = {width=48, height=48, numFrames=8},
  sequences = {
      { name = "stop", loopCount = 1, start = 1, count=1},
      { name = "play", time=1000, start = 1, count=8}
  }
}

Sprites.menuCat = {
  source = "img/menuCategories.png",
  frames = {width=32, height=32, numFrames=4},
  sequences = {
        { name = "stop", loopCount = 1, start = 1, count=1},
        { name = "open", frames={ 1,2,3,4 }, time=400, loopCount=1},
        { name = "close", frames={ 4,3,2,1 }, time=400, loopCount=1},
        
  }
}

return Sprites