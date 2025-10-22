extends Node


const cradle_left = {
	"system":"SYSTEM_CRADLE-L",
	"name_override":"SYSTEM_CRADLE",
	"manual":"SYSTEM_CRADLE_MANUAL",
	"specs":"SYSTEM_CRADLE_SPECS",
	"price":2500,
	"alignment":"ALIGNMENT_LEFT",
	"test_protocol":"detach",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER",
	"slot_type":"HARDPOINT",
	"config":{
		"id":"VelocityPlus",
		"section":"VP_ENCELADUS",
		"entry":"add_empty_cradle_equipment"
	},
	"weapon_slot":{
		"path":"res://VelocityPlus/weapons/EmptyCradle-L.tscn",
		"data":[
			{
				"property":"position",
				"value":"Vector2( 0, 196 )"
			},
			{
				"property":"flip",
				"value":"true"
			}
		]
	}
}
const cradle_right = {
	"system":"SYSTEM_CRADLE-R",
	"name_override":"SYSTEM_CRADLE",
	"manual":"SYSTEM_CRADLE_MANUAL",
	"specs":"SYSTEM_CRADLE_SPECS",
	"price":2500,
	"alignment":"ALIGNMENT_RIGHT",
	"test_protocol":"detach",
	"equipment_type":"EQUIPMENT_CARGO_CONTAINER", 
	"slot_type":"HARDPOINT",
	"weapon_slot":{
		"path":"res://VelocityPlus/weapons/EmptyCradle.tscn",
		"data":[
			{
				"property":"position",
				"value":"Vector2( 0, 196 )"
			}
		]
	}
}
