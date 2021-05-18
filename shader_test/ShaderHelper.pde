public static float RecenterX(float x, int resolutionX){
    return (x - (resolutionX / 2.0)) / (0.1 * resolutionX);
}

public static float RecenterY(float y, int resolutionY){
    return (y - (resolutionY / 2.0)) / (1.6 * resolutionY);
}

public static PVector GetPoint(Camera c, float x, float y, int resolutionX, int resolutionY){
    return PVector.add(c.Forward,PVector.add(PVector.mult(c.Right,(RecenterX(x,resolutionX))),PVector.mult(c.Up,RecenterY(y,resolutionY)))).normalize();
}
