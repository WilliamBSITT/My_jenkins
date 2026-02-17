/*
** EPITECH PROJECT, 2026
** My_jenkins
** File description:
** main
*/

#include <stdio.h>

int main(int argc, char *argv[]) {
    if (argc >= 2) {
        printf("Usage: %s\n", argv[0]);
        return 84;
    }
    printf("Hello, will!\n");
    return 0;
}
