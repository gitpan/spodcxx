#include <utest.h>
#include <stdio.h>

int main()
{
utest t(1,"Just for configuring");
	B_UTEST(t,"abc");
		printf("ok\n");
	E_UTEST(t);
return 0;
}
