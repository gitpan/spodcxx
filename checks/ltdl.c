#include <ltdl.h>

int main()
{
lt_dlhandle module;
	module=lt_dlopen("test");
	lt_dlclose(module);
return 0;
}


