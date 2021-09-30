#lang racket

(require raart)

(require "actor-contract.rkt")
(require "world-contract.rkt")
(require "raart-contract.rkt")
(provide collide-player collide-ennemy collide-wall invincibility)


(provide make-player make-enemy make-wall)
(provide collide-player collide-ennemy collide-wall invincibility)

; Creates a player
(define (make-player pos life)
  (make-actor pos 'player collide-player (text ">") life))

; Creates a wall
(define (make-wall pos)
  (make-actor pos 'wall collide-wall (text "#") 'invincible))

;Creates an enemy
(define (make-enemy pos life)
  (make-actor pos 'enemy collide-ennemy (text "<") life))

(define (inc_attribute act n)
  (actor (actor-pos act) (actor-prev-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (+ (actor-attributes act) n)))

(define (change-attributes act att)
  (actor (actor-pos act) (actor-prev-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) att))
  
(define (invincibility act ticks lifes)
  (if (zero? ticks) (cons (list (change-attributes act lifes)) '())
      (cons '(actor-send act (cons (actor-tag act) (list invincibility (sub1 ticks) life))) '())))


(define (collide-player act actor2)
  (cond
    [(eq? (actor-attributes act) 'invincible) (cons (list act) '())]
    [(= (actor-attributes act) 1) (cons '() '())]
    [else (cons (list (actor-send
                       (actor '(1 . 25) '(1 . 25) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) 'invincible)
                       (cons (actor-tag act) (list invincibility 10 (sub1 (actor-attributes act)))))) '())]))
     
(define (collide-ennemy act actor2)
  (if (= (actor-attributes act) 1) (cons '() '())
      (cons (list (actor (actor-pos act) (actor-prev-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (sub1 (actor-attributes act)))) '())))


(define (collide-wall act actor2)
  (cons (list act) '()))



