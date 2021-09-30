#lang racket
(require rackunit)
(require rackunit/text-ui)
(require raart)

(require "actor-contract.rkt")
(require "actor-event-contract.rkt")
(require "world-contract.rkt")
(require "runtime-contract.rkt")
(require "raart-contract.rkt")
(require "collision-contract.rkt")
(require "actor-action-contract.rkt")
(require "types.rkt")

(define all-tests
  (test-suite
   "Tests file for actor project"
     (test-case
      "Tests for updated update-actor for returning a list of actors"
      ;; Complex testing ... 
      (let* ([olenrob (lambda (act b a) 
              (cons
                (list act (actor (cons a b) (cons a b) '() '() "test5" collide-ennemy (text "X") (actor-attributes act)))
                (list "msg42")
                ))]
             [bornelo (lambda (act a b)
                (cons
                    (list act (actor (cons 3 4) (cons 3 4) '() '() "test3" collide-ennemy (text "X") (actor-attributes act)) (actor (cons 3 4) (cons 3 4) (list (cons "None" (list olenrob 85 29))) '() "test4" collide-ennemy (text "X") (actor-attributes act)))
                    (list "msg1" "msg2" "msg3")
                ))]
             [a-list-test (actor (cons 1 2) (cons 1 2) (list (cons "All" (list bornelo 4 2)) (cons "All" (list olenrob 4 2)) (cons "All" (list bornelo 4 2))) '() "test" collide-ennemy (text "X") '())]
             [act-updated (actor-update-list a-list-test)])
      
      (check-equal? (length (car act-updated)) 8)
      (check-equal? (length (cdr act-updated)) 9)
      (check-equal? (cadr act-updated) "msg1")
      (check-equal? (caddr act-updated) "msg2")
      (check-equal? (actor-tag (caar act-updated)) "test")
      )

      ;; Simple test to see actor generating others and mailbox filling
      (let* ([Example-Message-Function-One (lambda (act arg1 arg2) 
              (cons
                (list act (actor (cons arg1 arg2) (cons arg1 arg2) '() '() "test1" collide-ennemy (text "X") (actor-attributes act)))
                (list (cons "world" (list move 30 40 0 0 110 110)))
                ))]
             [Example-Message-Function-Two (lambda (act a b)
                (cons
                    (list act (actor (cons a b) (cons a b) (list (cons "None" (list Example-Message-Function-One 10 20))) '() "test2" collide-ennemy (text "X") (actor-attributes act)))
                    (list (cons "tag1" (list "pointer1" "arg1" "arg2")))
                ))]
             [a-list-test (actor (cons 1 2) (cons 1 2) (list (cons "All" (list Example-Message-Function-Two 20 30))) '() "test" collide-ennemy (text "X") '())]
             [act-updated (actor-update-list a-list-test)])

             (check-equal? (cadr act-updated) (cons "tag1" (list "pointer1" "arg1" "arg2")))
             (check-equal? (cdr act-updated)
               (list (cons "tag1" (list "pointer1" "arg1" "arg2")) (cons "world" (list move 30 40 0 0 110 110))))
             (check-equal? (actor-tag (caar act-updated)) "test")
             (check-equal? (actor-tag (cadar act-updated)) "test2")
             (check-equal? (actor-tag (caddar act-updated)) "test1")
     )

      ;; Actor dies
     (let* ([Example-Message-Function-One (lambda (act arg1 arg2) 
              (cons
                '()
                (list (cons "world" (list "dead" 30 40)))
                ))]
             [a-list-test (actor (cons 1 2) (cons 1 2) (list (cons "All" (list Example-Message-Function-One 20 30))) '() "test" collide-ennemy (text "X") '())]
             [act-updated (actor-update-list a-list-test)])

             (check-equal? (cadr act-updated) (cons "world" (list "dead" 30 40)))
             (check-equal? (car act-updated) '())
     ))
     
     (test-case
      "Basic-use of an actor (actor-file)"
       (let* ([sprite (text "X")]
              [a0 (make-actor '(0 . 0) 'none collide-wall sprite 'attributes-test)]
              [a1 (actor-send a0 (list 'none move 1 2 0 0 110 110))]
              [a2 (actor-send a1 (list 'none move 2 3 0 0 110 110))])

         ; Check make-actor function
         (check-equal? (actor-pos a0) '(0 . 0))
         (check-equal? (actor-mailbox a0) '())
         (check-equal? (actor-tag a0) 'none)
         (check-equal? (actor-sprite a0) sprite)
         (check-equal? (actor-attributes a0) 'attributes-test)
         
         ; Check actor-location function
         (check-equal? (actor-location a0) '(0 . 0))

         ; Check actor-send function
         (check-equal? (actor-msg-next-tick a1) (list (list 'none move 1 2 0 0 110 110)))
         (check-equal? (actor-msg-next-tick a2) (list (list 'none move 2 3 0 0 110 110) (list 'none move 1 2 0 0 110 110))) 
        ))
     (test-case
      "Basic use of a world (world file)"
      (let* ([ma (make-moving-area 0 0 110 110)]
             [a0 (make-actor '(0 . 0) 'none collide-ennemy (text "X") '())]
             [a1 (make-actor '(0 . 0) 'ship collide-ennemy (text "X") '())]
             [a2 (make-actor '(0 . 0) 'none collide-ennemy (text "X") '())]
             [actor-list (list (list 'none a0 a2) (list 'ship a1))]
             [msg1 (list 'none move 1 2 ma)]
             [msg2 (list 'ship summon a2)]
             [msg3 (list 'none summon a1)]
             [msg4 (list 'none send-message)]
             [w0 (make-world)]
             [w1 (world-add-actor w0 a0)]
             [w2 (world-add-actor w1 a1)]
             [w3 (world-add-actor w2 a2)]
             
             [a3 (actor-send (actor-send a0 msg1) msg1)]
             [a4 (actor-send (actor-send a0 msg1) msg1)]
             [a5 (actor-send a0 msg3)]
             [a6 (actor-send (actor-send a0 msg4) msg4)]
             [w4 (world-add-actor (world-add-actor w0 a3) a4)]
             [w5 (world-add-actor w0 a5)]
             [w6 (world-add-actor w0 a6)]

             [w7 (world (list (list 'none a0)) (list (list 'none move 1 2 ma)))]
             [w8 (world (list (list 'none a0) (list 'ship a1)) (list (list 'none move 1 2 ma) (list 'ship summon a2)))]

             [msg5 (list 'none send-self-msg msg1)]
             )
        
        ; Check make-world function
        (check-equal? (world-actors w0) '())
        (check-equal? (world-mailbox w0) '())
        
        ; Check other-tag-lists function
        (check-equal? (other-tag-lists actor-list 'none) (list (list 'ship a1)))
        (check-equal? (other-tag-lists actor-list 'ship) (list (list 'none a0 a2)))

        ; Check add-actor-to-list function
        (check-equal? (add-actor-to-list '() a0) (list (list 'none a0)))
        (check-equal? (add-actor-to-list (list (list 'none a0)) a1) (list (list 'ship a1) (list 'none a0)))
        (check-equal? (add-actor-to-list (list (list 'ship a1) (list 'none a0)) a2) (list (list 'none a0 a2) (list 'ship a1)))
        
        ; Check world-add-actor function
        (check-equal? (world-actors w1) (list (list 'none a0)))
        (check-equal? (world-actors w2) (list (list 'ship a1) (list 'none a0)))
        (check-equal? (world-actors w3) (list (list 'none a0 a2) (list 'ship a1)))
        
        ; Check actors-send function
        (check-equal? (actor-msg-next-tick (cadr (actors-send (car actor-list) msg1))) (list msg1))
        (check-equal? (actor-msg-next-tick (caddr (actors-send (car actor-list) msg1))) (list msg1))
        
        (check-equal? (actor-msg-next-tick (cadr (actors-send (actors-send (car actor-list) msg1) msg2))) (list msg2 msg1))
        
        ; Check world-send function
        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-send w3 msg1)))) (list msg1))
        (check-equal? (actor-msg-next-tick (caddar (world-actors (world-send w3 msg1)))) (list msg1))
        (check-equal? (actor-msg-next-tick (cadadr (world-actors (world-send w3 msg1)))) '())

        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-send (world-send w3 msg1) msg2)))) (list msg2))

        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-send (world-send w3 msg1) msg3)))) (list msg3 msg1))
        (check-equal? (actor-msg-next-tick (caddar (world-actors (world-send (world-send w3 msg1) msg3)))) (list msg3 msg1))
        
        ; Check world-empty-mailbox
        (check-equal? (world-mailbox (world-empty-mailbox w7)) '())
        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-empty-mailbox w7)))) (list (list 'none move 1 2 ma)))
        
        (check-equal? (world-mailbox (world-empty-mailbox w8)) '())
        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-empty-mailbox w8)))) (list (list 'ship summon a2)))
        (check-equal? (actor-msg-next-tick (cadadr (world-actors (world-empty-mailbox w8)))) (list (list 'none move 1 2 ma)))
        
        ; Check actors-update function
        (check-equal? (actors-update (list 'none a0 a2)) (cons (list a0 a2) '()))

        (check-equal? (actor-location (caar (actors-update (actors-send (list 'none a0 a2) msg1)))) (cons 1 2))
        (check-equal? (actor-location (cadar (actors-update (actors-send (list 'none a0 a2) msg1)))) (cons 1 2))
        (check-equal? (actor-msg-next-tick (caar (actors-update (actors-send (list 'none a0 a2) msg1)))) '())

        (check-equal? (actor-location (caar (actors-update (actors-send (actors-send (list 'none a0 a2) msg1) msg1)))) (cons 2 4))
        
        (check-equal? (actor-tag (caar (actors-update (actors-send (list 'none a0) msg3)))) 'none)
        (check-equal? (actor-tag (cadar (actors-update (actors-send (list 'none a0) msg3)))) 'ship)

        (check-equal? (cdr (actors-update (actors-send (actors-send (list 'none a0) msg4) msg4))) (list (list 'none move 1 2 0 0 110 110) (list 'none move 1 2 0 0 110 110)))
        
        ; Check world-update function
        (check-equal? (caar (world-actors (world-update w1))) 'none)
        (check-equal? (cadar (world-actors (world-update w1))) a0)
        (check-equal? (world-mailbox (world-update w1)) '())
        
        (check-equal? (actor-location (cadar (world-actors (world-update w4)))) (cons 2 4))
        (check-equal? (actor-location (caddar (world-actors (world-update w4)))) (cons 2 4))

        (check-equal? (car (world-actors (world-update w5))) (list 'ship a1))
        (check-equal? (caadr (world-actors (world-update w5))) 'none)
        (check-equal? (actor-tag (cadadr (world-actors (world-update w5)))) 'none)

        (check-equal? (world-mailbox (world-update w6)) (list (list 'none move 1 2 0 0 110 110) (list 'none move 1 2 0 0 110 110)))

        ; An actor send a msg to itself
        (check-equal? (actor-msg-next-tick (cadar (world-actors (world-update (world-send w1 msg5))))) (list msg1))
        
        )
        
        ;; Checking if messages are redirected correctly
     (let* ([Example-Message-Function-One (lambda (act arg1 arg2) 
              (cons
                (list act)
                (list (cons 'cucumber (list 'randomFunc 30 40)))
                ))]
             [a-sender (actor (cons 1 2) (cons 1 2) (list (cons 'test (list Example-Message-Function-One 20 30))) '() 'test collide-ennemy (text "X") '())]
             [a-cucumber (make-actor '(0 . 0) 'cucumber collide-ennemy (text "X") '())]
             [world (world-add-actor-list (make-world) (list a-sender a-cucumber))]
             [world-updated (world-update world)])

              (check-equal? (actor-tag (cadar (world-actors world-updated))) 'cucumber) ; vérifier qui est qui
              (check-equal? (actor-tag (car (cdadr (world-actors world-updated)))) 'test) ; là aussi
              (check-equal? (actor-mailbox (car (cdadr (world-actors world-updated)))) '()) ; on vérifie que l'acteur a-sender n'a plus de messages, donc le message a bien été lu

              (check-equal? (actor-tag (cadar (world-actors (world-empty-mailbox world-updated)))) 'cucumber)
              (check-equal? (world-mailbox (world-empty-mailbox world-updated)) '()) 
              (check-equal? (actor-msg-next-tick (cadar (world-actors (world-empty-mailbox world-updated)))) (list (list 'cucumber 'randomFunc 30 40))) ; La boite de mail ne devrait pas etre vide, donc ca devrait planter ici
              ; (check-equal? (cadar (actor-mailbox (cadar (world-actors (world-update world-updated))))) 'randomFunc) ; Par contre celui devrait être vrai
     ))
         
     (test-case
      "Basic use of a runtime (runtime file)"
      (let* ([w0 (make-world)]
             [w1 (make-world)]
             [w2 (make-world)]
             [r0 (make-runtime w0 2 10)]
             [r1 (runtime-add-function world-update r0)]
             [r2 r0]
             [r3 (runtime-add-world w1 r2)]
             ;[r4 (runtime-apply-func (runtime-add-function test2 (runtime-add-function test1 r2)))]
             [r5 (runtime 0 2 '() (list w0 w1) '() 10 #t)]

             [a0 (make-actor '(0 . 0) 'player collide-ennemy (text ">") '())]
             [r6 (runtime-add-world (world-add-actor w0 a0) r0)]  
             )
        
        ; Check make-runtime function
        (check-equal? (runtime-world-count r0) 1)
        (check-equal? (runtime-max-worlds r0) 2)
        (check-equal? (runtime-prev-worlds r0) (list w0))
        (check-equal? (runtime-next-worlds r0) '())
        (check-equal? (runtime-functions r0) (list world-update world-empty-mailbox))
        (check-equal? (runtime-fps r0) 10)
        
        ; Check runtime-add-function
        (check-equal? (runtime-world-count r1) 1)
        (check-equal? (runtime-max-worlds r1) 2)
        (check-equal? (runtime-prev-worlds r1) (list w0))
        (check-equal? (runtime-functions r1) (list world-update world-update world-empty-mailbox))
        
        ; Check runtime-add-world
        (check-equal? (runtime-world-count r2) 1)
        (check-equal? (runtime-max-worlds r2) 2)
        (check-equal? (runtime-prev-worlds r2) (list w0))
        (check-equal? (runtime-functions r2) (list world-update world-empty-mailbox))

        (check-equal? (runtime-world-count (runtime-add-world w0 r2)) 2)
        (check-equal? (runtime-prev-worlds (runtime-add-world w1 r2)) (list w1 w0))

        (check-equal? (runtime-world-count (runtime-add-world w2 (runtime-add-world w1 r2))) 2)
        (check-equal? (runtime-prev-worlds (runtime-add-world w2 (runtime-add-world w1 r2))) (list w2 w1))

        ; Check current-world function
        (check-equal? (runtime-current-world r3) w1)

        ; Check runtime-rewind function
        (check-equal? (runtime-world-count (runtime-rewind r0)) 1)

        (check-equal? (runtime-world-count (runtime-rewind r3)) 1)
        (check-equal? (runtime-max-worlds (runtime-rewind r3)) 2)
        (check-equal? (runtime-prev-worlds (runtime-rewind r3)) (list w0))
        (check-equal? (runtime-next-worlds (runtime-rewind r3)) (list w1))
        (check-equal? (runtime-functions (runtime-rewind r3)) (runtime-functions r3))

        (check-equal? (runtime-world-count (runtime-rewind (runtime-rewind (runtime-rewind r3)))) 1)
        (check-equal? (runtime-prev-worlds (runtime-rewind (runtime-rewind (runtime-rewind r3)))) (list w0))
        (check-equal? (runtime-next-worlds (runtime-rewind (runtime-rewind (runtime-rewind r3)))) (list w1))
        
        ; Check runtime-unwind function
        (check-equal? (runtime-world-count (runtime-unwind r0)) 1)

        (check-equal? (runtime-world-count (runtime-unwind r5)) 1)
        (check-equal? (runtime-max-worlds (runtime-unwind r5)) 2)
        (check-equal? (runtime-prev-worlds (runtime-unwind r5)) (list w0))
        (check-equal? (runtime-next-worlds (runtime-unwind r5)) (list w1))
        (check-equal? (runtime-functions (runtime-unwind r5)) (runtime-functions r5))

        (check-equal? (runtime-world-count (runtime-unwind (runtime-unwind (runtime-unwind r5)))) 2)
        (check-equal? (runtime-prev-worlds (runtime-unwind (runtime-unwind (runtime-unwind r5)))) (list w1 w0))
        (check-equal? (runtime-next-worlds (runtime-unwind (runtime-unwind (runtime-unwind r5)))) '())

        ; Check is-game-end? function
        (check-equal? (is-game-end? r2) #t)
        (check-equal? (is-game-end? r6) #f)
        
        ; Check runtime-apply-func
        ;(runtime-apply-func r4)
        
        ))
      (test-case
       "Collision"
       (let* ([ma (make-moving-area 0 0 110 110)]
              [a0 (caar (move (make-actor '(1 . 0) 'player collide-player (text "X") 2) -1 0 ma))]
              [a1 (caar (move (make-actor '(0 . 3) 'ship collide-ennemy (text "X") 1) 0 -1 ma))]
              [a2 (caar (move (make-actor '(1 . 1) 'wall collide-wall (text "X") '()) -1 -1 ma))]
              [a3 (caar (move (make-actor '(0 . 0) 'player collide-player (text "X") 1) 3 2 ma))]
              [a4 (caar (move (make-actor '(2 . 0) 'bullet collide-ennemy (text "X") 1) -2 3 ma))]
              [a5 (caar (move (make-actor '(0 . 0) 'bullet collide-ennemy (text "X") '()) 2 1 ma))]
              [a6 (caar (move (make-actor '(1 . 4) 'boulder collide-wall (text "X") '()) 1 -2 ma))]
              [a7 (caar (move (make-actor '(4 . 4) 'bullet collide-ennemy (text "X") '()) 1 1 ma))]
              [wld0 (world-add-actor (world-add-actor (make-world) a0) a1)]
              [list1 (world-to-list wld0)]
              [wld1 (collisions wld0)]
              [wld2 (world-add-actor (world-add-actor (make-world) a0) a2)]
              [wld3 (collisions wld2)]
              [wld4 (collisions (world-add-actor (world-add-actor wld2 a7) a6))]
              [wld5 (world-update wld3)]
              [wld6 (world-update (collisions (world-add-actor (world-add-actor (make-world) a3) a4)))]
              )
              
         ;(print (world-actors wld5))
         (check-equal? (equal? (actor-tag (car list1)) 'ship) #t)
         (check-equal? (equal? (actor-tag (second list1)) 'player) #t)
         (check-equal? (are-colliding? a0 a1) #f)
         (check-equal? (are-colliding? a0 a2) #t)
         (check-equal? (are-colliding? a3 a4) #t)
         (check-equal? (are-colliding? a5 a6) #f)
         (check-equal? (actor-msg-next-tick (second (first (world-actors wld1)))) '())
         (check-equal? (actor-msg-next-tick (second (second (world-actors wld1)))) '())
         (check-equal? (first (actor-msg-next-tick (second (second (world-actors wld3))))) (cons 'wall (list collide-wall a0)))
         (check-equal? (first (actor-msg-next-tick (second (first (world-actors wld3))))) (cons 'player (list collide-player a2)))
         
         (check-equal? (first (actor-msg-next-tick (second (first (world-actors wld4))))) (cons 'player (list collide-player a2)))
         (check-equal? (first (actor-msg-next-tick (second (second (world-actors wld4))))) (cons 'wall (list collide-wall a0)))
         (check-equal? (actor-msg-next-tick (second (third (world-actors wld4)))) '())
         (check-equal? (actor-msg-next-tick (second (fourth (world-actors wld4)))) '())
         (check-equal? (actor-attributes (second (second (world-actors wld5)))) 'invincible)
         (check-equal? (actor-msg-next-tick (second (second (world-actors wld5)))) (list (cons 'player (list invincibility 10 1))))
         (check-equal? (actor-tag (second (first (world-actors wld5)))) 'wall)
         (check-equal? (assoc 'player (world-actors wld6)) #f)
         (check-equal? (assoc 'bullet (world-actors wld6)) #f)
                       ;((actor-send (make-player '(1 . 25) (sub1 (actor-attributes actor))) (cons (actor-tag actor) (list invincibility 10 (sub1 (actor-attributes actor)))))
         ))

       ))


(define (summon act1 act2)
  (cons (list act1 act2) '()))

(define (send-message act)
  (cons (list act) (list (list 'none move 1 2 0 0 110 110))))

; Send a msg to the actor
(define (send-self-msg act msg)
  (cons (list (actor-send act msg)) '()))

(define (test1 w)
  (begin
    (print "test1")
    w))

(define (test2 w)
  (begin
    (print "test2")
    w))


(run-tests all-tests)