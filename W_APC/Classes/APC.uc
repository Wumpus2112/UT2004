//-----------------------------------------------------------
//
//-----------------------------------------------------------
class APC extends ONSWheeledCraft;

defaultproperties
{
     WheelSoftness=0.040000
     WheelPenScale=1.500000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-9.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=0.700000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.400000
     GearRatios(1)=0.300000
     GearRatios(2)=0.500000
     GearRatios(3)=0.700000
     GearRatios(4)=0.800000
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     PassengerWeapons(0)=(WeaponPawnClass=Class'W_APC.APCPlasmaRibbonPawn',WeaponBone="turret_base")
     PassengerWeapons(1)=(WeaponPawnClass=Class'W_APC.APCSideGunPawn',WeaponBone="passenger03")
     PassengerWeapons(2)=(WeaponPawnClass=Class'W_APC.APCSideGunPawn',WeaponBone="passenger04")
     PassengerWeapons(3)=(WeaponPawnClass=Class'W_APC.APCSideGunPawn',WeaponBone="passenger05")
     PassengerWeapons(4)=(WeaponPawnClass=Class'W_APC.APCSideGunPawn',WeaponBone="passenger06")
     IdleSound=Sound'ONSVehicleSounds-S.PRV.PRVEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.PRV.PRVStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.PRV.PRVStop01'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.newPRVdead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathPRV'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=100.000000,Y=-10.000000,Z=35.000000)
     ImpactDamageMult=0.001000
     Begin Object Class=SVehicleWheel Name=RWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="right_tire01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="right_strut01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'W_APC.APC.RWheel1'

     Begin Object Class=SVehicleWheel Name=LWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="left_tire01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="left_strut01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'W_APC.APC.LWheel1'

     Begin Object Class=SVehicleWheel Name=RWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="right_tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="right_strut02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'W_APC.APC.RWheel2'

     Begin Object Class=SVehicleWheel Name=LWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="left_tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="left_strut02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'W_APC.APC.LWheel2'

     Begin Object Class=SVehicleWheel Name=RWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="right_tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="right_strut03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(4)=SVehicleWheel'W_APC.APC.RWheel3'

     Begin Object Class=SVehicleWheel Name=LWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="left_tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="left_strut03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(5)=SVehicleWheel'W_APC.APC.LWheel3'

     Begin Object Class=SVehicleWheel Name=RWheel4
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="right_tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="right_strut04"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(6)=SVehicleWheel'W_APC.APC.RWheel4'

     Begin Object Class=SVehicleWheel Name=LWheel4
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="left_tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="left_strut04"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(7)=SVehicleWheel'W_APC.APC.LWheel4'

     VehicleMass=7.000000
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bDriverHoldsFlag=False
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryPosition=(X=20.000000,Y=-60.000000,Z=10.000000)
     EntryRadius=190.000000
     FPCamPos=(X=20.000000,Y=-40.000000,Z=50.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.100000
     VehiclePositionString="in an APC"
     VehicleNameString="APC"
     ObjectiveGetOutDist=1500.000000
     FlagBone="Dummy01"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn04'
     GroundSpeed=500.000000
     HealthMax=1000.000000
     Health=1000
     Mesh=SkeletalMesh'APC_Anim.BTR80A'
     Skins(0)=Shader'APC_Tex.SkinD'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000,Z=-1.350000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'W_APC.APC.KParams0'

}
