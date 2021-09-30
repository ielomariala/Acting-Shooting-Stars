#lang racket
(require "actor-contract.rkt")
(require "world-contract.rkt")
(require "types.rkt")

(provide coeff-dir-pos collision-with-act collisions collision-aux are-colliding?)
                                   
(define (coeff-dir-pos act)
  (if (eq? (car (actor-pos act)) (car (actor-prev-pos act))) "inf"
  (/(- (cdr (actor-pos act))
       (cdr (actor-prev-pos act)))
    (- (car (actor-pos act))
       (car (actor-prev-pos act))))))
  
;;check if actors act 1 and act 2 are colliding
(define (are-colliding? act1 act2)                                                        ;collide if :
  (or (equal? (actor-pos act1) (actor-pos act2))                                          ;  -at the same position 
      (and                                                                                
       (or (not (eq? (car (actor-pos act1)) (cdr (actor-pos act1))))                      ;  -act1 or act2 immobile
           (not (eq? (car (actor-pos act2)) (cdr (actor-pos act2)))))
       (not (eq? (coeff-dir-pos act1) (coeff-dir-pos act2)))                              ;  -act1's and act2's trajectory are not parallel
       (<= (* (- (* (- (car(actor-pos act1)) (car(actor-prev-pos act1)))                  ; and: the trajectory lines doesn't cross on act1's trajectory
                    (- (cdr (actor-pos act2)) (cdr (actor-prev-pos act1))))
                 (* (- (cdr (actor-pos act1)) (cdr (actor-prev-pos act1)))
                    (- (car (actor-pos act2)) (car (actor-prev-pos act1)))))
              (- (* (- (car(actor-pos act1)) (car(actor-prev-pos act1)))
                    (- (cdr (actor-prev-pos act2)) (cdr (actor-prev-pos act1))))
                 (* (- (cdr (actor-pos act1)) (cdr (actor-prev-pos act1)))
                    (- (car (actor-prev-pos act2)) (car (actor-prev-pos act1))))))
           0)
       (<= (* (- (* (- (car(actor-pos act2)) (car(actor-prev-pos act2)))                 ; and: the trajectory lines doesn't cross on act2's trajectory
                    (- (cdr (actor-pos act1)) (cdr (actor-prev-pos act2))))
                 (* (- (cdr (actor-pos act2)) (cdr (actor-prev-pos act2)))
                    (- (car (actor-pos act1)) (car (actor-prev-pos act2)))))
              (- (* (- (car(actor-pos act2)) (car(actor-prev-pos act2)))
                    (- (cdr (actor-prev-pos act1)) (cdr (actor-prev-pos act2))))
                 (* (- (cdr (actor-pos act2)) (cdr (actor-prev-pos act2)))
                    (- (car (actor-prev-pos act1)) (car (actor-prev-pos act2))))))
           0))))


;;return actor with the message collide if it collide with an actor from the list list-actors
(define (collision-with-act actor list-actors)
  (cond
    [(empty? list-actors) actor]
    [(are-colliding? actor (car list-actors))
     (actor-send actor (cons (actor-tag actor) (list (actor-collide actor) (car list-actors))))] ;;envoie du message collide
    [else (collision-with-act actor (cdr list-actors))]))


(define (collision-aux list-actors-prev list-actors-next wld)
  (if (empty? list-actors-next) wld
      (collision-aux (append list-actors-prev (list (car list-actors-next)))
                     (cdr list-actors-next)
                     (world-add-actor wld (collision-with-act (car list-actors-next)
                                                              (append list-actors-prev
                                                                      (cdr list-actors-next)))))))

;;;;;;;;utiliser begin pour check les erreurs
;; return a world where all the actors who collide have the message "collide" with the arguments
(define (collisions wld)
  (collision-aux '() (world-to-list wld) (make-world)))
  
 

