
struct object_detector_Object {
	char * type;
	uint16 distance; //in centimeter
	object_size_struct size;
	object_detector_Object * NextObject;
}

struct object_identifier_Object {
	object_detector_Object * Object;
	bool NewObject;
	bool UpdateMap;
}
