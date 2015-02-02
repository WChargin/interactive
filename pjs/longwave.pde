int m = 3;
int particleCount = 500;
float k = PI * m;
float omega = 0.5 * PI * m;
float A = 0.1 / omega * PI;

float t = 0;
float dt = 1 / 30;

boolean leftOpen = false;
boolean rightOpen = true;

void recalculateParameters()
{
    A = 0.1 / omega * PI;
}

float graphXMin;
float graphXMax;
float graphXMid;
float graphWidth;

// Pseudo-enum
final class Direction
{
    public static final Direction LEFT = new Direction();
    public static final Direction RIGHT = new Direction();
    public static final Direction STANDING = new Direction();
    private Direction() {}
}

class Particle
{
    float x;
    float y;

    public Particle(float x, float y)
    {
        this.x = x;
        this.y = y;
    }
    public Particle()
    {
        this(Math.random(), Math.random());
    }
}

class Tube
{
    private float xmin;
    private float xmax;
    private float xmid;
    private float width;
    private float ymin;
    private float ymax;
    private float ymid;
    private float height;

    private float openRadius;
    private Direction direction;

    private Particle[] particles;

    public Tube(float xmin, float xmax, float ymin, float ymax, Direction dir)
    {
        this.xmin = xmin;
        this.xmax = xmax;
        this.xmid = (xmin + xmax) / 2;
        this.width = xmax - xmin;
        this.ymin = ymin;
        this.ymax = ymax;
        this.ymid = (ymin + ymax) / 2;
        this.height = ymax - ymin;
        this.openRadius = height * 0.5;

        this.direction = dir;

        this.particles = new Particle[particleCount];
        for (int i = 0; i < particles.length; i++)
        {
            particles[i] = new Particle();
        }
    }

    public float calculateDisplacement(float x0)
    {
        if (this.direction == Direction.STANDING)
        {
            if (leftOpen && rightOpen)
            {
                return 2 * A * Math.sin(k * x0 + PI / 2) * Math.cos(omega * t);
            }
            else if (!leftOpen && !rightOpen)
            {
                return 2 * A * Math.sin(k * x0) * Math.cos(omega * t);
            }
            else
            {
                // Half-open
                if (rightOpen)
                {
                    return 2 * A * Math.sin(k * x0 / 2) * Math.cos(omega * t);
                }
                else
                {
                    return 2 * A * Math.sin(k * x0 / 2 + PI / 2) * Math.cos(omega * t);
                }
            }
        }
        else
        {
            float multiplier = this.direction == Direction.RIGHT ? 1 : -1;
            float dphi = 0;
            if (leftOpen && rightOpen)
            {
                dphi = PI / 2;
            }
            else if (leftOpen || rightOpen)
            {
                // Half-open
                if (leftOpen)
                {
                    dphi = PI / 2;
                }
                return A * Math.sin(k * x0 / 2 - multiplier * omega * t + dphi);
            }
            return A * Math.sin(k * x0 - multiplier * omega * t + dphi);
        }
    }

    public void draw()
    {
        drawNodes();
        drawParticles();
        drawBody();
        drawGraph();
    }

    private void drawBody()
    {
        // Reset drawing parameters
        fill(255, 255, 255);

        // Top and bottom boundaries
        strokeWeight(1);
        stroke(0, 0, 0);
        line(this.xmin, this.ymin, this.xmax, this.ymin);
        line(this.xmin, this.ymax, this.xmax, this.ymax);

        stroke(0, 0, 0);
        float boundaryWidth = 4;
        float halfWidth = boundaryWidth / 2;

        strokeCap(PROJECT);
        strokeWeight(boundaryWidth);
        if (leftOpen)
        {
            arc(this.xmin + halfWidth, this.ymid, this.openRadius, this.height - boundaryWidth, -PI / 2, PI / 2);
        }
        else
        {
            line(this.xmin + halfWidth, this.ymin + boundaryWidth / 2, this.xmin + halfWidth, this.ymax - boundaryWidth / 2);
        }
        if (rightOpen)
        {
            arc(this.xmax - halfWidth, this.ymid, this.openRadius, this.height - boundaryWidth, PI / 2, 3 * PI / 2);
        }
        else
        {
            line(this.xmax - halfWidth, this.ymin + halfWidth, this.xmax - halfWidth, this.ymax - halfWidth);
        }
    }

    private void drawParticles()
    {
        noStroke();
        strokeWeight(1);
        float mouseTubeX = (mouseX - this.xmin) / this.width;
        double mouseInTube = (this.ymin <= mouseY && mouseY <= this.ymax && 0 <= mouseTubeX && mouseTubeX <= 1);

        fill(0, 0, 0, 255 * 0.25);
        for (Particle particle : particles)
        {
            float r = 4;
            float x0 = this.xmin + this.width * particle.x;
            float dx = this.width * this.calculateDisplacement(particle.x);
            float x = min(this.xmax - r, max(this.xmin + r, x0 + dx));
            float y = min(this.ymax + r, max(this.ymin + r, this.ymin + this.height * particle.y));
            if (mouseInTube)
            {
                fill(0, 0, 0, 255 * 0.1);
                if (abs(mouseTubeX - particle.x) <= 0.05)
                {
                    stroke(255, 0, 0);
                    noFill();
                    line(max(this.xmin + 3, min(this.xmax - 3, x0)), y, x, y);
                    fill(0, 0, 0, 255 * 0.5);
                    noStroke();
                }
            }
            ellipse(x, y, r, r);
        }
    }

    private void drawNodes()
    {
        if (this.direction != Direction.STANDING)
        {
            return;
        }

        if (this.ymin > mouseY || mouseY > this.ymax)
        {
            return;
        }

        float weight = 4;
        float offset = weight / 2 + 1;
        strokeWeight(weight);
        noFill();

        float lambda = 1 / 10;

        int mm = (leftOpen == rightOpen) ? m : m / 2;

        // Nodes
        for (int i = 1; i < mm; i++)
        {
            float x = this.xmin + (i / mm) * this.width;
            float strength = exp(-Math.pow((x - mouseX) * lambda, 2) * 1);
            stroke(leftOpen ? 255 : 0, 0, leftOpen ? 0 : 255, 255 * strength);
            line(x, this.ymin + offset, x, this.ymax - offset);
        }

        // Antinodes
        for (int i = 1; i <= mm; i++)
        {
            float x = this.xmin + ((i - 0.5) / mm) * this.width;
            float strength = exp(-Math.pow((x - mouseX) * lambda, 2) * 1);
            stroke(leftOpen ? 0 : 255, 0, leftOpen ? 255 : 0, 255 * strength);
            line(x, this.ymin + offset, x, this.ymax - offset);
        }
    }

    private void drawGraph()
    {
        stroke(0, 0, 0, 255 * 0.5);
        strokeWeight(1);
        fill(0, 0, 0, 255 * 0.5);

        line(graphXMin, this.ymin, graphXMin, this.ymax);
        line(graphXMin, this.ymid, graphXMax, this.ymid);
        line(graphXMin, this.ymin, graphXMin - 2, this.ymin);
        text("2A", graphXMin - textWidth("2A") - 4, this.ymin + textAscent("2A") / 2);

        float ay = this.ymin + this.height / 4;
        line(graphXMin, ay, graphXMin - 2, ay);
        text("A", graphXMin - textWidth("A") - 4, ay + textAscent("A") / 2);

        text("Displacement", graphXMin + 4, this.ymin);
        text("Position", graphXMax - textWidth("Position"), this.ymid - 4);
        noFill();

        float tubeX = (mouseX - this.xmin) / this.width;
        if (0 <= tubeX && tubeX <= 1 && this.ymin <= mouseY && mouseY <= this.ymax)
        {
            float graphX = graphXMin + tubeX * graphWidth;
            line(graphX, this.ymin, graphX, this.ymax);
        }

        stroke(0, 0, 0);
        strokeWeight(1.5);
        noFill();
        beginShape();
        int samples = floor(graphWidth / 4);
        for (int i = 0; i <= samples; i++)
        {
            float x = i / samples;
            float y = this.calculateDisplacement(x);
            float xpos = graphXMin + graphWidth * x;
            float ypos = this.ymid - y / A * this.height / 4;

            if (i == 0)
            {
                vertex(xpos, ypos);
            }
            curveVertex(xpos, ypos);
            if (i == samples)
            {
                vertex(xpos, ypos);
            }
        }
        endShape();
    }

}

Tube first, second, standing;
Tube tubes[];

void setup()
{
    size(600, 400);

    float tubeWidth = width * 0.75;
    float xmin = width * 0.05;
    float xmax = width * 0.55;
    first = new Tube(xmin, xmax, height * 0.05, height * 0.25, Direction.RIGHT);
    second = new Tube(xmin, xmax, height * 0.30, height * 0.50, Direction.LEFT);
    standing = new Tube(xmin, xmax, height * 0.55, height * 0.75, Direction.STANDING);
    tubes = { first, second, standing };

    graphXMin = width * 0.60;
    graphXMax = width * 0.95;
    graphXMid = (graphXMin + graphXMax) / 2;
    graphWidth = graphXMax - graphXMin;

    frameRate(1 / dt);
}

void mouseClicked()
{
    boolean toggleLeft = false;
    boolean toggleRight = false;
    for (Tube tube : tubes)
    {
        if (tube.ymin <= mouseY && mouseY <= tube.ymax)
        {
            // Mouse within y bounds of tube
            if (tube.xmin <= mouseX && mouseX <= tube.xmin + tube.openRadius)
            {
                toggleLeft = true;
            }
            if (tube.xmax - tube.openRadius <= mouseX && mouseX <= tube.xmax)
            {
                toggleRight = true;
            }
        }
    }
    if (toggleLeft)
    {
        leftOpen = !leftOpen;
    }
    if (toggleRight)
    {
        rightOpen = !rightOpen;
    }
}

void draw()
{
    recalculateParameters();
    background(255, 255, 255);
    for (Tube tube : tubes)
    {
        tube.draw();
    }
    t += dt;
}

// vim: syn=java ft=java
