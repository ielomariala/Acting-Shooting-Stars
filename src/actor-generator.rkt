#lang racket

(require raart)

(require "actor-contract.rkt")
(require "actor-event-contract.rkt")
(require "actor-action-contract.rkt")
(require "types.rkt")

(provide create-enemy-generator create-score-counter create-perma-wall create-line-fixed-walls create-asteroid-generator create-UFO-generator)
(provide create-wall-moving-left infinite-ennemy-generator generate-asteroid generate-UFO)

;; event-action
(define (infinite-ennemy-generator act delay x-range y ma)
    (cons

    ; ajouter le nouvel ennemy et le spawn du prochain enemy...
     (list act
        (actor-send-list (make-actor (cons (random (car x-range) (cdr x-range)) y) 'enemy collide-ennemy (fg 'red (text "<")) 1)
        (list (list 'self repeat-call-delayed 25 shoot-backward (list 2 (fg 'green (text "c")) ma))
              (list 'self repeat-call-delayed 60 actor-zig-zag (list ma))
              (list 'enemy move-left-constantly 1 ma)))
     )
     (list (list 'Enemygenerator tick-counter 0 (list (event delay infinite-ennemy-generator (list delay x-range y ma)))))
    )
)

(define (create-score-counter pos)
    (actor-send
        (make-actor pos 'score-counter collide-wall (text "score") 0)
        (list 'self actor-update-scoreboard)
    )
)

(define (generate-asteroid act x-range y ma)
    (let ([x (random (car x-range) (cdr x-range))])
    (cons
        (list act (create-wall-moving-left (cons x y) ma) (create-wall-moving-left (cons (add1 x) y) ma)
              (create-wall-moving-left (cons x (add1 y)) ma) (create-wall-moving-left (cons (add1 x) (add1 y)) ma))
        '()
    ))
)

(define (create-asteroid-generator pos delay x-range y ma)
    (actor-send (make-actor pos 'Asteroidsgenerator collide-wall (text "AsteroidsGenerator") 'invincible)
    (list 'self repeat-call-delayed delay generate-asteroid (list x-range y ma))
    ;(list 'self tick-counter 0 (list (event 50 generate-asteroid (list (random 1 17) 80))))
    )
)

(define (generate-UFO act x-range y ma)
    (let ([x (random (car x-range) (cdr x-range))])
    (cons
        (list act (actor-send
            (make-actor (cons x y) 'UFO collide-ennemy (fg 'brmagenta (text "]H>")) 2)
            (list 'self repeat-call-delayed 60 UFO-move-cycle (list ma))
        ))
    '()
    ))
)

(define (create-UFO-generator pos delay x-range y ma)
    (actor-send (make-actor pos 'UFOGenerator collide-wall (text "UFOgenerator") 'invincible)
    (list 'self repeat-call-delayed delay generate-UFO (list x-range y ma))
    ;(list 'self tick-counter 0 (list (event 50 generate-asteroid (list (random 1 17) 80))))
    )
)

(define (create-enemy-generator pos delay x-range y ma)
    (actor-send (make-actor pos 'Enemygenerator collide-wall (text "EnemyGenerator") 'invincible)
    (list 'self tick-counter 0 (list (event delay infinite-ennemy-generator (list delay x-range y ma))))
    )
)

(define (create-perma-wall pos ma)
    (actor-send (make-actor pos 'permawall collide-wall (text "W") 'invincible)
    (list (list 'self actor-perma-wall-generator ma))
    )
)

(define (actor-perma-wall-generator act ma)
    (let ([pos (actor-pos act)])
        (cons
            (list (actor-send act (list 'self actor-perma-wall-generator)) (create-wall-moving-left (cons (car pos) (- (cdr pos) 1)) ma))
            '()
        )
    )
)

(define (create-line-fixed-walls x-at y-from)
    (if (> 0 y-from)
        '()    
        (cons (make-actor (cons x-at y-from) 'perma-wall collide-wall (text "#") 'invincible) (create-line-fixed-walls x-at (sub1 y-from)))
    )
)

(define (create-wall-moving-left pos ma)
    (actor-send
        (make-actor pos 'wall collide-wall (fg 'brblack (text "#")) 'invincible)
        (list 'self move-left-constantly 1 ma)
    )
)

