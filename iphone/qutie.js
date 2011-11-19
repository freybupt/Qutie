Game = {};
Game.fps = 60;
Game.qt = null;
Game.environment = null;

Game.run = function(){
    Game.update();
    Game.draw();
};

// initialize the game
Game.init = function(){
    Game.environment = new Environment();
    Game.qt = new Qutie();
};

// starts the game
Game.start = function(){
    Game.init();
    Game._intervalId = setInterval(Game.run, 1000 / Game.fps);
};

// pauses the game
Game.pause = function(){
    clearInterval(Game._intervalId);
};

// bounds
Game.left = function(){
    return 0;
};
Game.right = function(){
    return Game.environment.width;
};
Game.top = function(){
    return 0;
};
Game.bottom = function(){
    return Game.environment.height;
};

// Vector -> Boolean
Game.isInBounds = function(vec){
    return vec.x >= Game.left() &&
    vec.x <= Game.right() &&
    vec.y >= Game.top() &&
    vec.y <= Game.bottom(); // (0, 0) is top left!
}

// Vector -> Vector
Game.enforceBounds = function(vec){

    if(vec.x > Game.right()){
        vec.x = Game.right();
    }else if(vec.x < Game.left()){
        vec.x = Game.left();
    }
    
    // (0, 0) is top-left
    if(vec.y > Game.bottom()){
        vec.y = Game.bottom();
    }else if(vec.y < Game.top()){
        vec.y = Game.top();
    }
    
    return vec;
}

// update
Game.update = function(){
    Game.qt.update();
};

// draw
Game.draw = function(){
    var ctx = document.getElementById(Game.environment.canvasid).getContext('2d');
    ctx.clearRect(0, 0, Game.right(), Game.bottom());
    Game.qt.drawFace();
};

function Environment(){
    this.width = 320;
    this.height = 460;
    this.canvasid = "qt-canvas";
}


function QRCode(){
    
}
  
function Qutie(){
    this.currentPic = new Image();
    this.currentPic.src = "img/QutieEyesOpen.png";
    this.width = 50.0;
    this.height = 60.0;
    this.pos = new Vector(100.0, 100.0);
    this.vel = new Vector(-3.0, 0.0);
    this.acc = new Vector(0.0, 1.0);
    this.ctx = null;
      
    // update
    this.update = function(){
               
        this.vel = new Vector(this.vel.x+this.acc.x, this.vel.y+this.acc.y);
        this.pos = new Vector(this.pos.x+this.vel.x, this.pos.y+this.vel.y);
          
        // enforce bounds
        if(!Game.isInBounds(this.pos)){
            if(this.pos.x > Game.right()){
                this.pos.x = Game.right();
                this.vel.x = -this.vel.x;
            }else if(this.pos.x < Game.left()){
                this.pos.x = Game.left();
                this.vel.x = -this.vel.x;
            }
    
            // (0, 0) is top-left
            if(this.pos.y > Game.bottom()){
               this.pos.y = Game.bottom();
               this.vel.y = -this.vel.y;
            }else if(this.pos.y < Game.top()){
                this.pos.y = Game.top();
                this.vel.y = -this.vel.y;
            }
            
        }
                
    }
    
    
    // draw
    this.draw = function(){
        this.drawFace();
    };
      
    // draw QT face
    this.drawFace = function(){
        // if(this.ctx == null) return;
          
        // TODO: test if has context
        ctx = document.getElementById(Game.environment.canvasid).getContext('2d');
          
        ctx.drawImage(this.currentPic, this.pos.x, this.pos.y, this.width, this.height);
    };
      
}

  
  
  
  
function Vector(x, y)
{
    this.x = x; 
    this.y = y; 
    
    this.equal = function(v)
    {
        return this.x == v.getX() && this.y == v.getY(); 
    }
    this.getX = function()
    {
        return this.x; 
    }
    this.getY = function()
    {
        return this.y; 
    }
    this.setX = function(x)
    {
        this.x = x; 
    }
    this.setY = function(y)
    {
        this.y = y; 
    }
    this.addX = function(x)
    {
        this.x += x; 
    }
    this.addY = function(y)
    {
        this.y += y; 
    }
    this.set = function(v)
    {
        this.x = v.getX(); 
        this.y = v.getY(); 
    }
    this.add = function(v)
    {
        this.x += v.getX(); 
        this.y += v.getY(); 
    }
    this.sub = function(v)
    {
        this.x -= v.getX(); 
        this.y -= v.getY(); 
    }
    this.dotProd = function(v)
    {
        return this.x * v.getX() + this.y * v.getY(); 
    }
    this.length = function()
    {
        return Math.sqrt(this.x * this.x + this.y * this.y); 
    }
    this.scale = function(scaleFactor)
    {
        this.x *= scaleFactor; 
        this.y *= scaleFactor; 
    }
    this.toString = function()
    {
        return " X: " + this.x + " Y: " + this.y; 
    }
}

  