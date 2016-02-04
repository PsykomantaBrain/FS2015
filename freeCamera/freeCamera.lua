
print("////////////////// FreeCamera mod (by HarvesteR) ///////////////////")

VehicleCamera.updateRotateNodeRotation = function(self)
	local rotY = self.rotY;
	if self.rotYSteeringRotSpeed ~= 0 and self.vehicle.rotatedTime ~= nil then
		rotY = rotY + self.vehicle.rotatedTime*self.rotYSteeringRotSpeed;
	end

	local upx,upy,upz = 0,1,0;

	local dx,dy,dz = 0,0,1; --localDirectionToWorld(getParent(self.rotateNode), 0,0,1);
	local invLen = 1/math.sqrt(dx*dx + dz*dz);
	dx = dx*invLen;
	dz = dz*invLen;

	local newDx = math.cos(self.rotX) * (math.cos(rotY)*dx + math.sin(rotY)*dz);
	local newDy = -math.sin(self.rotX);
	local newDz = math.cos(self.rotX) * (-math.sin(rotY)*dx + math.cos(rotY)*dz);

	newDx,newDy,newDz = worldDirectionToLocal(getParent(self.rotateNode), newDx,newDy,newDz);
	upx,upy,upz = worldDirectionToLocal(getParent(self.rotateNode), upx,upy,upz);

	setDirection(self.rotateNode, newDx,newDy,newDz, upx,upy,upz);
	
	-- if self.useWorldXZRotation then
	-- 	
	-- else
	-- 	setRotation(self.rotateNode, self.rotX, rotY, self.rotZ);
	-- end;
end;