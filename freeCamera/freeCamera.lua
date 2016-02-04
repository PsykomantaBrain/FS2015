
print("////////////////// FreeCamera mod (by HarvesteR) ///////////////////")

cameras = {}

VehicleCamera.updateRotateNodeRotation = function(self)
	local rotY = self.rotY;
	if self.rotYSteeringRotSpeed ~= 0 and self.vehicle.rotatedTime ~= nil then
		rotY = rotY + self.vehicle.rotatedTime*self.rotYSteeringRotSpeed;
	end

	
	if getUpdatedToggles(self) then
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
	else
		if self.useWorldXZRotation then
			
			local upx,upy,upz = 0,1,0;

			local dx,dy,dz = localDirectionToWorld(getParent(self.rotateNode), 0,0,1);
			local invLen = 1/math.sqrt(dx*dx + dz*dz);
			dx = dx*invLen;
			dz = dz*invLen;

			local newDx = math.cos(self.rotX) * (math.cos(rotY)*dx + math.sin(rotY)*dz);
			local newDy = -math.sin(self.rotX);
			local newDz = math.cos(self.rotX) * (-math.sin(rotY)*dx + math.cos(rotY)*dz);

			newDx,newDy,newDz = worldDirectionToLocal(getParent(self.rotateNode), newDx,newDy,newDz);
			upx,upy,upz = worldDirectionToLocal(getParent(self.rotateNode), upx,upy,upz);

			setDirection(self.rotateNode, newDx,newDy,newDz, upx,upy,upz);
			
			
		else
			setRotation(self.rotateNode, self.rotX, rotY, self.rotZ);
		end;
	end;
end;

function getUpdatedToggles(cam)	
	
		if cameras[cam] == nil then
			cameras[cam] = false
		end;
	
		if InputBinding.hasEvent(InputBinding.cameraFrameOfReference) then	
			cameras[cam] = not cameras[cam];	
		end;
		
		return cameras[cam];	
end;