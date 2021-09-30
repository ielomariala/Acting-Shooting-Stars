#lang racket
(require racket/contract)
(require raart)

(require "actor.rkt")

(provide (struct-out actor))
(provide (contract-out [make-actor(-> pair? symbol? procedure? raart? any/c actor?)]
                       [actor-location(-> actor? pair?)]
                       [actor-send(-> actor? list? actor?)]
                       [actor-send-list(-> actor? list? actor?)]
                       [actor-transfers-msg (-> actor? actor?)]
                       [actor-execute-first-msg (-> actor? list?)]
                       [actor-update-list(-> actor? any/c)]
                       ))