
all:	

export:
	rm -rf .tmp
	mkdir .tmp
	cp -r * .tmp
	find .tmp/ -name CVS | xargs rm -rf
	find .tmp -type f | xargs todos
	(cd .tmp; zip -r ../export.zip *)


