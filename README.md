Building and Running KSketch2 - Reworked
========================================

**In Flash Builder 4.5 and later**
1. Download the code
2. Start up flash builder, make sure the workbench is at the root of your cloned KSketch2 directory
3. Import these projects - KSketch2_Desktop, KSketch2_Interface, KSketch2_Lib 

Project files should take care of the project references and build path. If not, continue.
4. Set project reference for KSketch2_Interface to refer to KSketch2_Lib.
5. Make sure the libs folder in KSketch2_Interface is refered inside its build path
6. Set project reference for KSketch2_Desktop to refer to KSketch2_Interface.
7. Build and run KSketch2_Desktop.

For building KSketch2_Portable on IOS, You'll need your own ios development and provisioning certificate. 

Overview of project structure.
==============================

Application projects
KSketch_Portable (Access to mobile libraries)
KSketch2_Desktop (Desktop Version with proper mouse and keyboard interactions)
KSketch2_Web (Web version does not have full access to the mouse and has codes that sidestep some browser flash
player issues)

These three projects reference the interface library, KSketch2_Interface. KSketch2_Interface contains components and
classes that are reusable across all 3 application projects. The components however, were created for interactions with
the mouse. Components that are more suitable with mobile and touch interactions will be added to either this project
or a new mobile interface project in the near future.

KSketch2_Library contains codes that directly modifies the data model and does not reference anything else.
