#include <string.h>

int compare_str (const void *data1, const void *data2)
{
	const char *s1 = (const char *) data1;
	const char *s2 = (const char *) data2;
	return strcmpi (s1, s2);
}
