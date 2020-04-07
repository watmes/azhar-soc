#include <stdio.h>

#include "common.h"
#include "backend_api.h" //Back end api
#include "api.h" //Front end modules api
#include "data_structures.h"

#define INTERFRAME_WAIT_TIME 10
struct backend_OutputFilesStruct * output_files; //Structure with the paths of the output files in the file system

void platform_init(char * msg) {
	bool hw_init_successful = backend_api_InitHw();
	if (!hw_init_successful) 
		exit(); //Fatel error in HW (e.g camera not found)

	output_files = backend_api_InitOutputFiles();

	if (output_files == null)
		exit(); //Couldn't create the output files on the file system
	printf("System stared successfully\n%s", msg);
}

void platform_run() {
	while (1) {
		struct object_detector_Object * DetectedObjects = object_detector_api_StartDetecting(); //Unlimited detected objects, represented in a linked list
	
		struct object_identifier_Object IndentifiedObjects[64]; //Up to 64 identified objects per frame
		int i = 0;
		while (DetectedObjects->ObjectType /= null) {
			object_identifier_api_Identify(DetectedObject,&IdentifiedObjects[i++]);
			DetectedObjects = DetectedObjects->NextObject;
		}

		//Put the new objects in the map, or update information of existing objects
		map_maintainer_api_UpdateMap(&IdentifiedObjects);

		//Map should be up to date here
		map_export_api_ExportMap(output_files);

		wait(INTERFRAME_WAIT_TIME);
	}
	//should never be reached
}

void main() {
	platform_init("Graduation project Application\n");

	platform_run();
	//Should never reach this line unless a fatal error happened
}
