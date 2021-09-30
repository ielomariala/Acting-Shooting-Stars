#lang racket

(require "world-contract.rkt")
(require "runtime.rkt")

(provide (struct-out runtime))
(provide (contract-out [make-runtime(-> world? number? flonum? runtime?)]
                       [runtime-add-world (-> world? runtime? runtime?)]
                       [runtime-add-function (-> procedure? runtime? runtime?)]
                       [runtime-current-world (-> runtime? world?)]
                       [runtime-rewind (-> runtime? runtime?)]
                       [runtime-unwind (-> runtime? runtime?)]
                       [send-message-runtime (-> runtime? list? runtime?)]
                       [is-game-end? (-> runtime? boolean?)]
                       [runtime-apply-func (-> runtime? runtime?)]
                       [start-application (-> runtime? any/c)]
                       ))