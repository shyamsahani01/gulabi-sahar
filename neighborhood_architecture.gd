extends "res://heritage_kit.gd"
## Street-facing residential/shop shells near the reviewed destinations.
## Solid background buildings; only the restaurant and palace interiors are enterable.
func build(a: Dictionary) -> void:
	setup(a)
	var height: float=a.h
	var pink: bool=a.old
	var plaster: String="heritage_rose" if pink else "arch_cream"
	box(Vector3(0,height/2,0),Vector3(w,height,d),plaster,true)
	box(Vector3(0,.15,0),Vector3(w+.35,.3,d+.35),"arch_step")
	box(Vector3(0,height+.12,0),Vector3(w+.5,.24,d+.5),"heritage_lime")
	# Roof parapets have open sky behind them, rather than another solid cube.
	for side in [-1,1]:
		box(Vector3(side*w/2,height+.55,0),Vector3(.18,.8,d),plaster)
		box(Vector3(0,height+.55,side*d/2),Vector3(w,.8,.18),plaster)
		box(Vector3(0,height+1,side*d/2),Vector3(w+.2,.12,.35),"heritage_lime")
	shape(Vector3(w*.26,height+.7,-d*.2),Vector3(1.3,1.25,1.3),"arch_frame")
	var levels:=mini(4,maxi(1,int(height/3)))
	var bays:=maxi(1,mini(4,int(w/3.2)))
	for side in [-1,1]:
		var old_origin:=origin
		var old_basis:=basis
		basis*=Basis(Vector3.UP,PI if side<0 else 0)
		for level in levels:
			var y:=level*3.0
			box(Vector3(0,y+.1,d/2+.1),Vector3(w+.15,.17,.28),"heritage_lime")
			for bay in bays:
				var x: float=(bay-(bays-1)/2.0)*(w-.7)/bays
				if level==0:
					var bw: float=(w-.7)/bays-.2
					box(Vector3(x,1.25,d/2+.035),Vector3(bw,2.35,.07),"arch_walnut")
					for k in 9:
						box(Vector3(x,.25+k*.24,d/2+.08),Vector3(bw,.025,.035),"arch_frame")
					box(Vector3(x,2.85,d/2+.45),Vector3(bw+.12,.12,1.0),"heritage_red" if pink else "arch_green",false,Basis(Vector3.RIGHT,.1))
				else:
					framed_window(Vector3(x,y+.4,d/2+.09),minf(1.3,w*.2),1.65)
					if level==1 and bay%2==0:
						box(Vector3(x,y+.15,d/2+.4),Vector3(1.9,.18,.9),"heritage_lime")
						jali(Vector3(x,y+.62,d/2+.8),1.8,.75)
		# A drainpipe and shop-sign fascia give the elevation a believable scale.
		detail=true
		rod(Vector3(w/2-.18,.2,d/2+.16),Vector3(w/2-.18,height,d/2+.16),.045,"arch_frame")
		box(Vector3(0,2.52,d/2+.12),Vector3(w*.85,.38,.1),"heritage_ink")
		detail=false
		origin=old_origin
		basis=old_basis
	world.draw_detail=false
