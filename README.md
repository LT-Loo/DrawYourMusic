## About Draw Your Music

Draw Your Music is an interactive visualisation software that transforms drawings into music. Each line drawn is converted into a musical note. The tool features hand movement detection, enabling users to adjust the audio speed and volume through gestures.

## Key Features

### Note Customisation Based On Line Characteristics

| Note Property | Line Characteristic | Explanation |
| :---: | :---: | --- |
| Note | Y-coordinate of its starting point | The sketch board is divided into 12 sections, each representing a musical note from C to B. Note is assigned to a line if the staring point lies within its corresponding section. |
| Pitch | Thickness | The thicker the line, the lower the pitch. |
| ADSR Effect | Colour & Length | The attack time (A), sustain level (S) and release time (R) of the note are influenced by the RGB values in the colour code, whereas the decay or sustain time (D) is affected by the length of line. |

### Audio Interaction via Hand Movement
Users can adjust the audio speed and volume by moving their hands closer or away from the camera lens.

| Audio Property | Controlled By |
| :---: | --- |
| Volume |  Hand on RIGHT screen |
| Speed | Hand on LEFT screen |

## Technologies Used
- Language: Processing
- Packages: 
    1. Processing Sound Library (Envelope) - For ADSR effect
    2. Deep Vision Library (YOLO Network) - For hand movement detection

## Software Requirement
Processing (https://processing.org/download)

## Developer
Loo<br>
loo.workspace@gmail.com