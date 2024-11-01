%.o: %.cpp
	g++ -c $< -o $@

clean:
	rm -f *.o *.exe

test: 
	g++ words_test.cpp words.cpp string_sort.cpp string_shear.cpp -o word_test.exe

%_test.exe: %_test.o %.o
	g++ $^ -o $@

%.exe: %.o
	g++ $< -o $@


