 #lang racket

(require
  (prefix-in lux: lux)
  (prefix-in raart: raart))

(require raart)
(require "actor-action-contract.rkt")
(require "world-contract.rkt")
(require "types.rkt")
(require "collision.rkt")
(require "raart-contract.rkt")

(provide (struct-out runtime) make-runtime runtime-add-world runtime-add-function
         runtime-current-world runtime-rewind runtime-unwind
         runtime-apply-func
         send-message-runtime is-game-end? start-application)

; All functions in runtime-functions must take a world as argument and returns a world
; max-count : number max of worlds in the runtime
; world-count : current-number of world in the runtime
; worlds : list of world
; functions : list of functions for the game-loop
(struct runtime (world-count max-worlds prev-worlds next-worlds functions fps isrunning)
  #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           (runtime-fps w))
         (define (word-label s ft) ;; Window label of the application
           "1 starred app but it is a shooting star")
         (define (word-event w e)  ;; Event Handler
           (match-define (runtime world-count max-worlds prev-worlds next-worlds functions fps isrunning) w)
           (let ([ma (make-moving-area 2 2 18 81)])
             (match e
               ["t" #f]  ;; Quit the application
               ["a" (runtime-rewind w)] ; Return in a previous world
               ["e" (runtime-unwind w)] ; Advance in a futur world
               ["q" (if isrunning (send-message-runtime w (list 'player move-left 1 ma)) w)] ; move left player
               ["z" (if isrunning (send-message-runtime w (list 'player move-up 1 ma)) w)] ; move up player
               ["d" (if isrunning (send-message-runtime w (list 'player move-right 1 ma)) w)] ; move right player
               ["s" (if isrunning (send-message-runtime w (list 'player move-down 1 ma)) w)] ; move down player
               [" " (if isrunning (send-message-runtime w (list 'player shoot-forward 1 (text "o") ma)) w)] ; move down player
               ["p" (if isrunning (runtime world-count max-worlds prev-worlds next-worlds functions fps #f) ; stop the game or unstop it
                        (runtime world-count max-worlds prev-worlds next-worlds functions fps #t))]
               [_  w]   ;; Otherwise do nothing
               ))
           )
         (define (word-output w)      ;; What to display for the application
           ;; (match-define (world tick) w)
          ; (match-define (runtime world-count max-worlds prev-worlds next-worlds functions) w)
           (display-world (runtime-current-world w))
          ;(raart:matte-at term-cols term-rows
          ;                 (modulo tick term-cols)
          ;                 (modulo (quotient tick term-cols) term-rows)
          ;               (raart:bg 'red (raart:text ">")))
         )
         (define (word-tick w)        ;; Update function after one tick of time ; NICOLAS REGARDE LA GAME LOOP EST LA
           (match-define (runtime world-count max-worlds prev-worlds next-worlds functions fps isrunning) w)
           ;(if (is-game-end? w) #f
               (if isrunning (runtime-apply-func w) w)
         )
         ])

; Returns a runtime without any world and any function. Takes the number max of worlds for the list
(define (make-runtime wld max-w fps)
  (runtime 1 max-w (list wld) '() (list world-update world-empty-mailbox collisions) fps #t))

; Adds a function to the runtime (for the game loop)
(define (runtime-add-function func r)
  (runtime (runtime-world-count r)
           (runtime-max-worlds r)
           (runtime-prev-worlds r)
           (runtime-next-worlds r)
           (cons func (runtime-functions r))
           (runtime-fps r)
           (runtime-isrunning r)))

; Adds a world to the runtime
(define (runtime-add-world w r)
  (if (< (runtime-world-count r) (runtime-max-worlds r)) (runtime (add1 (runtime-world-count r))
                                                                  (runtime-max-worlds r)
                                                                  (cons w (runtime-prev-worlds r))
                                                                  '()
                                                                  (runtime-functions r)
                                                                  (runtime-fps r)
                                                                  (runtime-isrunning r))
      (letrec ([add-world-rec (lambda (worlds-init worlds-end count)
                                (if (zero? count) (runtime (runtime-max-worlds r)
                                                           (runtime-max-worlds r)
                                                           (reverse worlds-end)
                                                           '()
                                                           (runtime-functions r)
                                                           (runtime-fps r)
                                                           (runtime-isrunning r))
                                    (add-world-rec (cdr worlds-init) (cons (car worlds-init) worlds-end) (sub1 count))))])
        (add-world-rec (runtime-prev-worlds r) (list w) (sub1 (runtime-max-worlds r))))))

; Returns the last world created
(define (runtime-current-world r)
  (car (runtime-prev-worlds r)))

; Returns a runtime which has returned from one world in the past
(define (runtime-rewind r)
  (if (<= (runtime-world-count r) 1) r
             (runtime (sub1 (runtime-world-count r))
                      (runtime-max-worlds r)
                      (cdr (runtime-prev-worlds r))
                      (cons (car (runtime-prev-worlds r)) (runtime-next-worlds r))
                      (runtime-functions r)
                      (runtime-fps r)
                      #f)))

; Returns a runtime which has advanced from one world into the future
(define (runtime-unwind r)
  (if (null? (runtime-next-worlds r)) r
      (runtime (add1 (runtime-world-count r))
               (runtime-max-worlds r)
               (cons (car (runtime-next-worlds r)) (runtime-prev-worlds r))
               (cdr (runtime-next-worlds r))
               (runtime-functions r)
               (runtime-fps r)
               #f)))

; Returns a runtime with a new world added containing the message msg given in parameters
(define (send-message-runtime r msg)
  (let ([last-world (runtime-current-world r)])
    (runtime (runtime-world-count r)
             (runtime-max-worlds r)
             (cons (world-send last-world msg) (cdr (runtime-prev-worlds r)))
             (runtime-next-worlds r)
             (runtime-functions r)
             (runtime-fps r)
             (runtime-isrunning r))
  )
)

; Sends all functions of runtime to actors according to their tag (A TESTER)
(define (runtime-apply-func r)
  (letrec ([apply-rec (lambda (funcs w r)
                        (if (null? funcs) (runtime-add-world w r)
                            (apply-rec (cdr funcs) ((car funcs) w) r)))])
    (apply-rec (runtime-functions r) (runtime-current-world r) r)))

;; Ends the game is the player die
(define (is-game-end? r)
  (let ([actors (world-actors (runtime-current-world r))])
    (if (assoc 'player actors) #f #t)))
    

;; Starter function
(define (start-application runtime)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux runtime)))
  (void))