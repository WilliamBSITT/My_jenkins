##
## EPITECH PROJECT, 2026
## My_jenkins
## File description:
## Makefile
##

SRCDIR_serveur = src/

SRC_serv = $(shell find $(SRCDIR_serveur) -name '*.c')


OBJ_serv = $(SRC_serv:$(SRCDIR_server)/%.c=obj/%.o)

BINARY_serv = hello

DEBUG_FLAGS += -Wall -Wextra -pedantic -g


all: $(BINARY_serv)

$(BINARY_serv): $(OBJ_serv)
	gcc -o $@ $^  $(DEBUG_FLAGS)


obj/%.o: $(SRCDIR_server)/%.c
	mkdir -p $(dir $@)
	gcc -c $< -o $@  $(DEBUG_FLAGS)

clean:
	rm -rf obj

fclean: clean
	rm -f $(BINARY_serv)

re: fclean all

.PHONY: all clean fclean re
