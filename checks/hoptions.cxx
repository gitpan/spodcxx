#include <hoptions.h>

int main(int argc,char *argv[])
{
hoptions o(argc,argv,"--help|--test|--with-cake");
	return !o.ok();
}
