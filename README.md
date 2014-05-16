Getting Started with KSketch2 Development
=========================================

Software You Will Need
----------------------

1. Install the GitHub client for [Windows](http://windows.github.com/) or [Mac](http://mac.github.com/).
1. Install [Adobe Flash Builder Premium 4.7](http://www.adobe.com/sea/products/flash-builder.html) (referred to below as "FB").
1. Install the Adobe AIR SDK 13 (Instructions adapted from http://forum.starling-framework.org/topic/fb47-issues)
    1. How to get this SDK
        * Download it from http://helpx.adobe.com/air/kb/archived-air-sdk-version.html
            1. Get both versions of the SDK
                1. Wtihout Compiler: "Adobe AIR 13 SDK downloads" (Shold be "AdobeAIRSDK")
                1. With Compiler: "Adobe AIR 13 SDK and compiler downloads" (Should be "AIRSDK_Compiler")
        * Or get it from one of the ksketch2 team members
    1. Overlay the SDK Without Compiler on FB's AIR 3.6 Directory
        * On Windows:
            1. Navigate to C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.7\sdks
            1. Unzip the contents of AdobeAIRSDK to a temporary folder "AIR13"
            1. Make a copy of the directory 4.6.0 and name it 4.6.0_AIR13
            1. Overlay AIR13 on Flex 4.6.0 by dragging the contents of the AIR13 directory into the 4.6.0 directory. 
                1. Make sure you select “Copy and Replace” when Windows asks and click the box at the bottom to apply all.
        * On Mac:                 
            1. Navigate to /Applications/Adobe Flash Builder 4.7/sdks
            1. Unpack the contents of AdobeAIRSDK to a temporary folder AIR13
                1. Create the "AIR13" directory and copy the SDK file (AdobeAIRSDK.tbz2) into that folder
                1. Navigate to /Applications/Adobe Flash Builder 4.7/sdks/AIR13 in a terminal window
                1. "tar jxvf AdobeAIRSDK.tbz2"
                    * If you have trouble overwriting files due to file permissions, try this command:
                        * "sudo tar jxvf AdobeAIRSDK.tbz2"
                1. Delete the orinial archive file (AdobeAIRSDK.tbz2).
            1. Make a copy of the directory 4.6.0 and name it 4.6.0_AIR13
            1. Overlay AIR13 on Flex 4.6.0 by dragging the contents of the AIR13 directory into the 4.6.0 directory. 
                1. In the terminal, navigate to /Applications/Adobe Flash Builder 4.7/sdks
                1. "ditto AIR13 4.6.0_AIR13"
    1. Configure Flash Builder to use the AIR 13 SDK by default
        1. Close Flash Builder (if it was open), and Open it again
        1. Go to (menu) Flash Builder->Preferences->Flash Builder->Installd Flex SDKs->Add…
        1. Navigate to the 4.6.0_AIR13 directory created earlier click OK. 
        1. Name the SDK "Flex 4.6.0 (AIR 13)" and click OK.
        1. Click the check box in the Installed SDKs dialogue box to make it the default SDK in Flash Builder.
        1. Click OK
    1. Update the AIR SDK used by FlashBuilder while debugging
        1. Navigate to FlashBuilder's compiler folder
            * On Windows: C:\Program Files (x86)\Adobe\Adobe Flash Builder 4.7\eclipse\plugins\com.adobe.flash.compiler_4.7.0.349722
            * On Mac: /Applications/Adobe Flash Builder 4.7/eclipse/plugins/com.adobe.flash.compiler_4.7.0.349722
        1. Rename the "AIRSDK" folder to "AIRSDK-original"
        1. Unpack the contents of the SDK With Compiler (AIRSDK_Compiler) to a folder called "AIRSDK"
            * Use unpacking instructions similar to those found above for "Overlay the SDK Without Compiler on the AIR 13 Directory"


Building and Running
--------------------
1. Clone the repository "richardcd73/ksketch2"
1. Launch FB and go to File->Switch Workspace->Other
    1. Choose the cloned ksketch2 folder
1. Import projects into FlashBuilder
    1. Right-click on Package Explorere->Import->General->Existing Projects into Workspace (Next)
    1. Choose "Select root directory" and browse to cloned ksketch2 folder (Finish)
    1. In menu select Project->Clean (This makes a clean build of all projects)
    1. Window->Show View->Problems
        1. "Cannot create HTML wrapper. Right-click here to recreate folder html-template"
            1. This is useful for debugging, but we aren't saving any of it, so we haven't checked into repository
            1. Right-click -> Generate HTML templates
        1. "unable to open '...ksketch2/KSKApp_Web/libs'
            1. GitHub doesn't sync empty folders, but Flash Builder needs these empty folders
1. Test your Installation
    1. In Package Explorer select KSKApp_Web and click "Debug"
        * You may need to install the debug version of the Flash Player (11.6 or higher)
    1. In Package Explorer select KSKApp_AIR and click "Debug"
        1. The "Debugging Configurations" window should appear
            * Recommended settings
                * Launch Method: On AIR Simulator
                    * Target Platform: Google Android 
                        * Device: Android: Samsung Galaxy Tab 10.1
                    * Target Platform: Apple iOS
                        * Device: iOS: Apple iPad
                * Launch Method: On Device
                    * Target Platform: Google Android 
                        * Launch Method: On Device
                        * Plug in device before running debugger
                        * May need to let debugger install Adobe Air
                    * Target Platform: Apple iOS
                        * Launch Method: On Device
                        * Packaging method: Fast 
                            * Avoid Standard (takes 15 minutes)
                            * If you see an error: "Packaging settings have not yet been configured"
                                1. Click "Configure"
                                1. Choose "Digital Signature" tab
                                1. Set Certificate
                                    1. Convert certificates to "p12" format needed by Flash Builder
                                        1. see http://help.adobe.com/en_US/flashbuilder/using/WSe4e4b720da9dedb5-2e7310a1136ab7c1811-7fee.html#WSe4e4b720da9dedb5-2e7310a1136ab7c1811-7fec
                                        1. use Dropbox:PlaySketch/Releases/Ksketch.developerprofile
                                    1. Save p12 to Dropbox
                                1. Set Provisioning file to Dropbox:PlaySketch/Releases/Ksketch.mobileprovision  
                        * Choose debugging method: Debug via USB


Overview of project structure
=============================


Packages and special objects
----------------------------

* Computation and storage packages in "sg.edu.smu.ksketch2"
    * model
        * objects: object representations
        * data_structures: low level structures used by objects
    * events: things that extend flash.events.Event
    * operators: *** objects that create operations
        * operations: objects that can go on the undo or redo stack
    * utils (those involving computation and storgage)
    * KSketch2: facade class for manipuating a model
* Display packages in "sg.edu.smu.ksketch2"
    * canvas: main canvas component
    * controls: every top-level interface control that is not the main canvas 
        * components: all visible controls
            * popup: all pop-up menus
            * timeBar: the time control
            * transformWidget: the object manipultor and associated context menu
        * imageInput: view for the mobile camera
        * interactioncontrol: *** refreshes app in response to events and updates from child components and model (desktop and mobile)
        * interactors: handlers for gesture input events
            * draw: handlers for draw gestures
            * transitions: handlers for trananslate, rotate, scale, etc.
            * widgetstates: Different appearances for widgets
    * imageEditing: image processing view
    * view: graphic representations of model objects and data
        * objects: graphic representations of KObject subclasses
    * utils: (those involving display) 
* Mobile packages (KSketch_Portable top-level)
    * views: top-level interface classes for mobile
        * canvas: main editing view
            * components: helper classes for canvas
                * popup: 
                * timeBar
                * transformWidget
            * interactioncontrol: simple IInteractionControl that handles only refreshes and undo/redo
            * interactors: handlers for gesture input events (mobile only)
                * widget: states for the object manipulator
        * document: choose a document view (also handles i/o)
            * previewer: simple ksketch player
            * scrollerColumn: list of available documents 
        * imageEditing:  
    * utils


Projects
--------

* KSKApp_Web
    * Top level project that runs in web the Flash Player in web browsers on desktops

* KSKApp_Air 
    * Top level project that runs in Adobe AIR on desktops, Android, or iOS

* KSKInterface
    * Canvas components
    * Classes from utils and view
    * Packages (in sg.edu.smu.ksketch2)
        * canvas
        * controls
            * components
                * popup
                * timeBar
                * transformWidget
            * imageInput
            * interactioncontrol
            * interactors
                * draw
                * transitions
                * widgetstates
        * imageEditing
        * view
            * objects
        * utils 
    * Dependencies
        * flash.*
        * mx.*
        * spark.*
        * leelib.util.flvEncoder.*
        * com.coreyoneil.collision
        * org.gestouch.*
        * Anything in KSKLibrary

* KSKLibrary 
    * Classes that do computation and data storage. (Avoids classes that deal directly with display.)
    * Packages (in sg.edu.smu.ksketch2)
        * model
            * objects
            * data_structures
        * events
        * operators
            * operations
        * utils 
    * Dependencies
        * flash.*
        * sg.edu.smu.ksketch2.model.*
        * sg.edu.smu.ksketch2.operators
        * sg.edu.smu.ksketch2.events
        * sg.edu.smu.ksketch2.utls (only parts within KSKLibrary)

        * Exceptions:
            * classes that use mx.utils.Base64Decoder & Base64Encoder
                * sg.edu.smu.ksketch2.model.objects.KImage
            * classes that use mx.utils.StringUtil.trim()
                * sg.edu.smu.ksketch2.model.objects.KStroke 
                * sg.edu.smu.ksketch2.model.data_structures
                * sg.edu.smu.ksketch2.model.KSceneGraph
            * classes that depend on sg.edu.smu.ksketch2.KSketch2
                * sg.edu.smu.ksketch2.operators.KSingleReferenceFrameOperator (static constants and variables)

* CollisionDetectionKit_v15 
    * Used in tap selection
    * http://code.google.com/p/collisiondetectionkit/
    * MIT License    
    * Unmodified
    * Packages
        * com.coreyoneil.collision
    * Dependencies
        * flash.*
        * mx.*
        * spark.*

* FLV Encoder 
    * Used in FLV export
    * https://github.com/zeropointnine/leelib
    * http://www.zeropointnine.com/blog/updated-flv-encoder-alchem/
    * Creative Commons Attribution 3.0 License (http://creativecommons.org/licenses/by/3.0/)
    * Unmodified
    * Packages
        * leelib.util.flvEncoder.*
    * Dependencies
        * flash.*
        * mx.*
        * spark.*

* Gestouch 
    * Used for multi-touch gestures in mobile
    * https://github.com/fljot/Gestouch
    * MIT License
    * Unmodified
    * Packages
        * org.gestouch.*
    * Dependencies
        * flash.*
        * mx.*
        * spark.*


Rules to observe
================
1. Don't sync ".metadata", as it contains personal project/workspace preferences
