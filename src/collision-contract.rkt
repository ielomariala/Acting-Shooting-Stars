#lang racket
(require racket/contract)
(require raart)

(require "collision.rkt")
(require "world-contract.rkt")
(require "actor-contract.rkt")

(provide (contract-out [coeff-dir-pos(-> actor? any/c)]
                       [collision-with-act(-> actor? list? actor?)]
                       [collision-aux(-> list? list? world? world?)]
                       [collisions(-> world? world?)]         
                       [are-colliding?(-> actor? actor? boolean?)]
                       ))
   