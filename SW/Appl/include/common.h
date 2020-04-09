#include "data_structures.h"


/*
 * Brief :
 * Free the linked list. If we don't free the list after
 * we finish processing a frame, we will run out of memory
 * and our program would crash after some frames.
 */
void freeObjectsLinkedList(struct object_detector_object * ptr);
