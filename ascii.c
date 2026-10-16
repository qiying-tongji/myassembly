#include <stdio.h>

int main(void)
{
    char ch;

    // 遍历所有小写英文字母
    for (ch = 'a'; ch <= 'z'; ch++)
    {
        printf("%c ", ch);

        // 每输出 13 个字母就换行
        if ((ch - 'a' + 1) % 13 == 0)
        {
            printf("\n");
        }
    }

    return 0;
}