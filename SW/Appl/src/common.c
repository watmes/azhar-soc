#include "data_structures.h"
#include "common.h"

/*
 * Brief :
 * Free the linked list. If we don't free the list after
 * we finish processing a frame, we will run out of memory
 * and our program would crash after some frames.
 */
void freeObjectsLinkedList(struct object_detector_object * ptr){
	struct object_detector_object * tmp;

	while (ptr != NULL) {
		tmp = ptr;
		ptr = ptr->nextObject;
		free(tmp->type);
		free(tmp);
	}

}

