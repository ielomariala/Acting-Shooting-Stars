#lang racket 

(require raart)
(require "actor-contract.rkt")
(require "types.rkt")

(provide (struct-out event))
(provide create-event repeat-call-delayed tick-counter)
(provide actor-add-score actor-update-scoreboard)

;; The function action will be called at trigger ticks with its parameters
(struct event(trigger action parameters))

(define (create-event trigger action parameters)
    (event trigger action parameters)
)

;; calls the function func with arguments args after delay ticks
;; This function should be use in messages
;; Example : 
;; (list 'self repeat-call-delayed 50 generate-asteroid (list (random 1 17) 80))
;; This message will make the actor containing it to call generate-asteroid with the parameters (random 1 17) 80 after 50 ticks
(define (repeat-call-delayed act delay func args)
    (cons
        (list
         (actor-send
            (actor-send
                act 
                (list 'called-from-repeat-call-delayed tick-counter 0 (list (event 0 func args))))
            (list 'self tick-counter 0 (list (event delay repeat-call-delayed (list delay func args))))
        ))
        '()
    )
)

(define (tick-counter act tick-count events)
    (if (null? events) 
        (cons
            (list act)
            '()
        )
        (if (= (event-trigger (car events)) tick-count)
            (apply (event-action (car events)) 
                (actor-send act (list (actor-tag act) tick-counter (add1 tick-count) (cdr events)))
                (event-parameters (car events)))
            (cons
                (list (actor-send act (list (actor-tag act) tick-counter (add1 tick-count) events)))
                '()
            )
        )   
    )
)

(define (actor-add-score act value)
    (cons
        (list (actor (actor-location act) (actor-prev-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (+ (actor-attributes act) value)))
        '()
    )
)

(define (actor-update-scoreboard act)
    (cons
        (list (actor-send 
            (actor 
                (actor-location act) (actor-prev-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act)
                (text (string-append "score : " (string-append (number->string (actor-attributes act))) " pts"))
                (actor-attributes act))
            (list 'self actor-update-scoreboard)
            )
        )
        (list (list (actor-tag act) actor-add-score 1))
    )
)

