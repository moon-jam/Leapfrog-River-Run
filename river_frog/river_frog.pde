PImage frog; // 青蛙的图像
PImage startScreen; // 开始画面的图像
PImage ruleScreen; // 规则页面的图像
PImage startButton; // 开始按钮图像
PImage ruleButton; // 规则按钮图像
PImage backButton; // 返回按钮图像
PImage restartButton; // 返回按钮图像
PImage lilyPad; // 荷叶的图像
PImage gameOverScreen; // 游戏结束画面图像

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
float frogY_max = 536.0;

// 青蛙的跳跃动画状态
float jumpState = 0; 
float jumpPeak; // 青蛙跳跃的最高点相对位置
float jumpTarget; // 青蛙跳跃的目标Y坐标
boolean jumpingDown = false; // 青蛙是否正在向下跳
boolean jumpdone = false; // 青蛙是否完成跳跃
boolean leaveLand = false; // 青蛙是否已经跳过
boolean jumpInPlace = false; // 青蛙是否在原地跳

int numberOfLilyPads = 40; // 全部荷叶的数量
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
        if (x < -lilyPad.width) x = width;
    }
}
ArrayList<LilyPad>[] lilyRows;
boolean onLilyPad;
LilyPad currentLilyPad;

enum DeathReason {
  DROWNED, 
  EATEN_BY_SNAKE,
  RIP
}
DeathReason deathReason;

int drownAnimationFrame = 61; // 动画帧的开始
int drownAnimationEndFrame = 94; // 动画帧的结束
int drownFrameRate = 8; // 每秒8帧
int frameCountDown = 0; // 帧计数器
boolean animationFinished = false; // 动画是否完成的标记
int animationPauseTime = 1000; // 动画结束后的暂停时间（毫秒）
int lastFrameTime;

boolean debug = false;

float scrollSpeed = 0.4;

float landY;

void setup() {
  size(1120, 630);

    // 加载图像资源
  frog = loadImage("assets/frog.png");
  lilyPad = loadImage("assets/lilyPad.png"); // 加载荷叶图像
  startScreen = loadImage("assets/start_screen.png");
  ruleScreen = loadImage("assets/rule_screen.png");
  gameOverScreen = loadImage("assets/gameover.png");
  startButton = loadImage("assets/start_btn.png");
  ruleButton = loadImage("assets/rule_btn.png");
  backButton = loadImage("assets/back_btn.png");
  restartButton = loadImage("assets/restart_btn.png");

  frog.resize(0, height / 10); // 根据屏幕高度调整青蛙大小
  lilyPad.resize(0, frog.height); // 调整荷叶大小与青蛙高度一致
  startScreen.resize(1120, 630);
  ruleScreen.resize(1120, 630);
  gameOverScreen.resize(1120, 630);
  startButton.resize(0, 70); // 以高度100像素调整开始按钮大小
  ruleButton.resize(0, 70); // 以高度100像素调整规则按钮大小
  backButton.resize(0, 70); // 调整返回按钮大小
  restartButton.resize(0, 90); // 调整重新开始按钮大小

  // 设置开始按钮的坐标
  xStartButton = (width - startButton.width) / 2;
  yStartButton = height - startButton.height * 2 - 25; // 假设按钮位于屏幕中央
  xEndButton = xStartButton + startButton.width;
  yEndButton = yStartButton + startButton.height;
  // 设置规则按钮的坐标
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

  // 初始位置在画面中央
  frogX = width / 2 - frog.width / 2;
  frogY = height / 2 - frog.height / 2;
  jumpTarget = frogY; // 初始跳跃目标就是初始位置
  jumpPeak = frog.height * 5 / 4; // 设置跳跃的最高点相对位置
  jumpdone = false;
  leaveLand = false; 
  jumpInPlace = false;

  // 初始化荷叶的X坐标数组
  lilyRows = new ArrayList[height / frog.height - 1]; // 假设屏幕下半部分是河流
  for (int i = 0; i < lilyRows.length; i++) {
      lilyRows[i] = new ArrayList<LilyPad>();
      float yPosition = (i + 1) * frog.height + height / 2;
      // 对于每一行，我们添加一些荷叶
      for (int j = 0; j < numberOfLilyPads / lilyRows.length; j++) {
          float xPosition = random(width);
          float speed = random(1, 3); // 随机速度
          if (random(100) < 50) speed = -speed; // 随机决定方向
          lilyRows[i].add(new LilyPad(xPosition, yPosition, speed));
      }
  }
  onLilyPad = false;
  currentLilyPad = null;

  drownAnimationFrame = 61;
  animationFinished = false;

  scrollSpeed = 0.4;
  landY = height / 2 + frog.height / 2;
}

void draw() {
  switch (gameState) {
    case STATE_START:
      // 绘制开始画面
      image(startScreen, 0, 0, width, height);
      image(startButton, xStartButton, yStartButton);
      image(ruleButton, xRuleButton, yRuleButton);
      break;
    case STATE_RULES:
      // 绘制规则页面
      image(ruleScreen, 0, 0, width, height);
      image(backButton, xBackButton, yBackButton);
      break;
    case STATE_GAME:
      // 游戏主逻辑
      runGame();
      break;
    case STATE_GAME_OVER:
      if(debug) runGame();
      else
      displayGameOverScreen();
      break;
  }
}

void runGame() {
  // 游戏逻辑
  background(#0D839E);
  if(leaveLand){
    landY -= scrollSpeed; // 河流向上移动
    fill(#86502E);
    rect(0, 0, width, landY); // 绘制青蛙的起始位置
  } else{
    fill(#86502E);
    rect(0, 0, width, landY); // 绘制青蛙的起始位置
  }

  boolean frogIsSafe = false;

  if(leaveLand){
    frogY -= scrollSpeed; // 青蛙向上移动
    jumpTarget -= scrollSpeed; // 跳跃目标向上移动
  }

  // 绘制荷叶
  for (ArrayList<LilyPad> lilyRow : lilyRows) {
    for (LilyPad lily : lilyRow) {
      if(leaveLand)
        lily.y -= scrollSpeed;
      lily.move();
      lily.display();
    }
  }

  float topRowY = lilyRows[0].get(0).y; // 获取顶部荷叶行的Y坐标
  if (topRowY < 0) {
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
  }

  // 检查并更新青蛙是否在荷叶上
  if (leaveLand && jumpdone && !onLilyPad) {
    for (ArrayList<LilyPad> lilyRow : lilyRows) {
      for (LilyPad lily : lilyRow) {
        if (frogX + frog.width > lily.x && frogX < lily.x + lilyPad.width && 
            abs(jumpTarget + frog.height/2 - lily.y)<30) {
          frogIsSafe = true;
          currentLilyPad = lily; // 更新当前荷叶
          onLilyPad = true;
          break;
        }
      }
      if (onLilyPad) {
        break;
      }
    }
    if (!onLilyPad) {
      gameState = STATE_GAME_OVER;
      endGame(DeathReason.DROWNED);
    }
  }

  // 如果青蛙在荷叶上，让青蛙跟随荷叶移动
  if (onLilyPad && currentLilyPad != null) {
    frogIsSafe = true;
    // 青蛙跟随荷叶移动
    frogX += currentLilyPad.speed;

    // 检查荷叶是否要离开屏幕
    if (currentLilyPad.x + lilyPad.width <= 10 || currentLilyPad.x >= width-10) {
      gameState = STATE_GAME_OVER;
      endGame(DeathReason.DROWNED);
    }

    if (frogX + frog.width < currentLilyPad.x-5 || frogX > currentLilyPad.x + lilyPad.width+5) {
      gameState = STATE_GAME_OVER;
      endGame(DeathReason.DROWNED);
    }
  }

  // 跳跃逻辑
  if (jumpState != 0) { // 青蛙不在荷叶上
    jumpdone = false;
    frogY += jumpingDown? jumpState : -jumpState;
    // 青蛙向上跳
    if(!jumpInPlace){
      if (frogY <= jumpTarget - jumpPeak) {
        jumpingDown = true; // 开始向下跳
      }
    } else{
      if (frogY <= jumpTarget - frog.height) {
        jumpingDown = true; // 开始向下跳
      }
    }
    // 青蛙向下跳，并检查是否到达目标位置
    if (jumpingDown && frogY >= jumpTarget) {
      frogY = jumpTarget;
      jumpState = 0;
      jumpingDown = false; // 重置向下跳的状态
      jumpdone = true;
      if(!jumpInPlace){
        leaveLand = true;
      }
      jumpInPlace = false;
      println("jumptarget: " + jumpTarget);
    }
  // println("frogY: " + frogY);
  }

  // 限制青蛙在边界内
  if (frogX < 0) {
    frogX = 0;
  } else if (frogX > width - frog.width) {
    frogX = width - frog.width;
  }

  // 限制青蛙在边界内
  if (jumpingDown && jumpTarget > frogY_max) {
    jumpTarget = frogY_max;
  }

  // 绘制青蛙
  image(frog, frogX, frogY);
}

void keyPressed() {
  int moveAmount = frog.width / 2; // 根据青蛙的大小调整移动量
  if (keyCode == LEFT) {
    frogX -= moveAmount;
  } if (keyCode == RIGHT) {
    frogX += moveAmount;
  } if (keyCode == ' ' && jumpState == 0) { // 按空白键并且青蛙不在跳跃中
    onLilyPad = false;
    jumpdone = false;
    jumpState = 3; // 设置一个正值开始向上跳
    jumpTarget += frog.height; // 设置一个新的跳跃目标位置
    // println("jumpTarget: " + jumpTarget);
  } if (keyCode == UP  && jumpState == 0){
    onLilyPad = false;
    jumpdone = false;
    jumpState = 3; // 设置一个正值开始向上跳
    jumpTarget = frogY; // 设置一个新的跳跃目标位置
    jumpInPlace = true;
  }if (keyCode == BACKSPACE) { 
    debug = true;
  }
}

// 检测鼠标点击
void mousePressed() {
  if (gameState == STATE_START) {
    if (mouseX >= xStartButton && mouseX <= xEndButton &&
        mouseY >= yStartButton && mouseY <= yEndButton) {
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
  gameState = STATE_GAME_OVER; // 设置游戏状态为游戏结束
  deathReason = reason; // 设置死亡原因
  lastFrameTime = millis(); // 重置计时器
}

void displayGameOverScreen() {
  String message = "";
  switch (deathReason) {
    case DROWNED:
      displayDrownAnimation();
      break;
    case EATEN_BY_SNAKE:
      message = "Game Over - Eaten by Snake";
      background(50); // 设定一个暗色背景
      fill(255, 0, 0);
      textSize(48);
      textAlign(CENTER, CENTER);
      text(message, width / 2, height / 2);
      break;
    case RIP:
      image(gameOverScreen, 0, 0, width, height);
      image(restartButton, xRestartButton, yRestartButton);
      break;
  }
}

void displayDrownAnimation() {
  if (!animationFinished) {
    if (millis() - lastFrameTime > 1000 / drownFrameRate) {
      lastFrameTime = millis(); // 重置计时器

      // 加载并显示当前帧
      String imageName = "assets/drown/" + drownAnimationFrame + ".png";
      PImage currentFrame = loadImage(imageName);
      image(currentFrame, 0, 0, width, height);

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
