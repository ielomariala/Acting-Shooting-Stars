build:
	racket src/main.rkt -f 10.0 2>log.txt

test:
	racket src/tests.rkt

doc:
	scribble --dest doc actors.scrbl
	x-www-browser doc/actors.html
.PHONY: doc 

clean:	
	rm doc/* src/*.bak
