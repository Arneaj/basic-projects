#include <iostream>
#include <thread>
#include <chrono>
#include <mutex>

using namespace std;

mutex global_lock;

void func( int id_number )
{
	int total = 0;
	for (int i = 0; i<100000; i++) total += i;

    global_lock.lock();
	cout << total << ", id: " << id_number << endl;
    global_lock.unlock();
}

int main()
{
    typedef chrono::high_resolution_clock Time;
    typedef chrono::duration<float> fsec;

    auto t0 = Time::now(); // time before solving

	thread th1(func, 1);
	thread th2(func, 2);

    th1.join();
	th2.join();

    auto t1 = Time::now(); // time after solving

    fsec duration_in_sec = t1 - t0;
    cout << "Time taken with multithreading: " << duration_in_sec.count() << endl;

    t0 = Time::now(); // time before solving

	func(1);
	func(2);

    t1 = Time::now(); // time after solving

    duration_in_sec = t1 - t0;
    cout << "Time taken without multithreading: " << duration_in_sec.count() << endl;
}
