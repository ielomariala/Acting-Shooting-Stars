#lang racket

(require "actor-contract.rkt")
(require "actor-action-contract.rkt")
(require "actor-event-contract.rkt")
(require "actor-generator-contract.rkt")
(require "world-contract.rkt")
(require "runtime-contract.rkt")
(require "collision-contract.rkt")
(require "types.rkt")

(provide (struct-out moving-area))

(provide make-actor actor-send actor-send-list

         make-player make-enemy make-wall
         
         create-enemy-generator create-score-counter create-asteroid-generator create-UFO-generator create-line-fixed-walls
         
         make-world world-add-actor world-add-actor-list world-send

         make-runtime runtime-add-function start-application

         make-moving-area kill-actor-out-area
         move move-right move-left move-down move-up move-right-constantly move-left-constantly move-down-constantly move-up-constantly
         actor-zig-zag shoot-forward shoot-backward
         UFO-move-line UFO-move-cycle UFO-shoot-line

         collide-player collide-ennemy collide-wall
         
         create-event repeat-call-delayed tick-counter
         actor-add-score actor-update-scoreboard
         )