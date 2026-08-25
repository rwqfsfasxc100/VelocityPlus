# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

const LOAD_RESOURCES = {
	"MicrowavesMeltOre/emp.gd": {"load_type": "script", "onready": false},
	"MVFSShaderStyles/SimulationLayer.gd": {"load_type": "script", "onready": false},
	"VariatedBroadcasts/ConversationPlayer.gd": {"load_type": "script", "onready": false},
	"CrewHider/CrewFaceOnEnceladus.gd": {"load_type": "script", "onready": false},
	"CrewHider/RestricedCrewList.gd": {"load_type": "script", "onready": false},
	"RemoveRingLimits/Escape Veloity.gd": {"load_type": "script", "onready": false},
	"RemoveRingLimits/Leaving Rings.gd": {"load_type": "script", "onready": false},
	"RemoveRingLimits/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"TurretOverrides/PDT.gd": {"load_type": "script", "onready": false},
	"RemoveWeaponGimbals/PDT.gd": {"load_type": "script", "onready": false},
	"ShowMarketValue/MineralMarket.tscn":{"load_type":"scene","original_path":"res://enceladus/MineralMarket.tscn","onready":false},
	"ScoopExtraReturnDialogue/DIALOG_SCOOP_RETURNING_1.tscn":{"load_type":"scene","original_path":"res://comms/conversation/subtrees/DIALOG_SCOOP_RETURNING_1.tscn","onready":false},
	"BetterTooltips/DoTradeIn.gd": {"load_type": "script", "onready": false},
	"HideUndamagedEquipment/SystemShipRepairUI.gd": {"load_type": "script", "onready": false},
	"BetterTooltips/SystemShipRepairUI.tscn":{"load_type":"scene","original_path":"res://enceladus/SystemShipRepairUI.tscn","onready":false},
	"AchievementEnabler/AchievementAbstract.gd": {"load_type": "script", "onready": false},
	"ExtendedCrewIdentificationLimits/AutopilotOverlay.gd": {"load_type": "script", "onready": false},
	"ArmTargetToAutopilot/DockingArm.gd": {"load_type": "script", "onready": false},
	"DisplayNegativeDepth/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"ExtraOMSDisplays/OMS.gd": {"load_type": "script", "onready": false},
	"ExtraOMSDisplays/CurrentGame.gd": {"load_type": "script", "onready": false},
	"ExtraOMSDisplays/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"ShowEquipmentReliability/Upgrades.gd": {"load_type": "script", "onready": false},
	"PilotsReduceAstrogationCalcTime/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"ScoopAutoReturnProtocol/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"DisablePilotAutoAdrenaline/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"ToggleSystemsAtEnceladus/SystemList.gd": {"load_type": "script", "onready": false},
	"ToggleSystemsAtEnceladus/Tuning.gd": {"load_type": "script", "onready": false},
	"ToggleSystemsAtEnceladus/ship-ctrl.gd": {"load_type": "script", "onready": false},
	"MaxAstrogatorTrackingTime/CurrentGame.gd": {"load_type": "script", "onready": false},
	"DisableMaintDroneSanBUS/drone-plant.gd": {"load_type": "script", "onready": false},
	"TemperatureBasedThrust/thruster.gd": {"load_type": "script", "onready": false},
	"NaturalTimeSkip/CurrentGame.gd": {"load_type": "script", "onready": false},
	"AutoRepairs/Repairs.gd": {"load_type": "script", "onready": false},
	"StationTransferSpeed/TradingHub.gd": {"load_type": "script", "onready": false},
	"AllHudEMPResist/Display-K37.gd":{"load_type":"script","onready":false},
	"AllHudEMPResist/Display-K225.gd":{"load_type":"script","onready":false},
	"AllHudEMPResist/Display-Prospector.gd":{"load_type":"script","onready":false},
	"OCPVoyagerFix/ocp-209.tscn":{"load_type":"scene","original_path":"res://ships/ocp-209.tscn","onready":false,"config":{"id":"VelocityPlus","section":"VP_SHIPS","entry":"fix_voyager_MPU_in_OCP"}},
	"ShowCrewAgenda/CrewBio.gd":{"load_type":"script","onready":false},
	"ShowCrewAgenda/CrewBio.tscn":{"load_type":"scene","original_path":"res://enceladus/CrewBio.tscn"},
}
