#lang racket

(require raart)

(require "types.rkt")
(require "actor-contract.rkt")
(require "actor-event-contract.rkt")

(provide (struct-out moving-area))
(provide kill-actor-out-area
         move-right-constantly move-left-constantly move-up-constantly move-down-constantly
         make-moving-area move move-right move-left move-up move-down actor-zig-zag
         shoot-forward shoot-backward
         UFO-move-line UFO-move-cycle UFO-shoot-line 
         )

(struct moving-area (min-x min-y max-x max-y))

; Defines a moving-area (a rectangle)
(define (make-moving-area min-x min-y max-x max-y) 
  (moving-area min-x min-y max-x max-y))

; Kills an actor if it goes throught the moving area
(define (kill-actor-out-area act ma)
  (let ([x (car (actor-pos act))]
        [y (cdr (actor-pos act))])
        (if (and (> x (moving-area-min-x ma))
                 (< x (moving-area-max-x ma))
                 (> y (moving-area-min-y ma))
                 (< y (moving-area-max-y ma)))
            (cons (list act) '())
            (cons '() '()))
        ))
  
; Moves the actor act by x and y coordinates according to the format of function used in messages
(define (move act x y ma)
  (cons
   (let ([new-x (+ (car (actor-pos act)) x)]
         [new-y (+ (cdr (actor-pos act)) y)])
     (list (cond [(and (>= new-x (moving-area-min-x ma))
                 (<= new-x (moving-area-max-x ma))
                 (>= new-y (moving-area-min-y ma))
                 (<= new-y (moving-area-max-y ma)))  (actor (cons new-x new-y) (actor-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))]
           [(< new-x (moving-area-min-x ma))        (actor (cons (moving-area-min-x ma) (cdr (actor-pos act))) (actor-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))]
           [(> new-x (moving-area-max-x ma))        (actor (cons (moving-area-max-x ma) (cdr (actor-pos act))) (actor-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))]
           [(< new-y (moving-area-min-y ma))        (actor (cons (car (actor-pos act)) (moving-area-min-y ma)) (actor-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))]
           [(> new-y (moving-area-max-y ma))        (actor (cons (car (actor-pos act)) (moving-area-max-y ma)) (actor-pos act) (actor-mailbox act) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))]
           [else '()] ; kill it if goes negative
           )))
   '()
   ) 
  )

(define (move-right act y ma)
  (move act 0 y ma))

(define (move-left act y ma)
  (move act 0 (- 0 y) ma))

(define (move-up act x ma)
  (move act (- 0 x) 0 ma))

(define (move-down act x ma)
  (move act x 0 ma))

(define (move-right-constantly act y ma)
  (cons (list (actor-send (caar (move-right act y ma)) (list 'self move-right-constantly y ma))) '()))

(define (move-left-constantly act y ma)
  (cons (list (actor-send (caar (move-left act y ma)) (list 'self move-left-constantly y ma))) '()))

(define (move-up-constantly act x ma)
  (cons (list (actor-send (caar (move-up act x ma)) (list 'self move-up-constantly x ma))) '()))

(define (move-down-constantly act x ma)
  (cons (list (actor-send (caar (move-down act x ma)) (list 'self move-down-constantly x ma))) '()))

(define (actor-zig-zag act ma)
    (let ([pos (actor-pos act)])
    (cons
        (list (actor-send
            act
            (list 'self tick-counter 0 (list
                (event 10 move-up (list 1 ma))
                (event 20 move-up (list 1 ma))
                (event 30 move-up (list 1 ma))
                (event 40 move-down (list 1 ma))
                (event 50 move-down (list 1 ma))
                (event 60 move-down (list 1 ma))
            ))))
        '()
    )))

(define (shoot-forward act bullet-speed bullet-sprite bullet-ma)
  (let ([pos (actor-pos act)])
    (cons
     (list act (actor-send (make-actor (cons (car pos) (add1 (cdr pos))) 'bullet (actor-collide act) bullet-sprite (actor-attributes act))
                           (list 'bullet move-right-constantly bullet-speed bullet-ma)))
     '()
    )
  )
)

(define (shoot-backward act bullet-speed bullet-sprite bullet-ma)
  (let ([pos (actor-pos act)])
    (cons
     (list act (actor-send (make-actor (cons (car pos) (sub1 (cdr pos))) 'bullet collide-ennemy bullet-sprite (actor-attributes act))
                           (list 'bullet move-left-constantly bullet-speed bullet-ma)))
     '()
    )
  )
)

(define (UFO-move-line act speed-x speedy ma)
    (cons
        (list (actor-send
            act
            (list 'self tick-counter 0 (list
                (event 10 move (list speed-x speedy ma))
                (event 11 move (list speed-x speedy ma))
                (event 12 move (list speed-x speedy ma))
                (event 13 move (list speed-x speedy ma))
                (event 14 move (list speed-x speedy ma))
                (event 15 move (list speed-x speedy ma))
            ))))
        '()
    )
)

(define (UFO-shoot-line act ma)
    (cons
        (list (actor-send
            act
            (list 'self tick-counter 0 (list
                (event 10 shoot-backward (list 2 (fg 'green (text "c")) ma))
                (event 11 shoot-backward (list 2 (fg 'green (text "c")) ma))
                (event 12 shoot-backward (list 2 (fg 'green (text "c")) ma))
                (event 13 shoot-backward (list 2 (fg 'green (text "c")) ma))
                (event 14 shoot-backward (list 2 (fg 'green (text "c")) ma))
                (event 15 shoot-backward (list 2 (fg 'green (text "c")) ma))
            ))))
        '()
    )
)

(define (UFO-move-cycle act ma)
    (cons
        (list (actor-send-list
            act
            (list 
                (list 'UFO-move-cycle UFO-move-line 0 -2 ma) ; horizontal slide
                (list 'UFO-move-cycle tick-counter 0 (list (event 20 UFO-shoot-line (list ma)))) ; shoot 5 times
                (list 'UFO-move-cycle tick-counter 0 (list (event 35 UFO-move-line (list -1 0 ma)))) ; vertical slide
                (list 'UFO-move-cycle tick-counter 0 (list (event 45 UFO-shoot-line (list ma)))) ; shoot 5 times
            )
        ))
        '()
    )
)
