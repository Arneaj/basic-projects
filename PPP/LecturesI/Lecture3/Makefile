%.o: %.cpp
	g++ -c $< -o $@

clean:
	rm -f *.o *.exe

%_test.exe: %_test.o %.o
	g++ $^ -o $@



