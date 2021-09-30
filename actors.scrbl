 #lang scribble/base

@title{Acting Shooting Star}
This is a scheme language project conducted by ENSEIRB-MATMECA first year students.
Basically, we should create actors capable of transmitting and receiving messages between themselves and the envirement (which is also composed of actors),
updating themselves and maybe even creating other actors. This concept is used in many games such as TERMINAL PHASE coded by C. L. Webber.

@section{Source code}
The src directory has multiple source codes:
    + main.rkt is the main code for the acting model.
    + actor.rkt is the main code for the "actor" structure.
    + types.rkt describes multiple "actor" types such as Walls, Missibles and players.
    + tests.rkt contains the tests we conducted to approve the well-functionning of our program.
    + *-contract.rkt are just contracts. This helped us divide the work between us without creating conflicts, as this is after all a group project.
    + world.rkt is the main code for the "world" structure.
    + runtime.rkt contains all functions usefull for runtime structure and the gameloop
    + actor-action.rkt contains all function which allow player to do things
    + actor-generator.rkt contains some functions to generate particular actors
    + actor-event.rkt contains function to create event in the game

@section{The architecture of the repository}
The "src" directory contains source coded explained in the precedent section.
The "doc" directory contains generated documentation files of our project. You can generate these with the command:
make doc
The "report" directory contains the source code of our report. If you want us to put the pdf version too, please inform us.

@section{Basic use of the library}
To use this library, you just have to create a new project and import the file user_interface.rkt which contains all functions for the creation of a shooting star game.

In this chapter, those functions will be explained and a tutorial will help you to make your first game. You just have to reproduce all actions done in italic. A demo is also defined in the library, lauch with the make command in the terminal. 

@subsection{Actors}
Actors represent all things that can be seen on the screen during the game. They could be ships, or a player but also scoreboards and timers. So well defined actors is important for proper functionning of the game. To help you making your first game, some functions were already implemented.

To begin, you'll need to create an actor, the function make-actor will help you to do that. It requires 5 arguments :

@itemlist[@item{A position which is a pair of two number.}
	  @item{A tag which represent the family of the actor (a player, an enemy, a wall ...). It's a symbol for exemple 'player.}
	  @item{A colliding function which will indicate what the actor has to do when it collides with something.}
	  @item{A sprite/symbol which will represent the actor during the game. It's a raart argument, for exemple (text ">").}
	  @item{And finally an attribute, its utility will depend on the actor. It could be for exemple the life of a player, or the score of a scoreboard. Its type is undefined. In brief, it can be anything.}]

Three others functions were implemented to create specific actors :
@itemlist[@item{make-player : take a position and a life (it's the attribute)}
	  @item{make-enemy : take a position}
	  @item{make-wall : take a position and a life (it's the attribute)}]
 
Below are exemples to create an actor and specific actors :

@centered{
(make-actor '(1 . 2) 'cucumber collide-cucumber (text "I") 1)
Defines a cucumber at the position (1, 2) with 1 life point, collide-cucumber has to be defined (we'll see that in another section), and it will be represented as an I.

(make-player '(1 . 2) 3)
Defines a player with 3 life point at the position (1, 2)

(make-wall '(1 . 2))
Defines a wall at the position (1, 2)
}

@italic{Tutorial : To start, just a player will be created.}
@centered{@italic{(define (make-player '(1 . 2) 3))}}

Actor with the tag player are special actors. It is adviced to have only one actor per game (but you can add others to increase difficulty, nevertheless all of them will have the same controls). Players can be moved with "Z" (up), "Q" (left), "S" (down), "D" (right) and shoot with the space key.

@subsection{World}

Now an actor is created, a world will be needed to animate and draw it. Worlds are containers which organise communication between actors but also let them realise their actions. Communication and animation will be explained later. To create an empty world, you'll need the make-world function. This function needs no arguments. 

@italic{Tutorial : A world will be created.}
@centered{@italic{(define wld (make-world))}}

An actor can be added to a world with the world-add-actor function. It takes a world (in which the player will be added) and a player.

@italic{Tutorial : To add the player actor to the world.}
@centered{@italic{(world-add-actor wld player)}}

A list of actors can also be added to a world with the function world-add-actor-list which takes a world and a list of actors (list act1, act2,...).  

@subsection{Runtime}
So, an actor and a world were created, what do we need now ? A runtime ! The runtime is a structure which organise the proper functionning of the game. It allows players to come back to past actions but also make the world running and draw it. To create a runtime you'll need the make-runtime function. It takes 3 arguments :
@itemlist[@item{A world. It's the initial world of the game.}
	  @item{The maximum number of world a runtime can save (used to go back in the past, it's a memory size). One world is saved each tick.}
	  @item{The fps number of the game. It's a float number}]

@italic{Tutorial : Create a runtime for the game which takes the previous created world. The runtime will have a memory of 50 worlds and 10.0 fps}
@centered{@italic{(define runtime(make-runtime wld 50 10.0))}}

So, once a runtime is correctly defined, the game can be launched ! To do it, just call the start-application function with a runtime as argument.

@italic{Tutorial : Launch the application}
@centered{@italic{(start-application runtime)}}
@italic{It's a little disappointing ... only an actor is shown (the player), it can be moved and throw bullets (ref section actor), but there are no enemy to kill, and the window is totally empty ... Be patient, all thoses functionnalities will be added in the next sections.}

You can stop and unstop the game with "P". To go back to previous actions use the "A" key and launch the game with "P" at the choosen moment. You can go back to the futur with the "E" key. To exit the game, use "T".

@subsection{Moving area}
Before talking about enemy generation in the game, moving-area must be introduced. It is areas in which actors can move and cannot quit. To create a moving-area use the make-moving-area function. It takes 4 arguments : min-x, min-y, max-x and max-y to delimitate a zone.

@italic{Tutorial : Create a moving area for enemy. This is the area in which enemy will move.}
@centered{@italic{(define ma (make-moving-area 0 0 50 50))}}

Moving area can also be used to create a garbage collector which kills all enemies or bullets when they are at the limit of the moving area.

@subsection{Enemies and objects generator}
So, having enemy moving on the screen and throwing bullets could be a good way to increase the fun of your games. For that, some functions were implemented :
@itemlist[@item{A score counter to count the score of a player. It increases with the time. You can add one with the create score-counter function. It takes one argument, its position.}
          @item{An enemy generator, an asteroid generator and an UFO-generator, these three functions generate the announce object and need the same 5 arguments :
	  @itemlist[@item{A position for the generator sprite. It's a pair.}
	            @item{A delay, in each delay tick an entity will spawn. It's a number.}
	  	    @item{A y range (y-min and y-max) in which entiteis can spawn. It's a pair.}
		    @item{A x position, at which entities will spawn. It's a number.}
		    @item{A moving area for the bullet and entities.}]
	For exemple : (define asteroid-gen (create-asteroid-generator '(21 . 1) 50 '(1 . 17) 80 (make-moving-area 0 0 110 110)))}

	@item{A create-line-fixed-walls function which create a fixed line of walls (to define for exemple moving areas). It takes two arguments the x from which the wall begins and the y in which it ends.
}]


@italic{Tutorial : Adds an enemy generator and a scoreboard.}
@centered{@italic{(define generator (create-enemy-generator '(20 . 1) 70 '(3 . 18) 80 ma))
(define scoreboard (create-score-counter '(21 . 45)))}}
@italic{To add them to the world don't forget to use the world-add-actor-list function.}
@centered{@italic{(define wld (world-add-actor-list player generator scoreboard))}}

@subsection{Destroy entities}
Maybe in your game, entities such as bullets or enemies are stacking in the border of your moving area without dispawning. To answer this problem you can use the kill-actor-out-function function. It takes an actor (to destroy) and a moving area (at the border of which the entity is destroyed). For the moment you don't have the knowledge to use it but next chapter will learn you the way to use it. 

@italic{Tutorial : just copy and paste the following lines to end your first game. It creates a garbage-collector which destroy all entities at the border of your moving area.}
@centered{@italic{(define (garbage-collector w)
  (world-send
   (world-send
    (world-send
     (world-send w (list 'bullet kill-actor-out-area ma))
     (list 'wall kill-actor-out-area ma))
   (list 'enemy kill-actor-out-area ma))
(list 'UFO kill-actor-out-area ma)))}}
@italic{You don't have to understand those lines, they will be explained in the next chapter.}
@italic{The way in which the runtime was defined must be changed too.}
@centered{@italic{(define runtime (runtime-add-function garbage-collector (make-runtime world 50 10.0)))}}

@section{Advanced use of the library}
The goal of this chapter is to learn you how make your own functions to create entities, animates them and make them communicating with the world. For that, new functions will be introduced.

@subsection{Messages trame}
It's messages which indicate to actors what they have to do. These messages can be sent by actors but also by the world or the runtime. Actors send messages to the world and it redistributes them to targeted actors. So each of them (actors) has a mailbox in which it stocks messages, waiting to be executed in the next tick. A message is a list which begins by a tag, as specified in the actor section, then there is the function you want to apply and finally all arguments for the function. Watch out, the first argument of the function MUST be an actor but don't put it in the arguments of the message (those functions will be detailled after).

For example : To move right an actor player, the move-right function which takes an actor and a number will be sent to a player. The message will take the following form :
@centered{(list 'player move-right 1)}

@subsection{Action functions}
Action functions are functions which will be send to actors to make them moving for exemple or shooting. They have also a specific format. First, they have to take an actor as first argument. The other parameters of the function (if there are) have no particular restrictions. Then the function must return a list constructed as the exemple below :
@centered{(cons (list act1 act2 ...) (list msg1 msg2 ...))}
in which the actor list represents the actors created by the function and the actor (in paramater of the function), if it is still alive after the execution. The message list represents all the messages the actors resent  to the world after the execution of the function.

Example, construction of an enemy generator function  :
@centered{(define (enemy-generator act new-actor-pos new-actor-life) (cons (list act (make-enemy new-actor-pos new-actor-life)) '())}
This function will return the actor and a new actor generated with the tag 'enemy. No messages are returned after the execution.

Example, construction of boost-bullet function which will boost the speed of the player bullet :
@centered{(define (boost-bullet act x y) (cons (list act) (list (list ('player-bullet move x y)))))}
A message with the fonction move applied with argument x y will be send to the world, which will send it to all actors with the tag 'player-bullet.

Example, contruction of a kill-actor function which kills the actor :
@centered{(define (kill-actor act) (cons '() '()))}
No actor is returned, the actor act is dead, killed or maybe murdered. At least, He's no longer existing in the next world. 

@subsection{Communication actor -> itself}
Actors can communicate between them, but to improve our generator, it could be usefull for an actor to send itself messages. To do that, you just have to use the actor-send or actor-send-list functions which take an actor and a message or a list of message as argument as described in the exemple below.

Example, improve the enemy generator, it will send itself a message with the same function to generate enemy each ticks :
@centered{(define (enemy-generator act new-actor-pos new-actor-life) (cons (list (actor-send act (list 'self enemy-generator new-actor-pos new-actor-life)) (make-enemy new-actor-pos new-actor-life)) '())}
Actor-send and actor-send-list functions return an actor, so they can directly be introduced in the returned actors. The tag of the message will not be interpreted (it could be anything but must be placed at the beginning of the message).

You can send messages to your initial world (before adding it to a runtime) by using the function world-send which takes a world and a message. It returns a world.

The actor structure is defined in all of the library functions and structures chapter (if you want to modify some parameters of an actor in your functions).

@subsection{Runtime functions}
Other particular functions are runtime functions. They only take a world as argument and must return a world. They can be used to send a message to specific actors each tick. To add such a function to a runtime, use the function runtime-add-function which takes a runtime as first argument and a function as second. This function will be executed each tick.

For example, A function which move-left all enemy by 3 cases each tick :
@centered{(define (enemies-move-left wld) (world-send wld (list 'enemy move-left 3)))}

The world structure is defined in all of the library functions and structures chapter (in you want to modify some parameters of a world in your functions).


@subsection{Events}

Using the features of action functions, functions that triggers after a certain amount of time can be created. The structure events was created for easier usage purpose.
It is then possible to create scenario and action functions chains delayed on a period of time. However, events are currently only implemented using actions functions.
Therefore, it can only interact with the world as much as action functions can.

Events can be create using the @italic{(define create-event(trigger action parameters))} function.
The parameter @italic{trigger} is the number of ticks at wich the function @italic{action} will be called with the parameters given in the list of @italic{parameters}.
The @italic{action} must be a function action !

@italic{Tutorial : Creating an enemy with a pattern move}

First, we create some simple events :
@centered{@italic{(define e1 (create-event 10 shoot-backward (list 2 (fg 'green (text "c")) (make-moving-area 0 0 100 100))))}}

@centered{@italic{(define e2 (create-event 20 move (list 1 0 (make-moving-area 0 0 100 100))))}}

The events @italic{e1} makes the actor shoot a bullet that goes to the left after 10 ticks while the event @italic{e2} makes the actor move by 1 to the right after 20 ticks.

We then create our pattern move using the two events and the tick-counter function :

@centered{@italic{
	(define (actor-move-cycle act)
		(cons
        (list (actor-send
            act
            (list 'self tick-counter 0 (list e1 e2))))
        '()
    )
	)
}}

Then we can create our actor and use the function @italic{repeat-call-delayed} to make the actor repeat the pattern move.

@centered{@italic{
(actor-send
            (make-actor (cons x y) 'actor-tutorial collide-function (text "X") '())
            (list 'self repeat-call-delayed 20 actor-move-cycle '())
        )
}}

And it's done, we created an actor that will do the its move pattern every 20 ticks. So this new actor will keep shooting to the left then move to the right until he dies.

@subsection{Collide functions}

Collide functions used in the structure @italic{actor} are actions functions that will be called when the actor is colliding with an other.
Therefore, those functions must output the result in the same format as action functions but must only take two parameters @italic{actor} in input.
It is important to note that those functions should only care about what happens to the first actor given in parametrs as the other actor will manage its own outcome by itself.

@italic{Example : collide of a wall}

@centered{@italic{
	(define (collide-wall actor actor2)
  (cons (list actor) '()))
}}

A wall doesn't care whoever he collides with. He is strong. So the function returns the wall unchanged. 
It is important to note that not returning actor2 here doesn't destroys it. 
Not returning it means that the actor @italic{actor} doesn't create an other actor @italic{actor2} when they collide.

@section{All library functions and structures}

@subsection{Structures}
@subsubsection{Actor structure}
@centered{(struct actor (pos prev-pos mailbox msg-next-tick tag collide sprite attributes))}
@itemlist[@item{pos is the position of the actor this tick, it is a pointed pair : (cons x y).}
	  @item{prev-pos is the position of the actor the previous tick, it is a pointed pair : (cons x y).}
	  @item{mailbox is a list of messages the actor will execute this tick.}
	  @item{msg-next-tick is a list of messages the actor will execute the next tick.}
	  @item{tag is a symbol used to target an actor or a list of actors later on. For example : 'player}
	  @item{collide is a function which tells the actor what to do when a collision occurs. It's the same format as action functions (see section Action functions).}
	  @item{sprite is a raart which design the actor. You create it with the function text generally. For example (text ">").}
	  @item{attributes is a free parameter, you can use it as you want, usefull for life for example.}]

@subsubsection{World structure}
@centered{(struct world (actors mailbox))}
The actors parameter is the list of all actors in a world, sorted by tag. The tag is the first parameter of each under-list.

For example : (list (list 'player a0) (list 'enemy a1 a2) (list 'bullet a3 a4 a5))

The mailbox parameter is a list of all messages sended to the world.

For example : (list msg1 msg2 msg3)

@subsection{Actor functions list}
@itemlist[@item{make-actor(-> pair? symbol? procedure? raart? any/c actor?)

Takes an initial position, a tag, collision function, a raart, and a free argument.

Creates an actor.}
	  @item{make-player(-> pair? any/c actor?)

Takes an initial position and a life number.

Creates a player.}
	  @item{make-enemy(-> pair? any/c actor?)

Takes an initial position and a life number.

Creates an enemy.}
	  @item{make-wall(-> pair? actor?)

Takes an initial position.

Creates a wall.}
	  @item{actor-send(-> actor? list? actor?)

Takes an actor to send the message and a message (Watch out : respect the message format).

Sends a message to an actor.}
	  @item{actor-send-list(-> actor? list? actor?)

Takes an actor to send the messages and a list of messages (Watch out : respect the message format).

Sends a list of message to an actor.}]

@subsection{World functions list}
@itemlist[@item{make-world(-> world?)

Takes nothing.

Creates a world.}
	  @item{world-add-actor(-> world? actor? world?)

Takes a world in which add the actor and an actor.

Adds an actor to a world.}
	  @item{world-add-actor-list(-> world? list? world?)

Takes a world in which add the list of actors and an actor list.

Adds a list of actor to a world.}
	  @item{world-send(-> world? list? world?)

Takes a world to send the message and a message (Watch out : respect the message format).

Sends a message to a world.}]

@subsection{Runtime functions list}
@itemlist[@item{make-runtime(-> world? number? flonum? runtime?)

Takes an initial world, the maximum number of world to save and the number of fps.

Creates a runtime.}
	  @item{runtime-add-function(-> procedure? runtime? runtime?)

Takes a procedure to add to the runtime and a runtime.

Adds a function to a runtime.}
	  @item{start-application(-> runtime? any/c)

Takes a runtime.

Starts the application.}]

@subsection{Generator functions list}
@itemlist[@item{create-enemy-generator(-> pair? number? pair? number? moving-area? actor?)

Takes an initial position for the generator, a spawn delay, the y-range in which entities can spawn, the x position of enemy spawn and a moving area fo the summoned entity.

Generates each delay tick an enemy between the y-range and which will displace itself by the left and shoot bullets.}
	  @item{create-asteroid-generator(-> pair? number? pair? number? moving-area? actor?)

Takes an initial position for the generator, a spawn delay, the y-range in which entities can spawn, the x position of enemy spawn and a moving area for the summoned entity.

Generates each delay tick an asteroid  between the y-range and which will displace itself by the left.}
	  @item{create-UFO-generator(-> pair? number? pair? number? moving-area? actor?)

Takes an initial position for the generator, a spawn delay, the y-range in which entities can spawn, the x position of enemy spawn and a moving area for the summoned entity.

Generates each delay tick an UFO between the y-range and which will displace itself by the left and up and shoot bullets.}
	  @item{create-line-fixed-walls(-> number? number? list?)

Takes an initial x position to start the wall and a final x position to end the wall.

Creates a line of walls between the two position.}
	  @item{create-score-counter(-> pair? actor?)

Takes an initial position.

Creates a score counter and places it at the given position.}]

@subsection{Moving functions list}
@itemlist[@item{make-moving-area(-> number? number? number? number? moving-area?)}
	  @item{move(-> actor? number? number? moving-area? list?)

Takes an actor to move, a x number to increase to the position, a y number to increase to the position, an accessible moving area.

Adds to an actor position x and y while respecting the moving area.}
	  @item{move-right(-> actor? number? moving-area? list?)

Takes an actor to move, a x number to increase to the position, an accessible moving area.

Moves right an actor by x while respecting of the moving area.}
	  @item{move-left(-> actor? number? moving-area? list?)

Takes an actor to move, a x number to increase to the position, an accessible moving area.

Moves left an actor by x while respecting of the moving area.}
	  @item{move-up(-> actor? number? moving-area? list?)

Takes an actor to move, a y number to increase to the position, an accessible moving area.

Moves up an actor by y while respecting of the moving area.}
	  @item{move-down(-> actor? number? moving-area? list?)

Takes an actor to move, a y number to increase to the position, an accessible moving area.

Moves down an actor by y while respecting of the moving area.}
	  @item{move-right-constantly(-> actor? number? moving-area? list?)

Takes an actor to move, a x number to increase to the position, an accessible moving area.

Moves right an actor by x constantly while respecting the moving area.}
	  @item{move-left-constantly(-> actor? number? moving-area? list?)

Takes an actor to move, a x number to increase to the position, an accessible moving area.

Moves left an actor by x constantly in respect of the moving area.}
	  @item{move-up-constantly(-> actor? number? moving-area? list?)

Takes an actor to move, a y number to increase to the position, an accessible moving area.

Moves up an actor by y constantly while respecting the moving area.}
	  @item{move-down-constantly(-> actor? number? moving-area? list?)

Takes an actor to move, a y number to increase to the position, an accessible moving area.

Moves down an actor by y constantly while respecting the moving area.}

	  @item{UFO-move-line(-> actor? number? number? moving-area? list?)

Takes an actor to move, a speed-x, speed-y and a moving zone.

Moves the actor during 6 ticks by speed-x and speed-y.}
	  @item{UFO-move-cycle(-> actor? moving-area? list?)

Takes an actor to move and a moving area for the actor.

Moves the actors in respect of the moving area.}
	  @item{actor-zig-zag(-> actor? moving-area? list?)

Takes an actor and a moving area.

Moves an actor up and down while respecting the moving area.}]

@subsection{Action functions list}
@itemlist[@item{kill-actor-out-area(-> actor? moving-area? list?)

Takes an actor and a moving-area.

Kills the actor if it reaches a border of the moving area.}
	  @item{shoot-forward(-> actor? number? raart? moving-area? list?)

Takes an actor, a shooting rate, a bullet sprite and a moving area for the bullets.

Creates an actor bullet which will displace itself by the right.}
	  @item{shoot-backward(-> actor? number? raart? moving-area? list?)

Takes an actor, a shooting rate, a bullet sprite/symbol and a moving area for the bullets.

Creates an actor bullet which will displace itself by the left.}
	  @item{UFO-shoot-line(-> actor? moving-area? list?)

Takes an actor which shoot and a moving area for the bullets.

Shoots 6 bullets which move themselves by the left.}]

@subsection{Event functions list}
@itemlist[@item{create-event(-> number? procedure? list? event?)

Takes a triggered tick, an action function (see Action function section) and a list of arguments for the function.

Creates an event with the defined parameters.}
	  @item{repreat-call-delayed(-> actor? number? procedure? list? list?)

Takes an actor, a delay, a function to apply and a list of arguments for the function.

Applies the functions the the list of arguments each delay ticks to the actor.}
	  @item{tick-counter(-> actor? number? list? list?)

Takes an actor, the beginning of the counter and a list of events.

Increases the tick and each time an event is reached, applies the event to the actor.}
	  @item{actor-add-score(-> actor? number? list?)

Takes an actor and score.

Adds the score to the actor.}
	  @item{actor-update-scoreboard(-> actor? list?)

Takes an actor.

Updates the sprite of the actor with the new score.}]

@subsection{Collide functions list}
@itemlist[@item{collide-player(-> actor? actor? list?)
Takes two actors.

Determines what happens when the actor given in the first parameter collides with the actor given in the second. The outcome is written for actor that are players.

}

@item{collide-ennemy(-> actor? actor? list?)

Takes two actors.

Determines what happens when the actor given in the first parameter collides with the actor given in the second. The outcome is written for actor that are ennemies.
}


@item{collide-wall(-> actor? actor? list?)
Takes two actors.

Determines what happens when the actor given in the first parameter collides with the actor given in the second. The outcome is written for actor that are walls.
}
]
