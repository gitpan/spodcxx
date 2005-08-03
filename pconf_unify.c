#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define VERSION "0.23"
#define PACKAGE "pconf"

static
void usage(void)
{
	printf("pconf_unify [--cflags <flags> | --ldflags <flags> | --libs <libraries> | --version]\n");
	printf("\n");
	printf("  sample: pconf_unify --libs -lutest -lpthread -lcritsec -lpthread\n"); 
	printf("          -lutest -lcritsec -lpthread\n");
	printf("\n");
	exit(1);
}

static
void do_cflags(char *flags[],int n);

static
void do_ldflags(char *flags[],int n);

static
void do_libs(char *libs[],int n);

int main(int argc,char *_argv[])
{
char **argv=malloc(sizeof(char*)*(argc+2));
	{int i;
		for(i=0;i<argc;i++) {
			argv[i]=_argv[i];
		}
	}
	if (argc==1) { usage(); }
	else if (strcmp(argv[1],"--cflags")==0) {
		do_cflags(&argv[2],argc-2);
	}
	else if (strcmp(argv[1],"--ldflags")==0) {
		do_ldflags(&argv[2],argc-2);
	}
	else if (strcmp(argv[1],"--libs")==0) {
		do_libs(&argv[2],argc-2);
	}
	else if (strcmp(argv[1],"--version")==0) {
		printf("%s v%s",PACKAGE,VERSION);
	}
	else {
		usage();
	}
	free(argv);
return 0;
}

void do_cflags(char *flags[],int n)
{
int i,j;
	for(i=0;i<n;i++) {
		if (flags[i]!=NULL) {
			for(j=i+1;j<n;j++) {
				if (flags[j]!=NULL) {
					if (strcmp(flags[j],flags[i])==0) {
						flags[j]=NULL;
					}
				}
			}
		}
	}
	for(i=0;i<n;i++) {
		if (flags[i]!=NULL) { printf(" %s",flags[i]); }
	}
}

void do_ldflags(char *flags[],int n)
{
	do_cflags(flags,n);
}

void do_libs(char *flags[],int n)
{
int i,j;
	for(i=0;i<n;i++) {
		for(j=i+1;j<n;j++) {
			if (flags[i]!=NULL) {
				if (strcmp(flags[j],flags[i])==0) {
					flags[i]=NULL;
				}
			}
		}
	}
	for(i=0;i<n;i++) {
		if (flags[i]!=NULL) { printf(" %s",flags[i]); }
	}
}

