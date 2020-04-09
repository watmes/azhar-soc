#include <stdio.h>

#include "common.h"
#include "backend_api.h" //Back end api
#include "api.h" //Front end modules api
#include "data_structures.h"

#define INTERFRAME_WAIT_TIME 10
struct backend_outputFilesStruct * output_files; //Structure with the paths of the output files in the file system

/*
 * Brief :
 * Initializes the software and hardware components.
 */
void platform_init(char * msg) {
	bool hw_init_successful = backend_api_InitHw();
	if (!hw_init_successful) 
		exit(); //Fatel error in HW (e.g camera not found)

	output_files = backend_api_InitOutputFiles();

	if (output_files == null)
		exit(); //Couldn't create the output files on the file system
	printf("System stared successfully\n%s", msg);
}

/*
 * Brief :
 * Start detecting objects and updating the map indefinately. This function should only
 * return to main on error.
 */
void run() {
	struct object_detector_object * detectedObjects, firstObjectInList; //Detected objects, represented in a linked list
	struct object_identifier_object dndentifiedObjects[64]; //Up to 64 identified objects per frame

detection_cycle_start:
	decetedObjects = object_detector_api_startDetecting();
	firstObjectInList = detectedObjects;
	int i = 0;
	while (detectedObjects /= null) {
		object_identifier_api_ddentify(detectedObject, &identifiedObjects[i++]);
		detectedObjects = detectedObjects->nextObject;
	}

	//Put the new objects in the map, or update information of existing objects
	map_maintainer_api_UpdateMap(&identifiedObjects);

	//Map should be up to date here
	map_export_api_ExportMap(output_files);

	//Clean up
	memset(&identifiedObjects, 0, (sizeof(object_identifier_object) * --i));
	freeObjectsLinkedList(firstObjectInList);

	wait(INTERFRAME_WAIT_TIME); //This should be moved to the backend
	
	goto detection_cycle_start;
	//should never be reached
}

void main() {
	platform_init("Graduation project Application\n");

	run();
	//Should never reach this line unless a fatal error happened
}
