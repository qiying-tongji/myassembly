#include <stdio.h>

/* 使用128位整数保存斐波那契数 */
typedef unsigned __int128 BigInt;

/* 递归计算斐波那契数列 */
void fib(int n, BigInt *a, BigInt *b)
{
    if (n == 0)
    {
        *a = 0;
        *b = 1;
        return;
    }

    /* 递归调用 */
    fib(n - 1, a, b);

    /* 计算当前斐波那契数 */
    BigInt temp = *a;
    *a = *b;
    *b = temp + *b;
}

/* 输出128位整数 */
void printBigInt(BigInt num)
{
    char digits[40];
    int count = 0;

    if (num == 0)
    {
        printf("0");
        return;
    }

    while (num > 0)
    {
        digits[count++] = '0' + num % 10;
        num /= 10;
    }

    while (count > 0)
    {
        putchar(digits[--count]);
    }
}

int main(void)
{
    int n;
    BigInt a = 0, b = 1;

    printf("Please input n (1-100): ");

    scanf("%d", &n);

    if (n < 1 || n > 100)
    {
        printf("Invalid input!\n");
        return 1;
    }

    fib(n, &a, &b);

    printf("Fibonacci number: ");
    printBigInt(a);
    printf("\n");

    return 0;
}