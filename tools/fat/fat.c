#include <stdio.h>
#include 


typedef struct{
	uint8_t bdb_oem;
	uint16_t bdb_bytes_per_sector;
	uint8_t bdb_sectors_per_cluster;
	uint16_t bdb_reserved_sectors;
	uint8_t bdb_fat_count;
	uint16_t bdb_dir_entries_count;
	uint16_t bdb_total_sectors;
	uint8_t bdb_media_descriptor_type;
	uint16_t bdb_sectors_per_fat;
	uint16_t bdb_sectors_per_track;
	uint16_t bdb_heads;
	uint32_t bdb_hidden_sectors;
	uint32_t bdb_large_sector_count;

	uint8_t ebr_drive_number;
	uint8_t ebr_signiture;
	uint8_t ebr_volume_id;
	uint8_t ebr_volume_label;           
	uint8_t ebr_system_id;
} BootSector;

bool readBootSector(FILE* disk){
	
}

int main(int argc, char** argv){
	if(argc < 3){
		printf("Syntax: %s <disk image> <file name>\n", argv[0]);
		return -1;
	}
	
	FILE* disk = fopen(argv[1], "rb");

	return 0;
}
