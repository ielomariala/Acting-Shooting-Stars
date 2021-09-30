# Acting Shooting Stars
**Acting Shooting Stars** is a scheme language project conducted by ENSEIRB-MATMECA first year students.

Basically, we should create actors capable of transmitting and receiving messages between themselves and the environment (which is also composed of actors),updating themselves and maybe even creating other actors. This concept is used in many games such as TERMINAL PHASE coded by C. L. Webber.

## These are the essential commands of this project:
    - make : Opens a window where you can play the game "Acting Shooting Star"
    - make tests : Launchs the tests used to approve our work
    - make doc : Creates an html documentation file in the directory "doc"
    - make clean : Cleans the deposit from unnecessary files

## This deposit contains multiple directories:

    - src : contains all source codes
        - actor.rkt implementing the 'actor' structure.
        - runtime.rkt implementing the 'runtime' structure, which is controling time in the game.
        - world.rkt implementing the 'world' structure, which is controling the environment in the game.
        - main.rkt is the launcher of the game.
        - raart.rkt and luxx.rkt implementing functions which control animation.
        - tests.rkt implementing the tests.

    - doc : contains documentation files, but only after the command "make doc" is executed

    - report : contains source code for files used to create our modest report

The root contains also necessary files such as:
    - actors.scrbl : which is the source file used to create the documentation files.
    - Makefile : makes executing commands easier.
    - StructureSpecs.txt : This text file is a back-up file in case scribble documentation did not work.
    - README.md


## The main contains a small demo of a space invader type of game :
    The game is based on "azerty" keyboard. You might have a bit of trouble playing on a "qwerty" keyboard. We may or may not create a function which changes controls, depending on the remaining time for the project.
    Controls : - move right : q
               - move left : d
               - move up : z
               - move down : s
               - shoot : spacebar
               - Quit the application : t
    
    Level : There is not any enemy present for now.


# This is not Final Version of project


