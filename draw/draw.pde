void setup() {
  size(600, 800);
  background(255);
}

void draw() {
  // Draw the face
  fill(255, 255, 0);
  ellipse(300, 400, 400, 400);

  // Draw the eyes
  fill(255, 0, 0);
  ellipse(225, 350, 50, 50);
  ellipse(375, 350, 50, 50);

  // Draw the pupils
  fill(255);
  ellipse(235, 350, 20, 20);
  ellipse(385, 350, 20, 20);

  // Draw the mouth
  noFill();
  stroke(0);
  strokeWeight(5);
  arc(300, 450, 200, 150, 0, PI);

  // Draw the eyebrows
  stroke(0);
  strokeWeight(10); // Increased stroke weight for thicker eyebrows
  line(200, 300, 275, 325);
  line(400, 300, 325, 325);
}