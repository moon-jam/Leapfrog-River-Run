int x, y;
int speedx, speedy;
color faceColor;

void setup() {
    size(800, 600);
    x = width / 2;
    y = height / 2;
    speedx = floor(random(-20, 20));
    speedy = floor(random(-20, 20));
    faceColor = color(random(255), random(255), random(255));
}

void draw() {
    background(255);

    fill(faceColor);
    ellipse(x + 100, y + 100, 200, 200);

    fill(255, 0, 0);
    ellipse(x + 75, y + 75, 25, 25);
    ellipse(x + 125, y + 75, 25, 25);

    fill(255);
    ellipse(x + 80, y + 75, 10, 10);
    ellipse(x + 130, y + 75, 10, 10);

    noFill();
    stroke(0);
    strokeWeight(5);
    arc(x + 100, y + 125, 100, 75, 0, PI);

    stroke(0);
    strokeWeight(10);
    line(x + 50, y + 50, x + 75, y + 65);
    line(x + 150, y + 50, x + 125, y + 65);

    x = x + speedx;
    if (x < 0 || x > width - 200) {
        speedx = abs(speedx) * (x > width - 200 ? -1 : 1);
        faceColor = color(random(255), random(255), random(255));
        speedx = abs(speedx)/speedx * floor(random(1, 20));
        speedy = abs(speedy)/speedy * floor(random(1, 20));
        x = x + 2 * speedx;
    }

    y = y + speedy;
    if (y < 0 || y > height - 200) {
        speedy = abs(speedy) * (y > height - 200 ? -1 : 1);
        faceColor = color(random(255), random(255), random(255));
        speedx = abs(speedx)/speedx * floor(random(1, 20));
        speedy = abs(speedy)/speedy * floor(random(1, 20));
        y = y + 2 * speedy;
    }

    println(x, y);
}