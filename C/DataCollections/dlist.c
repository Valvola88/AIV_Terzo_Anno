#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>


typedef struct aiv_list_node list_node;
typedef struct aiv_int_node int_node;

struct aiv_list_node
{
    list_node *prev;
    list_node *next;
    int count;
};

struct aiv_int_node
{
    list_node node;
    int value;
};

unsigned int list_get_len(list_node* head){
    return head->count;
}

list_node *list_get_tail(list_node *head)
{
    if (!head)
        return NULL;

    list_node* current_item = head;
    list_node* last_item = head;

    while (current_item)
    {
        last_item = current_item;
        current_item = current_item->next;
    }
    
    return last_item;
    
}

list_node *list_append (list_node **head, list_node *item)
{
    list_node *tail = list_get_tail(*head);
    if (!tail)
    {
        *head = item;
        (*head)->count = 1;
    }
    else
    {
        tail->next = item;
    (*head)->count++;
    }

    item->prev = tail;
    item->next = NULL;

    return item;
}

list_node* list_get_pos(list_node** head, const  int pos)
{
    if (pos >= list_get_len(*head))
        return NULL;
    
    unsigned int curr_num = pos;
    list_node* return_item = *head;
    while (curr_num > 0)
    {
        return_item = return_item->next;
        curr_num--;
    }

    return return_item;
}

list_node *list_append_after (list_node **head, list_node *item, const int pos)
{
    if (pos < 0 || pos > list_get_len(*head) - 1)
        return NULL;

    if (pos == list_get_len(*head) - 1)
    {
        list_node* prev_node = list_get_tail(*head);

        prev_node->next = item;
        item->prev = prev_node;
        item->next = NULL;
        
    }
    else 
    {
        list_node* prev_node = list_get_pos(head, pos);
        list_node* next_node = prev_node->next;

        prev_node->next = item;
        next_node->prev = item;
        item->prev = prev_node;
        item->next = next_node;
    }
    
    (*head)->count++;

    return item;
}

list_node *list_insert_before (list_node **head, list_node *item, const int pos)
{
    if (pos < 0 || pos > list_get_len(*head))
        return NULL;

    if (pos == 0)
    {
        list_node* next_item = (*head);

        next_item->prev = item;
        item->prev = NULL;
        item->next = next_item;

        item->count = next_item->count;

        *head = item;
        
    }
    else 
    {
        list_node* next_node = list_get_pos(head, pos);
        list_node* prev_node = next_node->prev;

        prev_node->next = item;
        next_node->prev = item;
        item->prev = prev_node;
        item->next = next_node;
    }
    
    (*head)->count++;

    return item;
}

void aiv_print_list(list_node* head, const char list_type)
{
    list_node* curr_item = head;
    if (list_type == 'i')
    {
        while (curr_item)
        {
            printf("[%d]", (*(int_node*)curr_item).value);
            curr_item = curr_item->next;
        }
    }
    printf("\n"); 
}

void aiv_shuffle_list(list_node **head)
{
    list_node *curr_node = *head;
    const unsigned int l = list_get_len(*head);

    list_node *ord_node_list[l];
    int ord_list[l];
    int shf_list[l];

    for(int i  =0 ; i< l; i++)
    {
        ord_list[i] = i;
        ord_node_list[i] = curr_node;
        curr_node = curr_node->next;
        ord_node_list[i]->prev = NULL;
        ord_node_list[i]->next = NULL;
    }
    for(int i = 0;  i<l; i++)
    {
        int t = -1;
        while (t == -1)
        {
            int r = rand()%l;
            t = ord_list[r];
        }

        ord_list[t] = -1;
        shf_list[i] = t;
        printf("[%i]", shf_list[i]);
    }

    *head = NULL;
    for(int i = 0; i < l; i++)
    {
        list_append(head, ord_node_list[shf_list[i]]);
    }

    printf("\n");

}

int main(int argc, char** argv)
{
    srand(time(NULL));
    list_node *head = NULL;

    int_node arr[8];

    for (int i = 0 ; i < 8; i++)
    {
        arr[i].value = (i + 1) * 100;
        list_append(&head, &arr[i]);
    }

    aiv_print_list(head, 'i');

    int_node i1;
    i1.value = 150;
    int_node i2;
    i2.value = 250;

    list_insert_before(&head, &i1, 3);
    list_append_after(&head, &i2, 6);
    aiv_print_list(head, 'i');

    aiv_shuffle_list(&head);
    aiv_print_list(head, 'i');
    printf("(%i)\n",list_get_len(head));
    printf("{%i}",((int_node*)list_get_pos(&head, 3))->value);
}