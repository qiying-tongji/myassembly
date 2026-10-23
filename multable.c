#include <stdio.h>

void print_item(int i, int j)
{
    printf("%d*%d=%d  ", i, j, i * j);
}

int main(void)
{
    int i, j;

    printf("The 9 multiplication table:\n");

    for (i = 9; i >= 1; i--)
    {
        for (j = 1; j <= i; j++)
        {
            print_item(i, j);
        }

        printf("\n");
    }

    return 0;
}