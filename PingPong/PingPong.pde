int x, y;
int speedx, speedy;
color faceColor;
int paddle1Y, paddle2Y;
int paddleSpeed = 7;
int paddleHeight = 80;
int paddleWidth = 15;
int score1 = 0, score2 = 0;
boolean gameStarted = false;
boolean gameOver = false;
String winner = "";
color paddle1Color = color(255, 0, 0); // Red for Player 1
color paddle2Color = color(0, 0, 255); // Blue for Player 2

void setup() {
    size(800, 600);
    score1 = 0; score2 = 0;
    x = width / 2;
    y = height / 2;
    speedx = floor(random(7, 9));
    speedy = floor(random(-8, 8));
    faceColor = color(random(255), random(255), random(255));
    paddle1Y = height / 2;
    paddle2Y = height / 2;
    speedx = abs(speedx) * ((score1+score2)%2==0 ? 1 : -1);
    if(!gameOver) {
        gameStarted = false;
    }
    gameOver = false;
}

boolean[] keys = new boolean[128];

void keyPressed() {
    if (keyCode == ' ') {
        gameStarted = true;
        if(gameOver) {
            setup();
        }
    }
    keys[keyCode] = true;
}

void keyReleased() {
    keys[keyCode] = false;
}

void draw() {
    if (!gameStarted) {
        drawStartScreen();
        return;
    }
    if (gameOver) {
        drawGameOverScreen();
        return;
    }

    background(255);

    // Draw the score board
    textSize(64);
    textAlign(CENTER);
    fill(0, 102, 153);
    float fixWidth = textWidth(""+score1)-textWidth(""+score2);
    println(fixWidth);
    text(score1 + " | " + score2, (width / 2)-(fixWidth/2), 50);

    // Draw the field lines
    stroke(0);
    for (int i = 70; i < height; i += 20) {
        line(width / 2, i, width / 2, i + 10);
    }
    
    // line(0, 0, width, 0); // Top border
    // line(0, height, width, height); // Bottom border
    // line(0, 0, 0, height); // Left border
    // line(width, 0, width, height); // Right border

    // Draw the face
    fill(faceColor);
    ellipse(x + 25, y + 25, 50, 50);

    // Draw the eyes
    fill(255, 0, 0);
    ellipse(x + 18, y + 18, 6, 6);
    ellipse(x + 31, y + 18, 6, 6);

    // Draw the pupils
    fill(255);
    ellipse(x + 20, y + 18, 2.5, 2.5);
    ellipse(x + 33, y + 18, 2.5, 2.5);

    // Draw the mouth
    noFill();
    stroke(0);
    strokeWeight(1);
    arc(x + 25, y + 31, 25, 18, 0, PI);

    // Draw the eyebrows
    stroke(0);
    strokeWeight(2.5);
    line(x + 12, y + 12, x + 18, y + 16);
    line(x + 37, y + 12, x + 31, y + 16);

    // Draw the paddles
    fill(paddle1Color);
    rect(0, paddle1Y, paddleWidth, paddleHeight);
    fill(paddle2Color);
    rect(width - paddleWidth, paddle2Y, paddleWidth, paddleHeight);

    // Move the face
    x = x + speedx;
    y = y + speedy;

    // Bounce the face off the top and bottom
    if (y < 0 || y > height - 50) {
        speedy *= -1;
        faceColor = color(random(255), random(255), random(255));
    }

    // Bounce the face off the paddles
    if (x < paddleWidth) {
        if (y + 50 > paddle1Y && y < paddle1Y + paddleHeight) {
            speedx *= -1;
            faceColor = color(random(255), random(255), random(255));
        } else {
            score2++;
            reset();
        }
        chg_speedy();
    }

    if (x > width - paddleWidth - 50) {
        if (y + 50 > paddle2Y && y < paddle2Y + paddleHeight) {
            speedx *= -1;
            faceColor = color(random(255), random(255), random(255));
        } else {
            score1++;
            reset();
        }
        chg_speedy();
    }

    // Move the paddles
    if (keys['W'] && paddle1Y > 0) {
    paddle1Y -= paddleSpeed;
    }
    if (keys['S'] && paddle1Y < height - paddleHeight) {
        paddle1Y += paddleSpeed;
    }
    if (keys['O'] && paddle2Y > 0) {
        paddle2Y -= paddleSpeed;
    }
    if (keys['L'] && paddle2Y < height - paddleHeight) {
        paddle2Y += paddleSpeed;
    }

    if (score1 == 25) {
        gameOver = true;
        winner = "Player 1";
    } else if (score2 == 25) {
        gameOver = true;
        winner = "Player 2";
    }
}

void reset() {
    println(score1, score2);
    x = width / 2;
    y = height / 2;
    speedx = floor(random(7, 9));
    speedy = floor(random(-8, 8));
    faceColor = color(random(255), random(255), random(255));
    speedx = abs(speedx) *((score1+score2)%2==0 ? 1 : -1);
}

void chg_speedy(){
    if(abs(speedy) < 1) speedy += random(-2, 2);
    else if(abs(speedy) < 3) speedy += random(-1.5, 1.5);
    else if(abs(speedy) < 5) speedy += random(-1, 1);
    else speedy -= abs(speedy)/speedy * random(0, 0.5);
}

void drawStartScreen() {
    background(255);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("Press Space to Start", width / 2, height / 2 - 100);
    textSize(16);
    text("First to 25 points wins", width / 2, height / 2);
    fill(paddle1Color);
    text("Red paddle is Player 1", width / 2, height / 2 + 50);
    fill(paddle2Color);
    text("Blue paddle is Player 2", width / 2, height / 2 + 100);
}

void drawGameOverScreen() {
    background(255);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(32);
    text(winner + " Wins!", width / 2, height / 2 - 100);
    textSize(16);
    fill(0);
    text("Press Space to Restart", width / 2, height / 2);
    text("First to 25 points wins", width / 2, height / 2 + 50);
    fill(paddle1Color);
    text("Red paddle was Player 1", width / 2, height / 2 + 100);
    fill(paddle2Color);
    text("Blue paddle was Player 2", width / 2, height / 2 + 150);
}