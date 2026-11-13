
/*
 * ==========================================
 * Calendar Program
 *
 * Stage 7: C Language Implementation
 *
 * Year: 1900 - 2099
 * Month: 1 - 12
 *
 * ==========================================
 */

#include <stdio.h>


/* ==========================================
   Function 1: Determine whether a year is leap
   ========================================== */

int is_leap_year(int year)
{
    /*
     * Leap year rules:
     * 1. Divisible by 400: leap year
     * 2. Divisible by 4 but not by 100: leap year
     */

    if (year % 400 == 0)
    {
        return 1;
    }

    if (year % 100 == 0)
    {
        return 0;
    }

    if (year % 4 == 0)
    {
        return 1;
    }

    return 0;
}


/* ==========================================
   Function 2: Calculate days in a month
   ========================================== */

int days_in_month(int year, int month)
{
    int days[12] =
    {
        31, 28, 31, 30, 31, 30,
        31, 31, 30, 31, 30, 31
    };

    /*
     * February has 29 days in a leap year.
     */

    if (month == 2 && is_leap_year(year))
    {
        return 29;
    }

    return days[month - 1];
}


/* ==========================================
   Function 3: Calculate first weekday
   ========================================== */

/*
 * Sunday = 0
 * Monday = 1
 * Tuesday = 2
 * Wednesday = 3
 * Thursday = 4
 * Friday = 5
 * Saturday = 6
 *
 * January 1, 1900 was Monday.
 */

int first_weekday(int year, int month)
{
    int total_days = 0;

    int y;
    int m;

    /*
     * Step 1:
     * Calculate days in previous years.
     */

    for (y = 1900; y < year; y++)
    {
        if (is_leap_year(y))
        {
            total_days += 366;
        }
        else
        {
            total_days += 365;
        }
    }

    /*
     * Step 2:
     * Calculate days in previous months
     * of the current year.
     */

    for (m = 1; m < month; m++)
    {
        total_days += days_in_month(year, m);
    }

    /*
     * January 1, 1900 was Monday.
     * Monday = 1, Sunday = 0.
     */

    return (total_days + 1) % 7;
}


/* ==========================================
   Function 4: Print calendar
   ========================================== */

void print_calendar(int year, int month)
{
    int weekday;
    int total_days;

    int day;
    int i;

    /*
     * Month name table.
     */

    const char *month_names[12] =
    {
        "January", "February", "March",
        "April", "May", "June",
        "July", "August", "September",
        "October", "November", "December"
    };

    /*
     * Calculate first weekday and month length.
     */

    weekday = first_weekday(year, month);

    total_days = days_in_month(year, month);

    /*
     * Display year and month.
     */

    printf("\n%d %s\n", year, month_names[month - 1]);

    /*
     * Display weekday title.
     */

    printf("Su Mo Tu We Th Fr Sa\n");

    /*
     * Print leading blank positions.
     */

    for (i = 0; i < weekday; i++)
    {
        printf("   ");
    }

    /*
     * Print all dates.
     */

    for (day = 1; day <= total_days; day++)
    {
        printf("%2d ", day);

        /*
         * Move to next line after Saturday.
         */

        if ((weekday + day) % 7 == 0)
        {
            printf("\n");
        }
    }

    /*
     * Print final newline if necessary.
     */

    if ((weekday + total_days) % 7 != 0)
    {
        printf("\n");
    }
}


/* ==========================================
   Main Function
   ========================================== */

int main(void)
{
    int year;
    int month;

    /*
     * Input year.
     */

    printf("Please input year (1900-2099): ");

    if (scanf("%d", &year) != 1)
    {
        printf("Invalid input!\n");
        return 1;
    }

    /*
     * Check year range.
     */

    if (year < 1900 || year > 2099)
    {
        printf("Invalid input!\n");
        return 1;
    }

    /*
     * Input month.
     */

    printf("Please input month (1-12): ");

    if (scanf("%d", &month) != 1)
    {
        printf("Invalid input!\n");
        return 1;
    }

    /*
     * Check month range.
     */

    if (month < 1 || month > 12)
    {
        printf("Invalid input!\n");
        return 1;
    }

    /*
     * Print complete calendar.
     */

    print_calendar(year, month);

    return 0;
}