#lang racket

(require racket/contract)
(require "actor-contract.rkt")
(require "actor-action-contract.rkt")
(require "actor-generator.rkt")

(provide (contract-out [create-enemy-generator (-> pair? number? pair? number? moving-area? actor?)]
                       [create-score-counter (-> pair? actor?)]
                       [create-perma-wall(-> pair? moving-area? actor?)]
                       [create-line-fixed-walls(-> number? number? list?)]
                       [create-asteroid-generator(-> pair? number? pair? number? moving-area? actor?)]
                       [create-UFO-generator(-> pair? number? pair? number? moving-area? actor?)]
                       [create-wall-moving-left(-> pair? moving-area? actor?)]
                       
                       [infinite-ennemy-generator(-> actor? number? pair? number? moving-area? list?)]
                       [generate-asteroid(-> actor? pair? number? moving-area? list?)]
                       [generate-UFO(-> actor? pair? number? moving-area? list?)]))
