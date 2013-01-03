ksketch2
========

Building KSketch2

Flash Builder Project settings for the projects in KSketch2- reworked_KSketch2 are included in the repository.
Just import them into flash builder.

Overview of project structure.

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
