// Extension Class for Colour Picker
class MyColorPicker extends ColorPicker {
  
  MyColorPicker(ControlP5 cp5, String theName) {
    super(cp5, cp5.getTab("default"), theName, 0, 0, 100, 10);
  }
 
 // Change size and position of colour sliders
  void setItemSize(int w, int h) {
    sliderRed.setSize(w, h);
    sliderGreen.setSize(w, h);
    sliderBlue.setSize(w, h);
    
    sliderRed.setPosition(0, 0);
    sliderGreen.setPosition(0, h+1);
    sliderBlue.setPosition(0, 2*(h+1));
    
    sliderAlpha.hide();
  }
}
