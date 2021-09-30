#lang racket

(provide (struct-out actor) make-actor actor-location actor-send actor-transfers-msg actor-execute-first-msg actor-update-list actor-send-list)

; Define the actor structure
; do-message applies the first command of the mailbox and returns an actor without this command  
(struct actor (pos prev-pos mailbox msg-next-tick tag collide sprite attributes))

; Creates an actor with an empty mailbox
(define (make-actor pos tag collide sprite attributes)
  (actor pos pos '() '() tag collide sprite attributes))


; Returns the actor location
(define (actor-location act)
 (actor-pos act))

; Adds message msg to the actor act mailbox at the first position
(define (actor-send act msg)
  (actor (actor-location act) (actor-prev-pos act) (actor-mailbox act) (cons msg (actor-msg-next-tick act)) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))
)

; Adds a list of messages to the actor
(define (actor-send-list act list-msg)
  (if (null? list-msg)
    act
    (actor-send (actor-send-list act (cdr list-msg)) (car list-msg))
  )
)

; Transfers all msg from msg-next-tick to mailbox
(define (actor-transfers-msg act)
  (if (null? (actor-msg-next-tick act)) act
      (actor-transfers-msg (actor (actor-pos act) (actor-prev-pos act)
                            (cons (car (actor-msg-next-tick act)) (actor-mailbox act)) (cdr (actor-msg-next-tick act))
                            (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act)))))

; Returns the actor act without its first message
(define (actor-remove-first-msg act)
  (if (null? (actor-mailbox act))
      act
      (actor (actor-location act) (actor-prev-pos act) (cdr (actor-mailbox act)) (actor-msg-next-tick act) (actor-tag act) (actor-collide act) (actor-sprite act) (actor-attributes act))  
    )
  )

;; Execute and remove the first msg, can be used as do-message2 but returning a list instead of a single actor
;; returns a list of actors
(define (actor-execute-first-msg act)
  (if (null? (actor-mailbox act))
      (cons (list act) '())
      (let ([msg (cdar (actor-mailbox act))])
        (apply (car msg) (actor-remove-first-msg act) (cdr msg)) ;; apply sur le nom de la fonction directement
      )
   )
)

;; Execute and deletes all messages of the given actor and returns a list of all remaining actors (newly created or updated by any message) 
;; and a list of messages to be read by the world so it can be send to the tagged actors. 
;; If any messages creates an actor with a message in it, it will have its messages also executed meaning that this can't function returns actors 
;; with messages left. However, function called by message can still creates actor with messages. 
(define (actor-update-list act)
  (let ([mailbox (actor-mailbox act)])
    (if (null? mailbox)
    (cons
      (list act)
      '()
    )
        ;; actor-updated-list ne contient pas forcement un l'actor, elle contient les acteurs qui sont encore en "vie" apres l'interprétation du message
        ;; temporalité : La séquence (tir, dead) ne provoque pas la meme chose que la séquence (dead, tir)
        ;; -> solution 1 : changer le format de do-message ? renvoyer (actor, new_actors) 
        ;; -> solution 2 : ne pas considérer les actions du même moment en tant que séquence, c-a-d interpréter les messages indépendemment des autres
        ;;                revient à faire : (append updated-act-list (cdr (actor-update-list (actor-remove-first-msg act)))
        ;; Pour l'instant, la fonction interprète tous les messages de tous les acteurs jusqu'à ce qu'il n'en reste plus         
        ;; 
        ;; updated-act-list contient tous les nouveaux acteurs issus de l'interprétation du premier msg
        (let ([updated-act-list (actor-execute-first-msg act)])
          ;;(append updated-act-list (cdr (actor-update-list (actor-remove-first-msg (car updated-act-list))))) ;; -> Version pour retourner seulement l'acteur
          ;;(apply append (map actor-update-list updated-act-list)) ;; -> Version pour retourner seulement une liste d'acteur
          (begin
            ;(print (cons 
            ;(apply append (map car (map actor-update-list (car updated-act-list))))
            ;(list (cdr updated-act-list) (apply append (map cdr (map actor-update-list (car updated-act-list)))))))
            (cons ;; Applique les messages de tous les acteurs et déjà présents et venant d'être crées
            (apply append (map car (map actor-update-list (car updated-act-list))))
            (append (cdr updated-act-list) (apply append (map cdr (map actor-update-list (car updated-act-list)))))
          ) ;; -> Version qui retourne une liste d'acteurs et une liste de messages.
        ))
       )))
