# Cymatica

## What is this?

Cymatica is a work-in-progress music player/visualizer, built with Processing and the libraries (in the most recent working version) [Minim](https://code.compartmental.net/tools/minim/) and [ControlP5](https://github.com/sojamo/controlp5).
Due to these libraries (at least atm) no longer updating, I am working on migrating it to [Beads](http://www.beadsproject.net/) and [G4P](http://www.lagers.org.uk/g4p/).

Right now, the planned features are displayed in individual sketches, with two different main sketches.
This structure is because of my workflow/processing's general system for sketches.
Think of the non-mains as tesing grounds where ideas will be tested, explored, and perfected.
The main sketches will then be updated with the completed aspects.
Upon this, the offshoot sketch will be deleted.

Right now, there are 4 sketches:

- Cymatica (The version built with Minim and Controlp5)
- Cymaticav3 (A version attempting to use Python's pyqt6)
- Cymatica V4 (The most recent version, using Beads and hoping to get Qt working with Java.)
- Spotify Test (A test of using spotify data for visualizers)

To come:

- Arrays (Another visualizer idea)
- Live audio (Allowing real time input from mic to be used)

## How do I install?

As of now, the only actually built version is the OG Cymatica, which is available on [Itch](https://iddude.itch.io/cymatica).
If you want to mess with the sketches themselves, you need to hava the latest Java (alongside processing) to view and run the pde files.
Once you have these, you can download or clone to see the individual sketches.

## How do I contribute?

If you are willing to contribute, thank you very much!
I'm the only person working on this right now, and help/tips/advice are appreciated.
Either way, fork and then clone the repository.
Your next steps depend on what you want to do with it.

### Making improvements to existing code:

This would mean tweaking/correcting the actual versions of Cymatica.
If you would like to contribute this way, make your changes to Cymatica.pde or Cymaticav2.pde.
Make sure to document changes _very_ well, and submit a detailed pull request explaining what you changed and why.
I'll decide whether to approve the pull request from there.

### Adding a feature

This would entail you coming up with a visualizer, or maybe some visual effect, or something of that sort.
It also is something that is likely not yet fully completed.
In this case, create a new sketch folder and write the code for your feature there in a way that it can stand alone.
Make sure to include relevant data files in your commits.
When you finish, submit a pr, and I'll review!
