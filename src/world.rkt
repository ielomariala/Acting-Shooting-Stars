#lang racket

(require "actor-contract.rkt")

(provide (struct-out world) make-world world-add-actor world-empty-mailbox world-send world-update world-add-actor-list actor-send-list)
(provide add-actor-to-list other-tag-lists actors-send actors-update)
(provide world-to-list)

; define a world,
;    -> actors is an alist of actors ordonned according to their tags
; ex : act1-tag = "ship"
; ex : act2-tag = "ship"
; ex : act3-tag = "wall"
; world = '((ship act1 act2) (wall act3))
;    -> functions is the list of functions executed by the runtime (game loop functions must return a world)
(struct world (actors mailbox))

; Returns a world without any actors
(define (make-world)
  (world '() '()))

; Returns all the lists wich don't have for tag the tag specified in parameter 
(define (other-tag-lists actors tag)
  (letrec ([other-tag-lists-rec (lambda (actors-list tag res) 
                             (if (null? actors-list) res
                                 (if (eq? tag (caar actors-list)) (other-tag-lists-rec (cdr actors-list) tag res)
                                     (other-tag-lists-rec (cdr actors-list) tag (cons (car actors-list) res)))))])
    (other-tag-lists-rec actors tag '())))

; Adds an actor to a list according to their tag
(define (add-actor-to-list actors-list actor)
  (let ([tag (actor-tag actor)]) 
  (if (pair? (assoc tag actors-list)) (cons (append (assoc tag actors-list) (list actor)) (other-tag-lists actors-list tag))                                      
      (cons (list tag actor) actors-list))))

; Adds actors to a list according to their tag
(define (add-actors-to-list actors-list actors)
  (if (null? actors) actors-list
      (add-actors-to-list (add-actor-to-list actors-list (car actors)) (cdr actors)))) 

; Adds an actor to the world
(define (world-add-actor w actor)
  (world (add-actor-to-list (world-actors w) actor) (world-mailbox w)))

; Adds a list of actors to the world
  (define (world-add-actor-list w list-actor)
    (if (null? list-actor)
      w
      (world-add-actor (world-add-actor-list w (cdr list-actor)) (car list-actor))
    )
  )

; Send a message msg to all actors of the list actors (keeps the tag of the actor list)
(define (actors-send actors msg)
  (letrec ([actors-send-rec (lambda (actors-init msg actors-end)
                              (if (null? actors-init) (reverse actors-end)
                                 (if (actor? (car actors-init))
                                     (actors-send-rec (cdr actors-init) msg (cons (actor-send (car actors-init) msg) actors-end))
                                     (actors-send-rec (cdr actors-init) msg (cons (car actors-init) actors-end))
                                     )))])

    (actors-send-rec actors msg '())))


(define (world-empty-mailbox w)
  (if (null? (world-mailbox w)) w
      (world-empty-mailbox (world-send (world (world-actors w) (cdr (world-mailbox w))) (car (world-mailbox w))))))
  
; Send a message msg to all actors of the world with the good tag
(define (world-send w msg)
  (let ([receivers (assoc (car msg) (world-actors w))])
    (if (or (procedure? (car msg)) (not receivers)) 
        (world (actors-send (world-actors w) msg) (world-mailbox w))
        (world (cons (actors-send receivers msg) (other-tag-lists (world-actors w) (car msg)))
                   (world-mailbox w)))))

; Update all actors of the list actors (remove tags if there are)
(define (actors-update actors)
  (letrec ([actors-update-rec (lambda (actors-init actors-end msg)
                                (if (null? actors-init) (cons actors-end msg)
                                    (if (actor? (car actors-init))
                                        (let ([updated-actor (actor-update-list (actor-transfers-msg (car actors-init)))])
                                          (actors-update-rec (cdr actors-init)
                                                             (append actors-end (car updated-actor))
                                                             (add-msgs-to-list msg (cdr updated-actor))))
                                        (actors-update-rec (cdr actors-init) actors-end '()))))])
    (actors-update-rec actors '() '())))

; Adds all messages msgs to the list msg-list
(define (add-msgs-to-list msg-list msgs)
  (if (null? msgs) msg-list
      (add-msgs-to-list (cons (car msgs) msg-list) (cdr msgs))))
              

; Updates all actors of the world (execute their messages)
(define (world-update w)
  (letrec ([world-update-rec (lambda (actors-lists new-actors new-msg)
                               (if (null? actors-lists) (world new-actors new-msg)
                                   (let ([updated-actors (actors-update (car actors-lists))])
                                   (world-update-rec (cdr actors-lists)
                                                     (add-actors-to-list new-actors (car updated-actors))
                                                     (add-msgs-to-list new-msg (cdr updated-actors))))))])
    (world-update-rec (world-actors w) '() '())))

; Puts all actors of a world in a list
(define (world-to-list world)
  (letrec([alist-to-list (lambda (alist)
                           (if (empty? alist) '()
                               (append (cdr (assoc (caar alist) alist))
                                       (alist-to-list (cdr alist)))))])
    (alist-to-list (world-actors world))))