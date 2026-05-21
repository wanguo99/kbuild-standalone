/* list.c - 简单链表实现 */
#include <stdlib.h>

struct list_node {
	void *data;
	struct list_node *next;
};

struct list_node *list_create_node(void *data)
{
	struct list_node *node = malloc(sizeof(struct list_node));
	if (node) {
		node->data = data;
		node->next = NULL;
	}
	return node;
}

void list_free_node(struct list_node *node)
{
	free(node);
}

int list_length(struct list_node *head)
{
	int len = 0;
	while (head) {
		len++;
		head = head->next;
	}
	return len;
}
