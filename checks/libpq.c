#include <libpq-fe.h>

int main()
{
PGconn *conn;
	conn=PQconnectdb("dbname=template1");
	PQfinish(conn);
return 0;
}


