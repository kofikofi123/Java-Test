needed_lua := lua-5.1 

ponpile:
	@javac -g Test.java
	@$(needed_lua) Test.lua

clean:
	@rm *.class