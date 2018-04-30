# moho-smpte
Graphical SMPTE Timecode overlay for Moho Animations

### Version ###

*	version: MH12 02.00.000 #480430.01      -- by Sam Cogheil (SimplSam)
*	release: v2.0.0 

### How do I get set up ? ###

* To install:
  
  1. Save the 'SS_SMPTE.lua' file to your computer file system  
  2. In Moho on a VECTOR Layer use Layer Settings and select \[General\] > \[Embedded script file\] and browse to the saved 'SS_SMPTE.lua' file, then click OK  
  3. You will now be presented with a Style dialog for the look and feel of the SMPTE overlay text. Set your preferences and click OK  
  4. On your timeline Press 'Play' -- Sit back and Enjoy the magic!  
    
* Sizing/Orientation:

  - You can set the Size, Position, Orientation of the SMPTE overlay by setting Transforming the SMPTE Layer (Transform Layer tool) @ Frame 0  
  - To increase styling options, place the SMPTE Layer inside a Group layer, and manipulate the Group Layer as usual, or add additional background layers etc.  
  - To edit the current Style (Colour etc.) -- Create a Marker (empty/any text) on the SMPTE Layer at Frame 0. Or simply remove and then re-add the layer script (the current settings will be preserved)  

* Known issues:  

  **Jumpy Text** (Moho buglet): Text will be slightly jumpy (even with a Fixed font) -- unless the SMPTE text is postfixed with a non-whitespace character
  - To work around jumpiness, try adding some spaces and a trailing dot '    .' postfix, and then position the SMPTE Layer such that the dot is offscreen, or enclose with preferred prefix '\[' and postfix '\]' (for example)
  - Alternatively - you can use group/layer masking to hide the postfix character(s)

            
### SPECIAL THANKS to: ###

*	Stan: MOHO Scripting -- http://mohoscripting.com
*	The friendly faces @ Lost Marble Moho forum -- http://www.lostmarble.com/forum/
	

