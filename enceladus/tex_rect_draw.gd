extends TextureRect

var do_draw = false
var obj_pos = false
var obj = null

var ship

func _draw():
	if obj_pos and obj:
		var ship_pos = ship.global_position
		var vp_pos = Vector2(-ship_pos.y,ship_pos.x)
		var i_pos = ship.get_node(obj).position
		var item_pos = Vector2(-i_pos.y,i_pos.x)
		var abs_item_pos = vp_pos + item_pos
		var vp = ship.get_viewport()
		var vpip = vp.get_visible_rect()
		var ip = ship.get_viewport_transform()
		var vp_scale = vpip.size/ip[2]
		var center = ip[2]/2
		var relative = abs_item_pos/vp_scale
		var cir_pos = relative + center
#		var rot_pos = Vector2(cir_pos.y,-cir_pos.x)
		draw_arc(cir_pos,5,0,PI*2,1024,Color(0,1,0,1),5)
	
	
	
	
	
	
	
	
	pass
	
	
	
	
#	if false:
#		var ps = CurrentGame.getPlayerShip()
#		var points = ps.getCollider()[0]
#		var np = PoolVector2Array([])
#		var bb = Rect2(0,0,0,0)
#		var size = rect_size * 0.75
#		var soffset = rect_size * 0.125
#		for point in points.polygon:
#			var vec = point# + size
#			np.append(vec)
#			if vec.x < bb.position.x:
#				bb.position.x = vec.x
#			if vec.y < bb.position.y:
#				bb.position.y = vec.y
#			if vec.x > bb.size.x:
#				bb.size.x = vec.x
#			if vec.y > bb.size.y:
#				bb.size.y = vec.y
#		var width = abs(bb.size.x) + abs(bb.position.x)
#		var height = abs(bb.size.y) + abs(bb.position.y)
#		var scaleDiff = Vector2(1,1)
#		if width > size.x or height > size.y:
#			var widthDiff = width / size.x
#			var heightDiff = height / size.y
#			if widthDiff > heightDiff:
#				scaleDiff = Vector2(widthDiff,widthDiff)
#			else:
#				scaleDiff = Vector2(heightDiff,heightDiff)
#		var poly2 = PoolVector2Array([])
#		for poly in np:
#			var rescale = poly / scaleDiff
#			var offset = rescale - (bb.position/scaleDiff)
#			var f = offset + Vector2((rect_size.x - width)/2,soffset.y)
#			poly2.append(f)
#		draw_rect(Rect2(Vector2(0,0),rect_size),Color(0,0,0,1))
#		draw_polyline(poly2,Color(0,1,0,1),5)
#		if obj_pos != null and typeof(obj_pos) == TYPE_VECTOR2:
#			var pv = scale_poly(PoolVector2Array([obj_pos]),scaleDiff)[0]
#			pv.x += (size.x/2)
#			pv.y += (size.y * 0.55)
#			draw_arc(pv,5,0,PI*2,1024,Color(0,0,2,1),5)

func scale_poly(poly,scale):
	var np = PoolVector2Array([])
	for point in poly:
		np.append(Vector2(point.x / scale.x, point.y / scale.y))
	return np
