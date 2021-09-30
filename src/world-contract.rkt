#lang racket

(require racket/contract)

(require "actor-contract.rkt")
(require "world.rkt")

(provide (struct-out world))
(provide (contract-out [make-world(-> world?)]
                       [world-add-actor(-> world? actor? world?)]
                       [world-add-actor-list(-> world? list? world?)]
                       [world-empty-mailbox(-> world? world?)]
                       [world-send(-> world? list? world?)]
                       [world-update(-> world? world?)]

                       [add-actor-to-list(-> list? actor? list?)]
                       [other-tag-lists(-> list? symbol? list?)]
                       [actors-send(-> list? list? list?)]
                       [actors-update(-> list? list?)]

                       [world-to-list (-> world? list?)]
                       ))