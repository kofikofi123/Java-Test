needed_lua := lua

ponpile:
	@javac -g Test.java
	@$(needed_lua) Test.lua

clean:
	@rm *.class