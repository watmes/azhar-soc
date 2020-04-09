
struct object_detector_object {
	char * type;
	uint16 distance; //in centimeter
	object_size_struct size;
	object_detector_object * nextObject;
}

struct object_identifier_object {
	object_detector_object * object;
	bool newObject;
	bool updateMap;
}
