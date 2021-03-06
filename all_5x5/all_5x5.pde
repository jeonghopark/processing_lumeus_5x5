// ~/Projects/LED_Fassade/opc/openpixelcontrol-master(master*) » make && ./bin/gl_server_avelux_5x5 -l ./layouts/freespace_avelux_5x5.json

// ~/Projects/LED_Fassade/opc/openpixelcontrol-master(master*) » ./bin/gl_server_avelux_5x5 -l ./layouts/freespace_avelux_5x5.json

import controlP5.*;

import ddf.minim.analysis.*;
import ddf.minim.*;

import processing.video.*;
import gab.opencv.*;

Minim minim;
AudioInput in;
FFT fftLin;

Capture camera;
OpenCV opencv;

ControlP5 cp5;
ControlP5 cp5Sub;

ListBox sceneList;

OPC opc[];
Fenster fenster[];
Typo typo;

PImage dot;

int runPixelLineX;
int widthSimulationWindows;

PFont font;

int stringIndexNum;

color colorMousePoint;
color colorAll;
color colorOneWindow;
color colorFadeDrawing;
color colorMovingLine;
color colorLongText;
color colorKeyBoard;

int speedLine;
int widthLine;
int speedLongText;
float AudioInputVol;

boolean allOnOff = false;
boolean colorRandomKeyboardOnOff = false;
boolean cameraOnOff = false;
float colorContrast;
float inputContrast;
int inputBrightness;


color[] pixelColors;


//----------------------------------------------------------------------------
void setup() {

    // important!!!
    size(1000, 700);

    minim = new Minim(this);
    in = minim.getLineIn();
    fftLin = new FFT( in.bufferSize(), in.sampleRate() );
    fftLin.linAverages( 5 );

    camera = new Capture(this, 160, 120);
    // println(camera.list());
    camera.start();

    opencv = new OpenCV(this, 160, 120);
    opencv.useColor(RGB);

    cp5 = new ControlP5(this);
    setupControlP5();
    cp5Sub = new ControlP5(this);

    font = createFont("verdana.ttf", 20);
    textFont(font);
    textSize(20);

    widthSimulationWindows = 500;

    dot = loadImage("color-dot.png");

    opcSetup("Simualtion");  // "Simulation" or ""

    typo = new Typo();

    fenster = new Fenster[25];
    int _index = 0;
    int _wWidth = widthSimulationWindows / 6;
    int _wHeight = height / 7;
    for (int j = 0; j < 5; j++) {
        for (int i = 0; i < 5; i++) {
            fenster[_index] = new Fenster(i * _wWidth, j * _wHeight, _wWidth, _wHeight);
            _index++;
        }
    }

    runPixelLineX = 0;
    stringIndexNum = 0;

    pixelColors = new color[25];

}


//----------------------------------------------------------------------------
void draw() {
    background(0);

    pushStyle();
    fill(30);
    rect(width * 0.5, 0, width * 0.5, height);
    popStyle();

    pushMatrix();
    for (int i = 0; i < fenster.length; i++) {
        fenster[i].basicFrameDisplay();
    }
    popMatrix();


    switch (int(sceneList.getValue())) {
    case 0:
        basicMouseInteraction();
        break;

    case 1:
        allWindows();
        break;

    case 2:
        basicClickDrawing();
        break;

    case 3:
        basicFadeDrawing();
        break;

    case 4:
        basicLineMoving();
        break;

    case 5:
        if (frameCount % speedLongText == 0) {
            stringIndexNum++;
        }
        stringView("LUMEUS!");
        break;

    case 6:
        audioSpectrum();
        break;

    case 7:
        typo.alphaDisplay(key, colorKeyBoard);
        break;

    case 8:
        if (frameCount % speedLongText == 0) {
            stringIndexNum++;
        }
        stringView("Christopher, Jealous, Jeniffer, JeongHo, Johann, Julian, Kim, Marius, Marc, Matthias, Max");
        break;

    case 9:
        if (cameraOnOff) {
            cameraPixelCapture();
            cameraView();
            cameraPixelView();
        }
        break;
    }

    pushStyle();
    fill(255);
    String _f = nfs(frameRate, 2, 1);
    text("FPS : " + _f, 770, 17);
    popStyle();
}



//----------------------------------------------------------------------------
void audioSpectrum() {

    pushStyle();
    noStroke();
    fftLin.forward( in.mix );

    for (int i = 0; i <  fftLin.avgSize(); i++) {

        float _spectrumV = abs(fftLin.getBand(i)) * AudioInputVol;

        if (int(_spectrumV) == 1) {
            fenster[20 + i].display(color(0, 255, 0));
        } else if (int(_spectrumV) == 2) {
            fenster[20 + i].display(color(0, 255, 0));
            fenster[15 + i].display(color(0, 255, 0));
        } else if (int(_spectrumV) == 3) {
            fenster[20 + i].display(color(0, 255, 0));
            fenster[15 + i].display(color(0, 255, 0));
            fenster[10 + i].display(color(0, 255, 0));
        } else if (int(_spectrumV) == 4) {
            fenster[20 + i].display(color(0, 255, 0));
            fenster[15 + i].display(color(0, 255, 0));
            fenster[10 + i].display(color(0, 255, 0));
            fenster[5 + i].display(color(255, 255, 0));
        } else if (int(_spectrumV) == 5) {
            fenster[20 + i].display(color(0, 255, 0));
            fenster[15 + i].display(color(0, 255, 0));
            fenster[10 + i].display(color(0, 255, 0));
            fenster[5 + i].display(color(255, 255, 0));
            fenster[0 + i].display(color(255, 0, 0));
        }

    }
    popStyle();

}



//----------------------------------------------------------------------------
void stringView(String str) {

    char _c = str.charAt(stringIndexNum % str.length());
    typo.alphaDisplay(_c, colorLongText);

}



//----------------------------------------------------------------------------
void basicMouseInteraction() {

    pushMatrix();

    fill(colorMousePoint);

    float dotSize = 50;
    // image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
    if (mouseX < width * 0.5 ) {
        rect(mouseX - dotSize / 2, mouseY - dotSize / 2, dotSize, dotSize);
    }
    popMatrix();

}



//----------------------------------------------------------------------------
void allWindows() {

    pushMatrix();
    pushStyle();
    if (allOnOff) {
        for (int i = 0; i < fenster.length; i++) {
            fenster[i].display(colorAll);
        }
    }
    popStyle();
    popMatrix();

}



//----------------------------------------------------------------------------
void basicClickDrawing() {

    pushMatrix();
    for (int i = 0; i < fenster.length; i++) {
        fenster[i].clickDisplay();
        fenster[i].basicFrameDisplay();
    }
    popMatrix();

}



//----------------------------------------------------------------------------
void basicFadeDrawing() {

    pushMatrix();
    for (int i = 0; i < fenster.length; i++) {
        float distX = dist(mouseX, 0, fenster[i].xMid, 0);
        float distY = dist(0, mouseY, 0, fenster[i].yMid);
        if (distX < fenster[i].width * 0.5 && distY < fenster[i].height * 0.5) {
            fenster[i].onoff = true;
        } else {
            fenster[i].onoff = false;
        }

        fenster[i].fadeDisplay();
        fenster[i].basicFrameDisplay();
    }
    popMatrix();

}



//----------------------------------------------------------------------------
void basicLineMoving() {

    pushStyle();
    runPixelLineX = runPixelLineX + speedLine;
    if (runPixelLineX > widthSimulationWindows) {
        runPixelLineX = 0;
    } else if (runPixelLineX < 0) {
        runPixelLineX = widthSimulationWindows;
    }
    stroke(colorMovingLine);
    strokeWeight(widthLine);
    line(runPixelLineX, 0, runPixelLineX, height);
    for (int i = 0; i < 5; i++) {
    }
    popStyle();

}



//----------------------------------------------------------------------------
void cameraView() {
    float _size = 1.0;
    image(camera, 770, 400, 160, 120);
}



//----------------------------------------------------------------------------
void cameraPixelCapture() {

    int pixelSize = 20;
    int rectSize = pixelSize;

    int _offSetPixelNum = 30 + 10 * 160;

    opencv.loadImage(camera);
    opencv.brightness(inputBrightness);
    opencv.contrast(inputContrast);


    PImage _imageBuff = opencv.getSnapshot();    

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            int index = i + j * 5;
            int pixelIndex = i * rectSize + j * rectSize * 160 + _offSetPixelNum;

            int _r = 0;
            int _g = 0;
            int _b = 0;

            for (int k = 0; k < rectSize * rectSize; k++) {
                int _pixelSumIndex = pixelIndex + k % 20 + k / 20 * 160;
                _r += int(red(_imageBuff.pixels[_pixelSumIndex]));
                _g += int(green(_imageBuff.pixels[_pixelSumIndex]));
                _b += int(blue(_imageBuff.pixels[_pixelSumIndex]));
            }

            pixelColors[index] = color(_r / 400.0 * colorContrast, _g / 400.0 * colorContrast, _b / 400.0 * colorContrast);
        }
    }


}


//----------------------------------------------------------------------------
void cameraPixelView() {

    int pixelSize = 20;
    int rectSize = pixelSize;
    pushStyle();
    noFill();
    stroke(0, 255, 0);

    float _size = 1.0;
    int _captureXPos = 770 + int(160 * _size / 2.0 - rectSize * 5 / 2.0);
    int _captureYPos = 400 + int(120 * _size / 2.0 - rectSize * 5 / 2.0);

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            int index = i + j * 5;
            rect(i * rectSize + _captureXPos, j * rectSize + _captureYPos, rectSize, rectSize);
        }
    }

    popStyle();


    pushMatrix();
    pushStyle();
    translate(770, 280);
    if (pixelColors.length > 0) {
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                int index = i + j * 5;
                color _c = pixelColors[index];
                fill(_c);
                rect(i * rectSize, j * rectSize, rectSize, rectSize);
            }
        }
    }
    popStyle();
    popMatrix();

    for (int i = 0; i < fenster.length; i++) {
        color _c = pixelColors[i];
        fenster[i].display(_c);
    }

}


//----------------------------------------------------------------------------
void captureEvent(Capture c) {
    if (cameraOnOff) {
        c.read();
    }
}



//----------------------------------------------------------------------------
void mousePressed() {

    for (int i = 0; i < fenster.length; i++) {
        float distX = dist(mouseX, 0, fenster[i].xMid, 0);
        float distY = dist(0, mouseY, 0, fenster[i].yMid);
        if (distX < fenster[i].width * 0.5 && distY < fenster[i].height * 0.5 && mousePressed) {
            fenster[i].onoff = !fenster[i].onoff;
            fenster[i].oneColor = colorOneWindow;
        }
    }

}


//----------------------------------------------------------------------------
void keyPressed() {
    
    if (colorRandomKeyboardOnOff) {
        colorKeyBoard = color(random(255), random(255), random(255));
    }

}


//----------------------------------------------------------------------------
void opcSetup(String s) {

    opc = new OPC[5];

    if (s == "Simualtion") {
        // für Simualtion
        for (int i = 0; i < opc.length; i++) {
            opc[i] = new OPC(this, "127.0.0.1", 7890 + i);
        }
    } else {

        // 5 x 5
        opc[4] = new OPC(this, "192.168.1.230", 7890);
        opc[3] = new OPC(this, "192.168.1.231", 7890);
        opc[2] = new OPC(this, "192.168.1.232", 7890);
        opc[1] = new OPC(this, "192.168.1.233", 7890);
        opc[0] = new OPC(this, "192.168.1.234", 7890);

    }

    // for (int i=0; i<5; i++) {
    //     for (int j=0; j<5; j++) {
    //         opc[i].ledStrip(0 + 60 * j, 60, width / 12 * (1 + j), height / 7 * (7 - (i + 1)), 1.0, 0, true);
    //     }
    // }

    opc[4].ledStrip(0, 60, width / 12 * 1, height / 7 * 2, 1.0, 0, true);
    opc[4].ledStrip(60, 60, width / 12 * 2, height / 7 * 2, 1.0, 0, true);
    opc[4].ledStrip(120, 60, width / 12 * 3, height / 7 * 2, 1.0, 0, false);
    opc[4].ledStrip(180, 60, width / 12 * 4, height / 7 * 2, 1.0, 0, false);
    opc[4].ledStrip(240, 60, width / 12 * 5, height / 7 * 2, 1.0, 0, false);
    opc[3].ledStrip(0, 60, width / 12 * 1, height / 7 * 3, 1.0, 0, true);
    opc[3].ledStrip(60, 60, width / 12 * 2, height / 7 * 3, 1.0, 0, true);
    opc[3].ledStrip(120, 60, width / 12 * 3, height / 7 * 3, 1.0, 0, false);
    opc[3].ledStrip(180, 60, width / 12 * 4, height / 7 * 3, 1.0, 0, false);
    opc[3].ledStrip(240, 60, width / 12 * 5, height / 7 * 3, 1.0, 0, false);
    opc[2].ledStrip(0, 60, width / 12 * 1, height / 7 * 4, 1.0, 0, true);
    opc[2].ledStrip(60, 60, width / 12 * 2, height / 7 * 4, 1.0, 0, true);
    opc[2].ledStrip(120, 60, width / 12 * 3, height / 7 * 4, 1.0, 0, false);
    opc[2].ledStrip(180, 60, width / 12 * 4, height / 7 * 4, 1.0, 0, false);
    opc[2].ledStrip(240, 60, width / 12 * 5, height / 7 * 4, 1.0, 0, false);
    opc[1].ledStrip(0, 60, width / 12 * 1, height / 7 * 5, 1.0, 0, true);
    opc[1].ledStrip(60, 60, width / 12 * 2, height / 7 * 5, 1.0, 0, true);
    opc[1].ledStrip(120, 60, width / 12 * 3, height / 7 * 5, 1.0, 0, false);
    opc[1].ledStrip(180, 60, width / 12 * 4, height / 7 * 5, 1.0, 0, false);
    opc[1].ledStrip(240, 60, width / 12 * 5, height / 7 * 5, 1.0, 0, false);
    opc[0].ledStrip(0, 60, width / 12 * 1, height / 7 * 6, 1.0, 0, true);
    opc[0].ledStrip(60, 60, width / 12 * 2, height / 7 * 6, 1.0, 0, true);
    opc[0].ledStrip(120, 60, width / 12 * 3, height / 7 * 6, 1.0, 0, false);
    opc[0].ledStrip(180, 60, width / 12 * 4, height / 7 * 6, 1.0, 0, false);
    opc[0].ledStrip(240, 60, width / 12 * 5, height / 7 * 6, 1.0, 0, false);

}



//----------------------------------------------------------------------------
void setupControlP5() {

    PFont pfont = createFont("Arial", 11, true);
    ControlFont cfont = new ControlFont(pfont, 11);

    int _sceneNum = 10;
    sceneList = cp5.addListBox("Scene List")
                .setPosition(530, 30)
                .setSize(210, 20 + 20 * _sceneNum)
                .setFont(cfont)
                .setItemHeight(20)
                .setBarHeight(20)
                .setColorBackground(color(60))
                .setColorActive(color(220, 0, 0))
                .setColorForeground(color(120, 220, 120))
                ;

    sceneList.setValue(-1);
    sceneList.getCaptionLabel().toUpperCase(true);
    sceneList.getCaptionLabel().setHeight(20);
    // sceneList.getCaptionLabel().setColor(0xffff0000);
    sceneList.addItem("Mouse Interaction", 0);
    sceneList.addItem("All On Off", 1);
    sceneList.addItem("Click Drawing", 2);
    sceneList.addItem("Fade Drawing", 3);
    sceneList.addItem("Line Moving", 4);
    sceneList.addItem("LUMEUS!", 5);
    sceneList.addItem("Live Audio", 6);
    sceneList.addItem("KeyboardInput", 7);
    sceneList.addItem("Credit", 8);
    sceneList.addItem("Camera Input", 9);

}


//----------------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {

    if (theEvent.getName() == "Scene List") {

        int _index = (int)(theEvent.getController().getValue());

        switch (_index) {
        case 0:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addColorWheel("colorMousePoint" , 500 + 270 , 30 , 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 1:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addToggle("allOnOff")
            .setPosition(500 + 270, 30)
            .setSize(50, 50)
            ;
            cp5Sub.addColorWheel("colorAll" , 500 + 270 , 30 + 70 , 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 2:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addColorWheel("colorOneWindow" , 500 + 270 , 30 , 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 3:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addColorWheel("colorFadeDrawing" , 500 + 270 , 30 , 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 4:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addSlider("speedLine")
            .setMin(-5)
            .setMax(5)
            .setValue(1)
            .setPosition(500 + 270, 30)
            .setSize(150, 22)
            ;
            cp5Sub.addSlider("widthLine")
            .setMin(1)
            .setMax(100)
            .setValue(4)
            .setPosition(500 + 270, 60)
            .setSize(150, 22)
            ;
            cp5Sub.addColorWheel("colorMovingLine" , 500 + 270 , 30 + 70, 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 5:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addSlider("speedLongText")
            .setMin(2)
            .setMax(120)
            .setValue(20)
            .setPosition(500 + 270, 30)
            .setSize(150, 22)
            ;
            cp5Sub.addColorWheel("colorLongText" , 500 + 270 , 30 + 70, 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 6:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addSlider("AudioInputVol")
            .setMin(0)
            .setMax(10)
            .setValue(2)
            .setPosition(500 + 270, 30)
            .setSize(150, 22)
            ;
            break;

        case 7:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addToggle("colorRandomKeyboardOnOff")
            .setPosition(500 + 270, 30)
            .setSize(50, 50)
            ;
            cp5Sub.addColorWheel("colorKeyBoard" , 500 + 270 , 30 + 70, 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 8:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addSlider("speedLongText")
            .setMin(2)
            .setMax(120)
            .setValue(20)
            .setPosition(500 + 270, 30)
            .setSize(150, 22)
            ;
            cp5Sub.addColorWheel("colorLongText" , 500 + 270 , 30 + 70, 200 ).
            setRGB(color(128, 0, 255));
            break;

        case 9:
            cp5Sub.remove(this);
            cp5Sub = new ControlP5(this);
            cp5Sub.addToggle("cameraOnOff")
            .setPosition(500 + 270, 30)
            .setSize(50, 50)
            ;
            cp5Sub.addSlider("colorContrast")
            .setMin(0)
            .setMax(4)
            .setValue(1)
            .setPosition(500 + 270, 30 + 70)
            .setSize(150, 22)
            ;
            cp5Sub.addSlider("inputContrast")
            .setMin(0)
            .setMax(4)
            .setValue(1)
            .setPosition(500 + 270, 30 * 2 + 70)
            .setSize(150, 22)
            ;
            cp5Sub.addSlider("inputBrightness")
            .setMin(-255)
            .setMax(255)
            .setValue(0)
            .setPosition(500 + 270, 30 * 3 + 70)
            .setSize(150, 22)
            ;
            break;

        }

    }

}
