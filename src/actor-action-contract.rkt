#lang racket

(require racket/contract)

(require raart)
(require "actor-contract.rkt")
(require "actor-action.rkt")

(provide (struct-out moving-area))
(provide (contract-out [make-moving-area (-> number? number? number? number? moving-area?)]
                       [kill-actor-out-area(-> actor? moving-area? list?)]
                       
                       [move(-> actor? number? number? moving-area? list?)]
                       [move-right(-> actor? number? moving-area? list?)]
                       [move-up(-> actor? number? moving-area? list?)]
                       [move-down(-> actor? number? moving-area? list?)]
                       [move-left(-> actor? number? moving-area? list?)]

                       [move-right-constantly(-> actor? number? moving-area? list?)]
                       [move-left-constantly(-> actor? number? moving-area? list?)]
                       [move-down-constantly(-> actor? number? moving-area? list?)]
                       [move-up-constantly(-> actor? number? moving-area? list?)]
                       
                       [actor-zig-zag(-> actor? moving-area? list?)]
                       [shoot-forward(-> actor? number? raart? moving-area? list?)]
                       [shoot-backward(-> actor? number? raart? moving-area? list?)]

                       [UFO-move-line(-> actor? number? number? moving-area? list?)]
                       [UFO-move-cycle(-> actor? moving-area? list?)]
                       [UFO-shoot-line(-> actor? moving-area? list?)]
                       ))