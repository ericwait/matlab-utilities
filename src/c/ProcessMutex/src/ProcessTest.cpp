#include "ScopedProcessMutex.h"

#include <stdio.h>
#include <string>
#include <thread>

int main(int argc, char* argv[])
{
	// Create all child processes with an argument
	if ( argc > 1 )
	{
		ScopedProcessMutex mutex("TestMutex");

		printf("Doing something (%s)!\n", argv[1]);

		std::this_thread::sleep_for(std::chrono::milliseconds(5000));

		printf("Done something (%s)!\n", argv[1]);

		return 0;
	}

	// Main dispatch process
	const int subprocesses = 4;

	STARTUPINFO si[subprocesses];
	PROCESS_INFORMATION pi[subprocesses];

	ZeroMemory(si, sizeof(si));
	ZeroMemory(pi, sizeof(pi));

	for ( int i=0; i < subprocesses; ++i )
		si[i].cb = sizeof(si[i]);

	for ( int i=0; i < subprocesses; ++i )
	{
		std::string procArgs = "Debug_x64\\ScopedProcessTest\\ScopedProcessTest.exe " + std::to_string(i);

		char buf[1024];
		strcpy(buf, procArgs.c_str());

		BOOL created = CreateProcess(NULL, buf, NULL, NULL, false, 0, NULL, NULL, &si[i], &pi[i]);
		if ( !created )
		{
			char* msgBuffer;
			DWORD errorCode = GetLastError();

			FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, errorCode,
							MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),(LPTSTR)&msgBuffer,0, NULL);

			printf("CreateProcess failed: %s", msgBuffer);

			LocalFree(msgBuffer);

			return -1;
		}
	}

	HANDLE childHandles[subprocesses];
	for ( int i=0; i < subprocesses; ++i )
		childHandles[i] = pi[i].hProcess;


	WaitForMultipleObjects(subprocesses, childHandles, true, INFINITE);


	return 0;
}
