#lang racket

(require raart)

(require "world-contract.rkt")
(require "actor-contract.rkt")

(provide display-world)

(define (display-world world)
  (letrec(
      [display-list (lambda (list-act)
                     (if (empty? list-act) (blank 50 20) 
                         (place-at (display-list (cdr list-act))
                                   (car (actor-pos (car list-act)))
                                   (cdr (actor-pos (car list-act)))
                                   (actor-sprite (car list-act)))))])      
      (display-list (world-to-list world))))

;(define a0 (make-actor '(0 . 0) do-message 'none (text ">")))
;(define a1 (make-actor '(5 . 5) do-message 'ship (text ">>")))

;(define world1 (world-add-actor (world-add-actor (make-world) a0 ) a1))
;world1
;(display-world world1)