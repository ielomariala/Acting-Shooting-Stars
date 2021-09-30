#lang racket

(require rackunit)
(require rackunit/text-ui)
(require raart)

(require "user_interface.rkt")
(require "runtime-contract.rkt")

; This is a demo of the library featuring a small game

; Reads command line and place fps given in fps variable
(define fps (make-parameter 10.0))

(define parser
  (command-line
   #:usage-help
   "Lauch the game"

   #:once-each
   [("-f" "--fps") FPS
                    "Choose your fps number"
                    (if (flonum? (string->number FPS)) (fps (string->number FPS)) (fps (exact->inexact (string->number FPS))))]

   #:args () (void)))

(define ma (make-moving-area 1 1 18 81))
(define player (make-actor (cons 5 15) 'player collide-player (text ">") '()))
(define generator (create-enemy-generator '(20 . 1) 70 '(5 . 18) 80 ma))
(define scoreboard (create-score-counter '(21 . 45)))
(define asteroid-gen (create-asteroid-generator '(21 . 1) 50 '(2 . 17) 80 ma))
(define UFO-generator (create-UFO-generator '(22 . 1) 180 '(6 . 19) 80 ma))
(define Title (make-actor (cons 0 20) 'title collide-wall (text "Level 1 ... but there's only one level") '()))

(define world (world-add-actor-list (world-add-actor-list (make-world) (append (create-line-fixed-walls 19 80) (create-line-fixed-walls 1 80))) (list player generator scoreboard asteroid-gen UFO-generator Title))) 

(define (garbage-collector w)
  (world-send
   (world-send
    (world-send
     (world-send w (list 'bullet kill-actor-out-area ma))
     (list 'wall kill-actor-out-area ma))
   (list 'enemy kill-actor-out-area ma))
(list 'UFO kill-actor-out-area ma)))

(define runtime (runtime-add-function garbage-collector (make-runtime world 50 (fps))))

(define (test-app count r)
  (if (zero? count) r
      (test-app (sub1 count) (runtime-apply-func r))))

;(test-app 100 runtime)
(start-application runtime)
