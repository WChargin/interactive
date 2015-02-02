int m = 2;
int particleCount = 500;
float k = 2 * PI * m;
float omega = PI * m;
float A = 0.1 / omega * PI;

float t = 0;
float dt = 1 / 30;

boolean leftOpen = false;
boolean rightOpen = true;

void recalculateParameters()
{
    A = 0.1 / omega * PI;
}

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
            return 2 * A * Math.sin(k * x0) * Math.cos(omega * t);
        }
        else
        {
            float multiplier = this.direction == Direction.RIGHT ? 1 : -1;
            return A * Math.sin(k * x0 - multiplier * omega * t);
        }
    }

    public void draw()
    {
        drawNodes();
        drawParticles();
        drawBody();
    }

    public void drawBody()
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

    public void drawNodes()
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

        int mm = m / 2;

        // Nodes
        for (int i = 1; i <= mm; i++)
        {
            float x = this.xmin + (i / (mm + 1)) * this.width;
            float strength = exp(-Math.pow((x - mouseX) * lambda, 2) * 1);
            stroke(0, 0, 255, 255 * strength);
            line(x, this.ymin + offset, x, this.ymax - offset);
        }

        // Antinodes
        for (int i = 0; i <= mm; i++)
        {
            float x = this.xmin + ((i + 0.5) / (mm + 1)) * this.width;
            float strength = exp(-Math.pow((x - mouseX) * lambda, 2) * 1);
            stroke(255, 0, 0, 255 * strength);
            line(x, this.ymin + offset, x, this.ymax - offset);
        }
    }

    public void drawParticles()
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
                    line(x0, y, x, y);
                    fill(0, 0, 0, 255 * 0.5);
                    noStroke();
                }
            }
            ellipse(x, y, r, r);
        }
    }
}

Tube first, second, standing;
Tube tubes[];

void setup()
{
    size(600, 400);

    float tubeWidth = width * 0.75;
    float xmin = width * 0.1;
    float xmax = width * 0.6;
    first = new Tube(xmin, xmax, height * 0.1, height * 0.3, Direction.RIGHT);
    second = new Tube(xmin, xmax, height * 0.4, height * 0.6, Direction.LEFT);
    standing = new Tube(xmin, xmax, height * 0.7, height * 0.9, Direction.STANDING);
    tubes = { first, second, standing };
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
    stroke(0, 0, 0, 255 / 4);
    strokeWeight(1);
    noFill();
    rect(0, 0, width - 1, height - 1);
    for (Tube tube : tubes)
    {
        tube.draw();
    }
    t += dt;
}

// vim: syn=java ft=java
