--

print("  moreDrivingAxes v0.1");


Drivable.updateTick = function(self, dt)
    if self:getIsActive() then
        local xt,yt,zt = getTranslation(self.components[1].node);
        local deltaWater = yt-g_currentMission.waterY+2.5;
        if deltaWater < 0 then
            self.isBroken = true;
            g_currentMission:onSunkVehicle(self);

            if self.isEntered then
                g_currentMission:onLeaveVehicle();

                if self:getIsActiveForSound() then
                    local volume = math.min(1, self:getLastSpeed()/30);
                    if self.waterSplashSample == nil then
                        self.waterSplashSample = createSample("waterSplashSample");
                        loadSample(self.waterSplashSample, "data/maps/sounds/waterSplash.wav", false);
                    end;
                    playSample(self.waterSplashSample, 1, volume, 0);
                end;
            end;
        end;
        self.showWaterWarning = deltaWater < 2;

        if self.attacherJointLowerCombo ~= nil and self.attacherJointLowerCombo.isRunning then
            for k, joint in pairs(self.attacherJointLowerCombo.joints) do
                if self.attacherJointLowerCombo.direction == 1 and self.attacherJointLowerCombo.currentTime >= joint.t then
                    self:lowerImplementByJointIndex(joint.jointIndex, true);
                elseif self.attacherJointLowerCombo.direction == -1 and self.attacherJointLowerCombo.currentTime <= self.attacherJointLowerCombo.duration-joint.t then
                    self:lowerImplementByJointIndex(joint.jointIndex, false);
                end;
            end;

            if (self.attacherJointLowerCombo.direction == -1 and self.attacherJointLowerCombo.currentTime == 0) or
               (self.attacherJointLowerCombo.direction == 1  and self.attacherJointLowerCombo.currentTime == self.attacherJointLowerCombo.duration) then
                self.attacherJointLowerCombo.isRunning = false;
            end;

            self.attacherJointLowerCombo.currentTime = Utils.clamp(self.attacherJointLowerCombo.currentTime + dt*self.attacherJointLowerCombo.direction, 0, self.attacherJointLowerCombo.duration);
        end;

        -- lock max speed to working tool
        local speed,_ = self:getSpeedLimit(true);
        if self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE then
            speed = math.min(speed, self.cruiseControl.speed);
        end;
        self.motor:setSpeedLimit(speed); --math.min(self.cruiseControl.tempSpeed, speed));
    end;

    if self.isEntered and self.isClient then
        local axisForward = InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
		
        if InputBinding.isAxisZero(axisForward) then
            self.axisForward = InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE);
			self.axisForward = Utils.clamp(self.axisForward + InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_FORWARD_VEHICLE_ALT), -1, 1);
			
            if not InputBinding.isAxisZero(self.axisForward) then
                self.axisForwardIsAnalog = true;
            end
            self.lastDigitalForward = 0;
            if math.abs(self.axisForward) > 0.1 and g_gui.currentGuiName ~= "ChatDialog" then
                self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF);
            end;
        else
            self.axisForward = Utils.clamp(self.lastDigitalForward + dt/self.axisSmoothTime*axisForward, -1, 1);
            self.axisForwardIsAnalog = false;
            self.lastDigitalForward = self.axisForward;
            if g_gui.currentGuiName ~= "ChatDialog" then
                self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF);
            end;
        end;
		
        self.axisSide = InputBinding.getDigitalInputAxis(InputBinding.AXIS_MOVE_SIDE_VEHICLE);
        if InputBinding.isAxisZero(self.axisSide) then
            self.axisSide = InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_SIDE_VEHICLE);
			self.axisSide = Utils.clamp(self.axisSide + InputBinding.getAnalogInputAxis(InputBinding.AXIS_MOVE_SIDE_VEHICLE_ALT), -1, 1);
			
            if not InputBinding.isAxisZero(self.axisSide) then
                self.axisSideIsAnalog = true;
            end
        else
            self.axisSideIsAnalog = false;
        end;

        if not self:getIsActiveForInput(false) then
            if not self.axisSideIsAnalog then
                self.axisSide = 0;
            end
            if not self.axisForwardIsAnalog then
                self.axisForward = 0;
            end

            if self.steeringEnabled then
                if g_gui.currentGui ~= nil and g_gui.currentGuiName ~= "ChatDialog" then
                    self:setCruiseControlState(Drivable.CRUISECONTROL_STATE_OFF);
                end;
            end;
        end

        if g_isServerStreamingVersion then self.axisSide = self.axisSide * 0.5; end;   -- This is the factor to slow down the steering

        if self.isServer then
            if self.steeringEnabled then
                Drivable.updateVehiclePhysics(self, self.axisForward, self.axisForwardIsAnalog, self.axisSide, self.axisSideIsAnalog, dt);
            end;
        else
            self:raiseDirtyFlags(self.drivableGroundFlag);
        end;
    end;
end;