Game = {};
Game.fps = 24;
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
    vec.x + this.qt.width <= Game.right() &&
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

Game.onclick = function(event){
    var xy = Game.environment.getCanvasMouseXY(event);
    Game.qt.onclick(xy.x, xy.y);
}




function Environment(){
    this.width = 320;
    this.height = 460;
    this.canvasid = "qt-canvas";
    
    // returns the coordinates of the canvas
    // null -> {x, y}
    this.getCanvasCoordinates = function(){
        return {x: Util.left(document.getElementById(this.canvasid)),
                y: Util.top(document.getElementById(this.canvasid))};
    }
    
    // returns the mouse click coordinates
    // null -> {x, y}
    this.getCanvasMouseXY = function(event){
        xy = Util.getMouseXY(event);
        xyc = this.getCanvasCoordinates();
        return {x: xy.x - xyc.x, y: xy.y - xyc.y};    
    }
}


function QRCode(){
    
}

QTStates = {};
QTStates.eyes_open = 1;
QTStates.eyes_closed = 2;
QTStates.crying = 3;
QTStates.eating = 4;
QTStates.happy = 5;
QTStates.winking = 6;
QTStates.spooked = 7;

// TODO: offload into resource file! Not here!
QTStates.getImagePath = function(state){
    switch(state){
        case QTStates.eyes_open:
            return "QutieEyesOpen.png";
            break;
        case QTStates.eyes_closed:
            return "QutieEyesClosed.png";
            break;
        case QTStates.crying:
            return "Crying.png";
            break;
        case QTStates.eating:
            return "Eating.png";
            break;
        case QTStates.happy:
            return "Happy.png";
            break;
        case QTStates.winking:
            return "Winking.png";
            break;
        case QTStates.spooked:
            return "Spooked.png";
            break;
        default:
            return "Crying.png";
    }
}
  
function Qutie(){
    this.currentPic = new Image();
    this.currentPic.src = "Spooked.png";
    this.width = 150.0;
    this.height = 130.0;
    this.pos = new Vector(100.0, 100.0);
    this.vel = new Vector(-3.0, 0.0);
    this.acc = new Vector(0.0, 1.0);
    this.ctx = null;
    
    this.state_eyes = QTStates.happy; // not used anymore
    this.current_emotion = QTStates.happy;

    
    this.isHit = function(x, y){
        return ((this.pos.x < x && x < (this.pos.x + this.width)) &&
               (this.pos.y < y && y < (this.pos.y + this.height)));
    }
    
    ///////////////////////////////////////////////////////////////////////////
    // Controller
    ///////////////////////////////////////////////////////////////////////////
          
    // update
    this.update = function(){
               
        this.vel = new Vector(this.vel.x+this.acc.x, this.vel.y+this.acc.y);
        this.pos = new Vector(this.pos.x+this.vel.x, this.pos.y+this.vel.y);
        
        
        var pos_x_r = parseInt(this.pos.x) + parseInt(this.width);
        
        // enforce bounds
        if(!Game.isInBounds(this.pos)){
            if(pos_x_r > Game.right()){
                this.pos.x = parseInt(Game.right())-parseInt(this.width);
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
        
    // on click
    this.onclick = function(x, y){
        if(this.isHit(x,y)){
            this.toggleEyes();
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////
    // Put all drawing functions here
    ///////////////////////////////////////////////////////////////////////////

    // draw
    this.draw = function(){
        this.drawFace();
    };
      
    // draw QT face
    this.drawFace = function(){
        // if(this.ctx == null) return;
          
        // TODO: test if has context
        ctx = document.getElementById(Game.environment.canvasid).getContext('2d');
        
        this.currentPic = new Image();
        this.currentPic.src = QTStates.getImagePath(this.current_emotion);
        this.drawCurrentPicture(ctx);
        
    };

    // Draws the current picture
    this.drawCurrentPicture = function(ctx){
        ctx.drawImage(this.currentPic, this.pos.x, this.pos.y, this.width, this.height);
        //Util.drawPicByDiv(this.currentPic.src, this.pos.x, this.pos.y, this.width, this.height);
    }
       
    
    ///////////////////////////////////////////////////////////////////////////
    // Put all state changing functions here
    ///////////////////////////////////////////////////////////////////////////
    
    this.closeEyes = function(){
        this.state_eyes = QTStates.eyes_closed;
    }
    
    this.openEyes = function(){
        this.state_eyes = QTStates.eyes_open;
    }
    
    this.toggleEyes = function(){
        if(this.state_eyes == QTStates.eyes_closed){
            this.openEyes();
        }else{
            this.closeEyes();
        }
    }      
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

Util = {};

// Returns the xy position of the mouse
Util.getMouseXY = function(event){
    return {
        x: event.pageX, 
        y:event.pageY
        };
}

// Find the left coordinate of an object
Util.left = function(obj)
{
    var curleft = 0;
    if (obj.offsetParent)
        while (1) {
            curleft += obj.offsetLeft;
            if (!obj.offsetParent)
                break;
            obj = obj.offsetParent;
        }
    else if (obj.x)
        curleft += obj.x;
    return curleft;
}

// Find the top coordinate of an object
Util.top = function(obj)
{
    var curtop = 0;
    if (obj.offsetParent)
        while (1) {
            curtop += obj.offsetTop;
            if (!obj.offsetParent)
                break;
            obj = obj.offsetParent;
        }
    else if (obj.y)
        curtop += obj.y;
    return curtop;
}

// TODO: fix, not working
Util.drawPicByDiv = function(imgStr, x, y, w, h){
    document.getElementById('qt').innerHTML = 
        "<div id='qtpic' style={position: fixed; left:"+x+";top:"+y+";width:"+w+"px;height:"+h+"px;}>"
        +"<img src='"+imgStr+"' style={width:100%; height:100%;}></img>"      
        +"</div>";
}