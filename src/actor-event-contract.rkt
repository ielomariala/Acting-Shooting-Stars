#lang racket
(require racket/contract)

(require "actor-contract.rkt")
(require "actor-event.rkt")

(provide (struct-out event))
(provide (contract-out [repeat-call-delayed(-> actor? number? procedure? list? list?)]
                       [create-event(-> number? procedure? list? event?)]
                       [tick-counter(-> actor? number? list? list?)]

                       [actor-add-score(-> actor? number? list?)]
                       [actor-update-scoreboard(-> actor? list?)]
                       ))