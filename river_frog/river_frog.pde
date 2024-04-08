import java.util.Iterator;

PImage frog; // 青蛙的图像
PImage lilyPad; // 荷叶的图像
PImage fly; // 蒼蠅的图像
PImage snake; // 蒼蠅的图像
PImage snake_flipped; // 蒼蠅的图像
PImage startScreen; // 开始画面的图像
PImage ruleScreen; // 规则页面的图像
PImage gameOverScreen; // 游戏结束画面图像
PImage startButton; // 开始按钮图像
PImage ruleButton; // 规则按钮图像
PImage backButton; // 返回按钮图像
PImage restartButton; // 返回按钮图像
PImage deadIcon; // 死亡图示

// 按钮的坐标位置
int xStartButton, yStartButton, xEndButton, yEndButton;
int xRuleButton, yRuleButton, xEndRuleButton, yEndRuleButton;
int xBackButton, yBackButton, xEndBackButton, yEndBackButton;
int xRestartButton, yRestartButton, xEndRestartButton, yEndRestartButton;

// 游戏状态
final int STATE_START = 0;
final int STATE_RULES = 1;
final int STATE_GAME = 2;
final int STATE_GAME_OVER = 3;
int gameState = STATE_START; // 当前游戏状态

// 游戏角色的位置
float frogX, frogY; 

// 青蛙的跳跃动画状态
float jumpState = 0; 
float jumpPeak; // 青蛙跳跃的最高点相对位置
float jumpTarget; // 青蛙跳跃的目标Y坐标
boolean jumpingDown = false; // 青蛙是否正在向下跳
boolean jumpdone = false; // 青蛙是否完成跳跃
boolean leaveLand = false; // 青蛙是否已经跳过
boolean jumpInPlace = false; // 青蛙是否在原地跳

int numberOfLilyPads = 50; // 全部荷叶的数量
class LilyPad {
    float x, y;
    float speed; // 荷叶的移动速度
    boolean hasFrog; // 是否有青蛙在上面
    
    LilyPad(float x, float y, float speed) {
        this.x = x;
        this.y = y;
        this.speed = speed;
    }
    
    void display() {
        image(lilyPad, x, y);
    }
    
    void move() {
        x += speed;
        // 如果荷叶移动到屏幕外，它会从另一边出现
        if (x > width) x = -lilyPad.width;
        if (x < - lilyPad.width) x = width;
    }
}
ArrayList<LilyPad>[] lilyRows;
boolean onLilyPad;
LilyPad currentLilyPad;

class Fly {
    float x, y; // 蒼蠅的初始位置
    float shakeRange = 5; // 震动范围
    float shakeX, shakeY; // 震动的实际位置
    
    Fly(float x, float y) {
        this.x = x;
        this.y = y;
        shakeX = x;
        shakeY = y;
    }
    
    void display() {
        image(fly, shakeX, shakeY); // 使用 shakeX 和 shakeY 来显示震动位置
    }
    
    void shake() {
        // 随机震动，确保不会偏离太远
        shakeX = x + random( - shakeRange, shakeRange);
        shakeY = y + random( - shakeRange, shakeRange);
    }
}
ArrayList<Fly> flies; 
int numberOfFlies = 14; // 蒼蠅的数量
int removedFliesCount = 0;

class Snake {
    float x, y;
    float speed;

    Snake(float x, float y, float speed) {
        this.x = x;
        this.y = y;
        this.speed = speed;
    }

    void display() {
        if(speed > 0) image(snake, x, y);
        else image(snake_flipped, x, y);
    }

    void move() {
        x += speed;
        // 如果荷叶移动到屏幕外，它会从另一边出现
        if (x > width) x = -lilyPad.width;
        if (x < - lilyPad.width) x = width;
    }
}
ArrayList<Snake> snakes;

class Land {
    float x, y, width, height;

    Land(float x, float y, float width, float height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    void display() {
        fill(#86502E); // 土地的颜色
        rect(x, y, width, height);
    }

    void move(float speed) {
        y -= speed; // 向上移动
    }

    boolean isOffScreen() {
        return y + height < -10; // 检查土地是否完全离开屏幕
    }
}
ArrayList<Land> lands;

enum DeathReason {
    DROWNED, 
    EATEN_BY_SNAKE,
    RIP
}
DeathReason deathReason;

int snakeAnimationFrame = 5; // 动画帧的开始
int snakeAnimationEndFrame = 60; // 动画帧的结束
int drownAnimationFrame = 61; // 动画帧的开始
int drownAnimationEndFrame = 94; // 动画帧的结束
int animationFrameRate = 8; // 每秒8帧
int frameCountDown = 0; // 帧计数器
boolean animationFinished = false; // 动画是否完成的标记
int animationPauseTime = 1000; // 动画结束后的暂停时间（毫秒）
int lastFrameTime;

boolean debug = false;

float scrollSpeed = 0.5;

float landY;

int score = 0;
int deaths = 0;

void setup() {
    size(1120, 630);
    
    // 加载图像资源
    frog = loadImage("assets/frog.png");
    lilyPad = loadImage("assets/lilyPad.png"); // 加载荷叶图像
    fly = loadImage("assets/fly.png"); // 加载蒼蠅图像
    snake = loadImage("assets/snake.png"); // 加载蛇图像
    snake_flipped = loadImage("assets/snake_flipped.png"); // 加载蛇图像
    deadIcon = loadImage("assets/dead.png"); // 加载死亡图示
    startScreen = loadImage("assets/start_screen.png");
    ruleScreen = loadImage("assets/rule_screen.png");
    gameOverScreen = loadImage("assets/gameover.png");
    startButton = loadImage("assets/start_btn.png");
    ruleButton = loadImage("assets/rule_btn.png");
    backButton = loadImage("assets/back_btn.png");
    restartButton = loadImage("assets/restart_btn.png");
    
    frog.resize(0, height / 10); // 根据屏幕高度调整青蛙大小
    lilyPad.resize(0, frog.height); // 调整荷叶大小与青蛙高度一致
    fly.resize(0, frog.height / 2); // 根据需要调整蒼蠅大小
    snake.resize(0, frog.height); // 根据需要调整蛇的大小
    snake_flipped.resize(0, frog.height); // 根据需要调整蛇的大小
    deadIcon.resize(0, height / 20);
    startScreen.resize(1120, 630);
    ruleScreen.resize(1120, 630);
    gameOverScreen.resize(1120, 630);
    startButton.resize(0, 70); // 以高度100像素调整开始按钮大小
    ruleButton.resize(0, 70); // 以高度100像素调整规则按钮大小
    backButton.resize(0, 70); // 调整返回按钮大小
    restartButton.resize(0, 90); // 调整重新开始按钮大小
    
    //设置开始按钮的坐标
    xStartButton = (width - startButton.width) / 2;
    yStartButton = height - startButton.height * 2 - 25; // 假设按钮位于屏幕中央
    xEndButton = xStartButton + startButton.width;
    yEndButton = yStartButton + startButton.height;
    //设置规则按钮的坐标
    xRuleButton = xStartButton; // 假设规则按钮与开始按钮在同一水平线上
    yRuleButton = yEndButton + 15; // 规则按钮位于开始按钮下方20像素的位置
    xEndRuleButton = xRuleButton + ruleButton.width;
    yEndRuleButton = yRuleButton + ruleButton.height;
    
    // 设置返回按钮的坐标，用于规则页面
    xBackButton = (width - backButton.width) / 2;
    yBackButton = height - backButton.height - 10; // 屏幕底部上方50像素
    xEndBackButton = xBackButton + backButton.width;
    yEndBackButton = yBackButton + backButton.height;
    
    xRestartButton = (width - restartButton.width) / 2;
    yRestartButton = height - restartButton.height - 50; // 屏幕底部上方50像素
    xEndRestartButton = xRestartButton + restartButton.width;
    yEndRestartButton = yRestartButton + restartButton.height;
    
    //初始位置在画面中央
    frogX = width / 2 - frog.width / 2;
    frogY = height / 2 - frog.height / 2;
    jumpTarget = frogY; // 初始跳跃目标就是初始位置
    jumpPeak = frog.height * 5 / 4; // 设置跳跃的最高点相对位置
    jumpdone = false;
    leaveLand = false; 
    jumpInPlace = false;
    jumpState = 0;
    
    //初始化荷叶的X坐标数组
    lilyRows = new ArrayList[height / frog.height + 1]; // 假设屏幕下半部分是河流
    for (int i = 0; i < lilyRows.length; i++) {
        lilyRows[i] = new ArrayList<LilyPad>();
        float yPosition = (i + 1) * frog.height + height / 2;
        //对于每一行，我们添加一些荷叶
        for (int j = 0; j < numberOfLilyPads / lilyRows.length; j++) {
            float xPosition = random(width);
            float speed = random(1, 3); // 随机速度
            if(random(100) < 50) speed = -speed; // 随机决定方向
            lilyRows[i].add(new LilyPad(xPosition, yPosition, speed));
        }
    }
    onLilyPad = false;
    currentLilyPad = null;
    
    flies = new ArrayList<Fly>();
    //在适当位置生成蒼蠅
    for (int i = 0; i < numberOfFlies; i++) { 
        float x = random(width);
        float y = (int)random(height / frog.height + 1) * frog.height + height / 2;
        flies.add(new Fly(x, y));
    }   
    
    drownAnimationFrame = 61;
    snakeAnimationFrame = 5; // 动画帧的开始
    animationFinished = false;
    
    landY = height / 2 + frog.height / 2;

    lands = new ArrayList<Land>();
    for (int i = 0; i < 2; i++) { 
        float y = (int)random(height / frog.height + 1) * frog.height + height;
        lands.add(new Land(0, y, width, (int)random(1,5) * frog.height));
    }

    snakes = new ArrayList<Snake>();
}

void draw() {
    switch(gameState) {
        case STATE_START:
            drawInfo();
            // 绘制开始画面
            image(startScreen, 0, 0, width, height);
            image(startButton, xStartButton, yStartButton);
            image(ruleButton, xRuleButton, yRuleButton);
            drawInfo();
            break;
        case STATE_RULES:
            // 绘制规则页面
            image(ruleScreen, 0, 0, width, height);
            image(backButton, xBackButton, yBackButton);
            drawInfo();
            break;
        case STATE_GAME:
            // 游戏主逻辑
            runGame();
            drawInfo();
            break;
        case STATE_GAME_OVER:
            if (debug) runGame();
            else
                displayGameOverScreen();
            break;
    }
}

void drawInfo(){
    drawScore();
    drawDeaths();
}

void drawScore() {
    // 设置文字大小
    textSize(32);
    // 计算文字的宽度和高度
    float textWidth = textWidth("Flies: " + score);
    float textHeight = textAscent() + textDescent();
    // 计算背景框的位置和尺寸
    float rectX = 10;
    float rectY = 10;
    float rectWidth = textWidth + 10;
    float rectHeight = textHeight + 10;
    // 绘制背景框
    fill(0, 150); // 黑色半透明背景
    noStroke();
    rect(rectX, rectY, rectWidth, rectHeight);
    // 设置文字对齐方式为居中
    textAlign(CENTER, CENTER);
    // 在框框的正中间绘制文字
    fill(255); // 白色文字
    text("Flies: " + score, rectX + rectWidth / 2, rectY + rectHeight / 2);
}

void drawDeaths(){
        // 计算图示和文字所需的总宽度
    textSize(32);
    float textWidth = textWidth("     " + deaths);
    float iconWidth = deadIcon.width;
    float totalWidth = iconWidth + textWidth;

    // 计算背景框的位置和尺寸
    float rectX = width - 20 - totalWidth;
    float rectY = 10;
    float rectWidth = totalWidth + 10;
    float rectHeight = deadIcon.height + 10;

    // 绘制背景框
    fill(0, 150); // 黑色半透明背景
    noStroke();
    rect(rectX, rectY, rectWidth, rectHeight);

    // 绘制图示
    image(deadIcon, rectX + 5, rectY + 5);

    // 绘制文字
    fill(255); // 白色文字
    text("     " + deaths, rectX + 5 + iconWidth, rectY + rectHeight / 2);
}

void runGame() {
    //游戏逻辑
    background(#0D839E);
    if (leaveLand) {
        landY -= scrollSpeed; // 河流向上移动
        fill(#86502E);
        rect(0, 0, width, landY); // 绘制青蛙的起始位置
        frogY -= scrollSpeed; // 青蛙向上移动
        jumpTarget -= scrollSpeed; // 跳跃目标向上移动
        for (Fly fly : flies) {
            fly.y -= scrollSpeed;
        }
        for (Land land : lands) {
            land.move(scrollSpeed);
        }
    } else{
        fill(#86502E);
        rect(0, 0, width, landY); // 绘制青蛙的起始位置
    }
    
    boolean frogIsSafe = false;
    
    //绘制荷叶
    for (ArrayList < LilyPad > lilyRow : lilyRows) {
        for (LilyPad lily : lilyRow) {
            if (leaveLand)
                lily.y -= scrollSpeed;
            lily.move();
            lily.display();
        }
    }

    boolean onLand = false;
    for (Land land : lands) {
        land.display();
        // 检查青蛙是否在土地上
        if (land.y < frogY + frog.height && land.y + land.height >= frogY + frog.height) {
            onLand = true;
        }
        // 如果土地离开屏幕，移除并创建新的土地
        if (land.isOffScreen()) {
            land.y = (int)random(10,15) * frog.height + frogY;
            land.height = (int)random(1,5) * frog.height; // 随机生成新的土地
        }
        // println(snakes.size());
        if (snakes.size() < land.height/frog.height*2) { // 10% 的几率在每块土地上生成一条蛇，同时限制蛇的总数
            float snakeX = random(0, width);
            float snakeY = land.y+frog.height*(int)random(land.height/frog.height - 1); // 蛇应该出现在土地的上方
            snakes.add(new Snake(snakeX, snakeY, random(1, 4)*(random(1) > 0.5 ? 1 : -1)));
        }
    }

    for (Snake snake : snakes) {
        snake.display();
        snake.move();
        if(leaveLand) {
            snake.y -= scrollSpeed;
        }
    }

    // 检查青蛙是否与蛇相撞
    Iterator<Snake> snakeIterator = snakes.iterator();
    while (onLand && snakeIterator.hasNext()) {
        Snake snake = snakeIterator.next();
        if (dist(frogX, frogY, snake.x, snake.y) < frog.width) {
            // 青蛙与蛇相撞，结束游戏
            gameState = STATE_GAME_OVER;
            endGame(DeathReason.EATEN_BY_SNAKE);
            break;
        }
        if(snake.y < -10) {
            snakeIterator.remove();
        }
    }
    
    float topRowY = lilyRows[0].get(0).y; // 获取顶部荷叶行的Y坐标
    if(topRowY < -frog.height) {
        // 创建新的荷叶行并添加到顶部
        ArrayList<LilyPad> newRow = new ArrayList<LilyPad>();
        float newYPosition = lilyRows[lilyRows.length - 1].get(0).y + lilyPad.height;
        for (int j = 0; j < numberOfLilyPads / lilyRows.length; j++) {
            float newXPosition = random(width);
            float newSpeed = random(1, 3); // 随机速度
            if (random(100) < 50) newSpeed = -newSpeed; // 随机决定方向
            newRow.add(new LilyPad(newXPosition, newYPosition, newSpeed));
        }
        // 移除底部行，将新行添加到顶部
        lilyRows = (ArrayList<LilyPad>[]) append(subset(lilyRows, 1), newRow);
        
        Iterator<Fly> it = flies.iterator();
        while(it.hasNext()) {
            Fly fly = it.next();
            if (fly.y < 0) {
                it.remove();
            }
        }
    }
    // 根据被移除的蒼蠅数量，添加同等数量的新蒼蠅
    while (flies.size() < numberOfFlies){
        float x = random(width);
        float y = lilyRows[lilyRows.length - 1].get(0).y + (int)random(1, 5) * frog.height; // 在屏幕底部随机位置生成蒼蠅
        flies.add(new Fly(x, y));
    }
    
    //检查并更新青蛙是否在荷叶上
    if(leaveLand && jumpdone && !onLilyPad) {
        for (ArrayList < LilyPad > lilyRow : lilyRows) {
            for (LilyPad lily : lilyRow) {
                if (frogX + frog.width > lily.x && frogX < lily.x + lilyPad.width && 
                    abs(jumpTarget + frog.height / 2 - lily.y)<30) {
                    frogIsSafe= true;
                    currentLilyPad = lily; // 更新当前荷叶
                    onLilyPad = true;
                    break;
                }
            }
            if (onLilyPad) {
                break;
            }
        }
        if (!onLilyPad && !onLand) {
            gameState = STATE_GAME_OVER;
            endGame(DeathReason.DROWNED);
        }
    }
    
    //如果青蛙在荷叶上，让青蛙跟随荷叶移动
    if(onLilyPad && currentLilyPad != null && !onLand) {
        frogIsSafe = true;
        // 青蛙跟随荷叶移动
        frogX += currentLilyPad.speed;
        
        // 检查荷叶是否要离开屏幕
        if ((currentLilyPad.x + lilyPad.width <= 10 || currentLilyPad.x >= width - 10) && !onLand) {
            gameState = STATE_GAME_OVER;
            endGame(DeathReason.DROWNED);
        }
        
        if ((frogX + frog.width < currentLilyPad.x - 5 || frogX > currentLilyPad.x + lilyPad.width + 5) && !onLand) {
            gameState = STATE_GAME_OVER;
            endGame(DeathReason.DROWNED);
        }
    }
    
    //跳跃逻辑
    if(jumpState != 0) { // 青蛙不在荷叶上
        jumpdone = false;
        frogY += jumpingDown ? jumpState : - jumpState;
        // 青蛙向上跳
        if (!jumpInPlace && frogY <= jumpTarget - jumpPeak) {
            jumpingDown = true; // 开始向下跳
        }else if (frogY <= jumpTarget - frog.height) {
            jumpingDown = true; // 开始向下跳
        }
        // 青蛙向下跳，并检查是否到达目标位置
        if (jumpingDown && frogY >= jumpTarget) {
            frogY = jumpTarget;
            jumpState = 0;
            jumpingDown = false; // 重置向下跳的状态
            jumpdone = true;
            if (!jumpInPlace) {
                leaveLand = true;
            }
            jumpInPlace = false;
           // println("jumptarget: " + jumpTarget);
        }
       // println("frogY: " + frogY);
    }
    
    //限制青蛙在边界内
    if(frogX < 0) {
        frogX = 0;
    } else if (frogX > width - frog.width) {
        frogX = width - frog.width;
    }
    if (jumpTarget <= -frog.height) {
        gameState = STATE_GAME_OVER;
        endGame(DeathReason.DROWNED);
    }
    
    //绘制青蛙
    image(frog, frogX, frogY);
    
    Iterator<Fly> it = flies.iterator();
    while (it.hasNext()) {
        Fly cur_fly = it.next();
        if (dist(frogX, frogY, cur_fly.x, cur_fly.y) < fly.width / 2 + frog.width / 2) {
        //     // 如果碰撞发生，移除蒼蠅并增加分数
            it.remove();
            score++; // 增加得分
        } else {
                if(random(0,2)<1)
                    cur_fly.shake();
                cur_fly.display();
        }
    }
}

void keyPressed() {
    int moveAmount = frog.width / 2; // 根据青蛙的大小调整移动量
    if(keyCode == LEFT) {
        frogX -= moveAmount;
    } if (keyCode == RIGHT) {
        frogX += moveAmount;
    } if (keyCode == ' ' && jumpState == 0 && jumpTarget+frog.height*3/2<height) { // 按空白键并且青蛙不在跳跃中
        onLilyPad = false;
        jumpdone = false;
        jumpState = 3; // 设置一个正值开始向上跳
        jumpTarget += frog.height; // 设置一个新的跳跃目标位置
        jumpInPlace = false;
        // println("jumpTarget: " + jumpTarget);
    } if (keyCode == UP  && jumpState == 0) {
        onLilyPad = false;
        jumpdone = false;
        jumpState = 3; // 设置一个正值开始向上跳
        jumpTarget = frogY; // 设置一个新的跳跃目标位置
        jumpInPlace = true;
    } if (keyCode == BACKSPACE) { 
        debug = !debug;
    } if(keyCode == ENTER & gameState == STATE_START) {
        setup();
        gameState = STATE_GAME; // 开始游戏
    }
}

void keyReleased() {
    if (keyCode == ENTER && (gameState == STATE_GAME_OVER && deathReason == DeathReason.RIP)) {
        while(keyCode != ENTER);
        gameState = STATE_START; // 返回开始界面
        setup(); // 重新初始化游戏
    } if(keyCode == ENTER & gameState == STATE_RULES) {
        gameState = STATE_START; // 返回开始界面
    }
}

// 检测鼠标点击
void mousePressed() {
    if(gameState == STATE_START) {
        if (mouseX >= xStartButton && mouseX <= xEndButton && 
            mouseY >= yStartButton && mouseY <= yEndButton) {
            setup();
            gameState = STATE_GAME; // 开始游戏
        } else if (mouseX >= xRuleButton && mouseX <= xEndRuleButton && 
            mouseY >= yRuleButton && mouseY <= yEndRuleButton) {
            gameState = STATE_RULES; // 显示规则
        }
    } else if (gameState == STATE_RULES) {
        // 如果在规则页面点击了返回按钮
        if (mouseX >= xBackButton && mouseX <= xEndBackButton && 
            mouseY >= yBackButton && mouseY <= yEndBackButton) {
            gameState = STATE_START; // 返回开始界面
        }
    } else if (gameState == STATE_GAME_OVER && deathReason == DeathReason.RIP) {
        if (mouseX >= xRestartButton && mouseX <= xEndRestartButton && 
            mouseY >= yRestartButton && mouseY <= yEndRestartButton) {
            gameState = STATE_START; // 返回开始界面
            setup(); // 重新初始化游戏
        }
    }
}

void endGame(DeathReason reason) {
    deaths++;
    gameState = STATE_GAME_OVER; // 设置游戏状态为游戏结束
    deathReason = reason; // 设置死亡原因
    lastFrameTime = millis(); // 重置计时器
}

void displayGameOverScreen() {
    String message = "";
    switch(deathReason) {
        case DROWNED:
            displayDrownAnimation();
            break;
        case EATEN_BY_SNAKE:
            displaySnakeAnimation();
            break;
        case RIP:
            image(gameOverScreen, 0, 0, width, height);
            image(restartButton, xRestartButton, yRestartButton);
            drawInfo();
            break;
    }
}

void displayDrownAnimation() {
    if(!animationFinished) {
        if (millis() - lastFrameTime > 1000 / animationFrameRate) {
            lastFrameTime = millis(); // 重置计时器
            
            // 加载并显示当前帧
            String imageName = "assets/drown/" + drownAnimationFrame + ".png";
            PImage currentFrame = loadImage(imageName);
            image(currentFrame, 0, 0, width, height);
            drawInfo();
            
            // 准备下一帧
            drownAnimationFrame++;
            if (drownAnimationFrame > drownAnimationEndFrame) {
                animationFinished = true;
                lastFrameTime = millis(); // 重新开始计时
            }
        }
    } else {
        // 动画播放完毕，暂停一秒后显示游戏结束画面
        if (millis() - lastFrameTime > animationPauseTime) {
            deathReason = DeathReason.RIP;
        }
    }
}

void displaySnakeAnimation() {
    if(!animationFinished) {
        if (millis() - lastFrameTime > 1000 / animationFrameRate) {
            lastFrameTime = millis(); // 重置计时器
            
            // 加载并显示当前帧
            String imageName = "assets/snake/" + snakeAnimationFrame + ".png";
            PImage currentFrame = loadImage(imageName);
            image(currentFrame, 0, 0, width, height);
            drawInfo();
            
            // 准备下一帧
            snakeAnimationFrame++;
            if (snakeAnimationFrame > snakeAnimationEndFrame) {
                animationFinished = true;
                lastFrameTime = millis(); // 重新开始计时
            }
        }
    } else {
        // 动画播放完毕，暂停一秒后显示游戏结束画面
        if (millis() - lastFrameTime > animationPauseTime) {
            deathReason = DeathReason.RIP;
        }
    }
}
