// Created by Crowbar 0.71

$modelname "player/amongus/engineer/engineer.mdl"

$model "engineer" "engineer_morphs_low.smd" {

	flexfile "engineer_01.vta" 
	{
		defaultflex frame 0
		flex "N" frame 1
		flex "MB" frame 2
		flex "PP" frame 3
		flex "DS" frame 4
		flex "GK" frame 5
		flex "T" frame 6
		flex "TH" frame 7
		flex "SH" frame 8
		flex "OO" frame 9
		flex "OH" frame 10
		flex "WQ" frame 11
		flex "FV" frame 12
		flex "UH" frame 13
		flex "AW" frame 14
		flex "AH" frame 15
		flex "AH2" frame 16
		flex "AE" frame 17
		flex "AE2" frame 18
		flex "IH" frame 19
		flex "Y" frame 20
		flex "EE" frame 21
		flex "ER" frame 22
		flex "silence1" frame 23
		flex "happySmall" frame 24
		flex "madUpper" frame 25
		flex "specialAction01Upper" frame 26
		flex "defaultFaceUpper" frame 27
		flex "scaredUpper" frame 28
		flex "painBigUpper" frame 29
		flex "painSmallUpper" frame 30
		flex "happyBigUpper" frame 31
		flex "happySmallUpper" frame 32
		flex "specialAction01" frame 33
		flex "defaultFace" frame 34
		flex "scared" frame 35
		flex "mad" frame 36
		flex "painBig" frame 37
		flex "painSmall" frame 38
		flex "happyBig" frame 39
		flex "happyBigClosed" frame 40
	}

	flexcontroller happySmall range 0 1 "happySmall"
	flexcontroller happySmallUpper range 0 1 "happySmallUpper"
	flexcontroller specialAction01Upper range 0 1 "specialAction01Upper"
	flexcontroller painSmall range 0 1 "painSmall"
	flexcontroller ER range 0 1 "ER"
	flexcontroller AE2 range 0 1 "AE2"
	flexcontroller happyBigClosed range 0 1 "happyBigClosed"
	flexcontroller painBig range 0 1 "painBig"
	flexcontroller EE range 0 1 "EE"
	flexcontroller silence1 range 0 1 "silence1"
	flexcontroller scared range 0 1 "scared"
	flexcontroller defaultFace range 0 1 "defaultFace"
	flexcontroller specialAction01 range 0 1 "specialAction01"
	flexcontroller madUpper range 0 1 "madUpper"
	flexcontroller silence range 0 1 "silence"
	flexcontroller happyBigUpper range 0 1 "happyBigUpper"
	flexcontroller IH range 0 1 "IH"
	flexcontroller Y range 0 1 "Y"
	flexcontroller painBigUpper range 0 1 "painBigUpper"
	flexcontroller painSmallUpper range 0 1 "painSmallUpper"
	flexcontroller mad range 0 1 "mad"
	flexcontroller happyBig range 0 1 "happyBig"
	flexcontroller defaultFaceUpper range 0 1 "defaultFaceUpper"
	flexcontroller scaredUpper range 0 1 "scaredUpper"
	flexcontroller N range 0 1 "N"
	flexcontroller MB range 0 1 "MB"
	flexcontroller PP range 0 1 "PP"
	flexcontroller DS range 0 1 "DS"
	flexcontroller GK range 0 1 "GK"
	flexcontroller T range 0 1 "T"
	flexcontroller TH range 0 1 "TH"
	flexcontroller SH range 0 1 "SH"
	flexcontroller OO range 0 1 "OO"
	flexcontroller OH range 0 1 "OH"
	flexcontroller WQ range 0 1 "WQ"
	flexcontroller FV range 0 1 "FV"
	flexcontroller UH range 0 1 "UH"
	flexcontroller AW range 0 1 "AW"
	flexcontroller AH range 0 1 "AH"
	flexcontroller AH2 range 0 1 "AH2"
	flexcontroller AE range 0 1 "AE"

	localvar silence
	%N = N
	%MB = MB
	%PP = PP
	%DS = DS
	%GK = GK
	%T = T
	%TH = TH
	%SH = SH
	%OO = OO
	%OH = OH
	%WQ = WQ
	%FV = FV
	%UH = UH
	%AW = AW
	%AH = AH
	%AH2 = AH2
	%AE = AE
	%AE2 = AE2
	%IH = IH
	%Y = Y
	%EE = EE
	%ER = ER
	%silence = silence
	%silence1 = silence1
	%happySmall = happySmall
	%madUpper = madUpper
	%specialAction01Upper = specialAction01Upper
	%defaultFaceUpper = defaultFaceUpper
	%scaredUpper = scaredUpper
	%painBigUpper = painBigUpper
	%painSmallUpper = painSmallUpper
	%happyBigUpper = happyBigUpper
	%happySmallUpper = happySmallUpper
	%specialAction01 = specialAction01
	%defaultFace = defaultFace
	%scared = scared
	%mad = mad
	%painBig = painBig
	%painSmall = painSmall
	%happyBig = happyBig
	%happyBigClosed = happyBigClosed
}
$bodygroup "hat"
{
	studio "hat_bodygroup.smd"
	blank
}
$bodygroup "rightarm"
{
	studio "glove_bodygroup.smd"
	studio "robotarm_bodygroup.smd"
	blank
}

$lod 11
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod1.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod1.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod1.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod1.smd"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	facial
}
$lod 22
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod2.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod2.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod2.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod2.smd"
	replacebone "bip_toe_L" "bip_foot_L"
	replacebone "bip_index_0_L" "bip_hand_L"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "bip_pinky_0_L" "bip_hand_L"
	replacebone "bip_toe_R" "bip_foot_R"
	replacebone "bip_ring_0_L" "bip_hand_L"
	replacebone "bip_thumb_0_R" "bip_hand_R"
	replacebone "prp_cord" "bip_pelvis"
	replacebone "bip_thumb_0_L" "bip_hand_L"
	replacebone "bip_index_0_R" "bip_hand_R"
	replacebone "prp_pouch" "bip_pelvis"
	replacebone "bip_middle_0_L" "bip_hand_L"
	replacebone "prp_legPouch" "bip_pelvis"
	replacebone "bip_middle_0_R" "bip_hand_R"
	replacebone "bip_ring_0_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_0_R" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "prp_helmet" "bip_head"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "prp_starter" "bip_hand_R"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	nofacial
}
$lod 33
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod3.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod3.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod3.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod3.smd"
	replacebone "bip_hand_R" "bip_lowerArm_R"
	replacebone "bip_hand_L" "bip_lowerArm_L"
	replacebone "bip_toe_L" "bip_foot_L"
	replacebone "bip_index_0_L" "bip_hand_L"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "bip_pinky_0_L" "bip_hand_L"
	replacebone "bip_toe_R" "bip_foot_R"
	replacebone "bip_ring_0_L" "bip_hand_L"
	replacebone "bip_thumb_0_R" "bip_hand_R"
	replacebone "prp_cord" "bip_pelvis"
	replacebone "bip_thumb_0_L" "bip_hand_L"
	replacebone "bip_index_0_R" "bip_hand_R"
	replacebone "prp_pouch" "bip_pelvis"
	replacebone "bip_middle_0_L" "bip_hand_L"
	replacebone "prp_legPouch" "bip_pelvis"
	replacebone "bip_middle_0_R" "bip_hand_R"
	replacebone "bip_ring_0_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_0_R" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "prp_helmet" "bip_head"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "prp_starter" "bip_hand_R"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	nofacial
}
$lod 44
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod4.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod4.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod4.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod4.smd"
	replacebone "bip_hand_R" "bip_lowerArm_R"
	replacebone "bip_hand_L" "bip_lowerArm_L"
	replacebone "bip_toe_L" "bip_foot_L"
	replacebone "bip_index_0_L" "bip_hand_L"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "bip_pinky_0_L" "bip_hand_L"
	replacebone "bip_toe_R" "bip_foot_R"
	replacebone "bip_ring_0_L" "bip_hand_L"
	replacebone "bip_thumb_0_R" "bip_hand_R"
	replacebone "prp_cord" "bip_pelvis"
	replacebone "bip_thumb_0_L" "bip_hand_L"
	replacebone "bip_index_0_R" "bip_hand_R"
	replacebone "prp_pouch" "bip_pelvis"
	replacebone "bip_middle_0_L" "bip_hand_L"
	replacebone "prp_legPouch" "bip_pelvis"
	replacebone "bip_middle_0_R" "bip_hand_R"
	replacebone "bip_ring_0_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_0_R" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "prp_helmet" "bip_head"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "prp_starter" "bip_hand_R"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	nofacial
}
$lod 55
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod5.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod5.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod5.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod5.smd"
	replacebone "bip_hand_R" "bip_lowerArm_R"
	replacebone "bip_hand_L" "bip_lowerArm_L"
	replacebone "bip_toe_L" "bip_foot_L"
	replacebone "bip_index_0_L" "bip_hand_L"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "bip_pinky_0_L" "bip_hand_L"
	replacebone "bip_toe_R" "bip_foot_R"
	replacebone "bip_ring_0_L" "bip_hand_L"
	replacebone "bip_thumb_0_R" "bip_hand_R"
	replacebone "prp_cord" "bip_pelvis"
	replacebone "bip_thumb_0_L" "bip_hand_L"
	replacebone "bip_index_0_R" "bip_hand_R"
	replacebone "prp_pouch" "bip_pelvis"
	replacebone "bip_middle_0_L" "bip_hand_L"
	replacebone "prp_legPouch" "bip_pelvis"
	replacebone "bip_middle_0_R" "bip_hand_R"
	replacebone "bip_ring_0_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_0_R" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "prp_helmet" "bip_head"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "prp_starter" "bip_hand_R"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	nofacial
}
$shadowlod
{
	replacemodel "engineer_morphs_low.smd" "engineer_morphs_low_lod6.smd"
	replacemodel "hat_bodygroup.smd" "hat_bodygroup_lod6.smd"
	replacemodel "glove_bodygroup.smd" "glove_bodygroup_lod6.smd"
	replacemodel "robotarm_bodygroup.smd" "robotarm_bodygroup_lod6.smd"
	replacebone "bip_hand_R" "bip_lowerArm_R"
	replacebone "bip_hand_L" "bip_lowerArm_L"
	replacebone "bip_toe_L" "bip_foot_L"
	replacebone "bip_index_0_L" "bip_hand_L"
	replacebone "weapon_bone_L" "bip_hand_L"
	replacebone "effect_hand_L" "bip_hand_L"
	replacebone "effect_hand_R" "bip_hand_R"
	replacebone "bip_pinky_0_L" "bip_hand_L"
	replacebone "bip_toe_R" "bip_foot_R"
	replacebone "bip_ring_0_L" "bip_hand_L"
	replacebone "bip_thumb_0_R" "bip_hand_R"
	replacebone "prp_cord" "bip_pelvis"
	replacebone "bip_thumb_0_L" "bip_hand_L"
	replacebone "bip_index_0_R" "bip_hand_R"
	replacebone "prp_pouch" "bip_pelvis"
	replacebone "bip_middle_0_L" "bip_hand_L"
	replacebone "prp_legPouch" "bip_pelvis"
	replacebone "bip_middle_0_R" "bip_hand_R"
	replacebone "bip_ring_0_R" "bip_hand_R"
	replacebone "weapon_bone_1" "bip_hand_R"
	replacebone "weapon_bone" "bip_hand_R"
	replacebone "bip_pinky_0_R" "bip_hand_R"
	replacebone "bip_pinky_1_R" "bip_pinky_0_R"
	replacebone "bip_pinky_2_R" "bip_pinky_1_R"
	replacebone "bip_ring_1_R" "bip_ring_0_R"
	replacebone "bip_ring_2_R" "bip_ring_1_R"
	replacebone "bip_middle_1_R" "bip_middle_0_R"
	replacebone "bip_middle_2_R" "bip_middle_1_R"
	replacebone "bip_index_1_R" "bip_index_0_R"
	replacebone "bip_index_2_R" "bip_index_1_R"
	replacebone "bip_thumb_1_R" "bip_thumb_0_R"
	replacebone "bip_thumb_2_R" "bip_thumb_1_R"
	replacebone "bip_thumb_1_L" "bip_thumb_0_L"
	replacebone "bip_middle_1_L" "bip_middle_0_L"
	replacebone "bip_thumb_2_L" "bip_thumb_1_L"
	replacebone "bip_index_1_L" "bip_index_0_L"
	replacebone "bip_pinky_1_L" "bip_pinky_0_L"
	replacebone "bip_pinky_2_L" "bip_pinky_1_L"
	replacebone "bip_ring_1_L" "bip_ring_0_L"
	replacebone "bip_ring_2_L" "bip_ring_1_L"
	replacebone "bip_middle_2_L" "bip_middle_1_L"
	replacebone "bip_index_2_L" "bip_index_1_L"
	replacebone "prp_helmet" "bip_head"
	replacebone "medal_bone" "bip_spine_2"
	replacebone "prp_starter" "bip_hand_R"
	replacebone "mvm" "bip_pelvis"
	replacebone "prop_bone" "bip_pelvis"
	replacebone "prop_bone_1" "bip_pelvis"
	replacebone "prop_bone_2" "bip_pelvis"
	replacebone "prop_bone_3" "bip_pelvis"
	replacebone "prop_bone_4" "bip_pelvis"
	replacebone "prop_bone_5" "bip_pelvis"
	replacebone "prop_bone_6" "bip_pelvis"
	replacebone "taunt_effect" "bip_pelvis"
	nofacial
}

$surfaceprop "flesh"

$contents "solid"

$illumposition -0.514 -1.347 38.444

$cdmaterials "models\player\amongus\engineer\"
$cdmaterials ""

$texturegroup "skinfamilies"
{
	{ "engineer_black" "engineer_head" "engineer_mech_hand_black" }
	{ "engineer_blue" "engineer_head" "engineer_mech_hand_blue" }
	{ "engineer_cyan" "engineer_head" "engineer_mech_hand_cyan" }
	{ "engineer_gray" "engineer_head" "engineer_mech_hand_gray" }
	{ "engineer_green" "engineer_head" "engineer_mech_hand_green" }
	{ "engineer_lime" "engineer_head" "engineer_mech_hand_lime" }
	{ "engineer_maroon" "engineer_head" "engineer_mech_hand_maroon" }
	{ "engineer_navy" "engineer_head" "engineer_mech_hand_navy" }
	{ "engineer_olive" "engineer_head" "engineer_mech_hand_olive" }
	{ "engineer_purple" "engineer_head" "engineer_mech_hand_purple" }
	{ "engineer_red" "engineer_head" "engineer_mech_hand_red" }
	{ "engineer_teal" "engineer_head" "engineer_mech_hand_teal" }
	{ "engineer_yellow" "engineer_head" "engineer_mech_hand_yellow" }
}

$attachment "back_lower" "bip_spine_0" 0 0 0 rotate 0 0 0
$attachment "foot_L" "bip_foot_L" 0 0 0 rotate 0 0 0
$attachment "foot_R" "bip_foot_R" 0 0 0 rotate 0 0 0
$attachment "partyhat" "bip_head" 0 -9.26 -2.23 rotate 75 90 180
$attachment "head" "bip_head" 0 -10.66 1.23 rotate 74.7 -90 0
$attachment "eyeglow_R" "bip_head" -1.81 -4.01 -5.32 rotate 69.7 -152.97 -61.46
$attachment "eyeglow_L" "bip_head" 1.81 -4.01 -5.32 rotate 69.7 -27.03 61.46
$attachment "effect_hand_L" "effect_hand_L" 0 0 0 rotate 0 0 0
$attachment "exhaust" "bip_hand_R" -2.86 -0.54 2.68 rotate -37.72 -175.85 -11.65
$attachment "effect_hand_R" "effect_hand_R" 0 0 0 rotate 0 0 0
$attachment "flag" "bip_spine_2" 0.12 1.92 9.64 rotate 0.95 -6.92 -1.52
$attachment "prop_bone" "prop_bone" 0 0 0 rotate 0 0 0
$attachment "taunt_effect" "taunt_effect" 0 0 0 rotate 0 0 0

$cbox 0 0 0 0 0 0

$bbox -9.058 -27.026 -4.007 11.751 25.998 80.894

$hboxset "engineer"
$hbox 1 "bip_head" -6 -11 -8 6 4 6
$hbox 0 "bip_pelvis" -9 -0.5 -7.5 9 11.5 3.5
$hbox 3 "bip_spine_0" -9 -2 -10 9 4 4
$hbox 3 "bip_spine_1" -9 -3 -10.5 9 3 4.5
$hbox 2 "bip_spine_2" -10 -3 -9 10 3 5
$hbox 2 "bip_spine_3" -10 -3.5 -10 10 1.5 4
$hbox 4 "bip_upperArm_L" 0 -3.5 -2.75 12 3.5 3.25
$hbox 4 "bip_lowerArm_L" 0 -2.25 -3.25 13 2.25 3.25
$hbox 4 "bip_hand_L" -3.5 -10 -3 1.5 0 5
$hbox 5 "bip_upperArm_R" 0 -3.5 -2.75 12 3.5 3.25
$hbox 5 "bip_lowerArm_R" 0 -3.25 -2.75 13 3.25 2.75
$hbox 5 "bip_hand_R" -2.5 0.5 -3.5 2.5 9.5 4.5
$hbox 6 "bip_hip_L" 2 -4 -5 16 4 4
$hbox 6 "bip_knee_L" 0 -2.25 -4.5 16 3.25 2.5
$hbox 6 "bip_foot_L" -2 -10 -3 2 2 3
$hbox 7 "bip_hip_R" 2 -4 -5 16 4 4
$hbox 7 "bip_knee_R" 0 -3.25 -4.5 16 2.25 2.5
$hbox 7 "bip_foot_R" -2 -2 -2.5 2 10 3.5
$skipboneinbbox

$definebone "bip_pelvis" "" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "bip_hip_R" "bip_pelvis" -4.58855 3.357311 -1.242807 -2.879271 94.365211 -168.385282 0 0 0 0 0 0
$definebone "bip_knee_R" "bip_hip_R" 15.99354 0 0 17.033489 -0.000015 -0.000004 0 0 0 0 0 0
$definebone "bip_spine_0" "bip_pelvis" 0 -4.109955 0 0 0 -13.079057 0 0 0 0 0 0
$definebone "bip_spine_1" "bip_spine_0" 0 -6.949554 0 0 0 10.813604 0 0 0 0 0 0
$definebone "bip_spine_2" "bip_spine_1" 0 -5.956688 0 0 0 2.50559 0 0 0 0 0 0
$definebone "bip_spine_3" "bip_spine_2" 0 -4.703865 0 0 0 39.110162 0 0 0 0 0 0
$definebone "bip_neck" "bip_spine_3" 0 -3.603737 -0.000004 0 0 -30.380774 0 0 0 0 0 0
$definebone "bip_head" "bip_neck" 0 -3.416229 0 0 0 5.314948 0 0 0 0 0 0
$definebone "bip_hip_L" "bip_pelvis" 4.588553 3.357315 -1.242804 -2.879281 85.634788 168.385282 0 0 0 0 0 0
$definebone "bip_knee_L" "bip_hip_L" 15.993515 0 0 17.03345 0 0.000002 0 0 0 0 0 0
$definebone "bip_collar_L" "bip_spine_3" 3.535877 -1.233402 -0.275414 -31.649246 -58.004384 165.158291 0 0 0 0 0 0
$definebone "bip_upperArm_L" "bip_collar_L" -0.000004 -6.772207 0 2.204571 -124.972695 95.698935 0 0 0 0 0 0
$definebone "bip_lowerArm_L" "bip_upperArm_L" 11.405773 0 -0.000004 -0.000002 27.511754 -90.000009 0 0 0 0 0 0
$definebone "bip_collar_R" "bip_spine_3" -3.53588 -1.233391 -0.275425 31.649246 58.004384 -14.841709 0 0 0 0 0 0
$definebone "bip_upperArm_R" "bip_collar_R" 0.000015 6.772213 0.000009 -2.204577 55.027375 84.301063 0 0 0 0 0 0
$definebone "bip_lowerArm_R" "bip_upperArm_R" 11.405701 0 0 0.000034 -27.511761 0.000032 0 0 0 0 0 0
$definebone "bip_foot_L" "bip_knee_L" 17.10424 0 0 3.682956 88.903798 -59.100637 0 0 0 0 0 0
$definebone "bip_foot_R" "bip_knee_R" 17.104212 0 0 -3.682957 91.096214 120.899334 0 0 0 0 0 0
$definebone "bip_hand_R" "bip_lowerArm_R" 12.199291 -0.000001 -0.000004 -89.999907 -90.000016 0 0 0 0 0 0 0
$definebone "bip_hand_L" "bip_lowerArm_L" 12.199297 0 -0.000001 0 90.000009 -0.000004 0 0 0 0 0 0
$definebone "bip_toe_L" "bip_foot_L" -0.081844 -8.483861 2.222119 -0.000001 0.000001 -45.179492 0 0 0 0 0 0
$definebone "bip_index_0_L" "bip_hand_L" 0.938377 -5.097872 3.235913 87.502851 -63.700455 -50.389195 0 0 0 0 0 0
$definebone "weapon_bone_L" "bip_hand_L" -2.040047 -3.177454 0.24738 13.465256 -24.792157 110.081899 0 0 0 0 0 0
$definebone "effect_hand_L" "bip_hand_L" -0.678658 -4.780277 0.952188 -13.720137 167.14507 0.723118 0 0 0 0 0 0
$definebone "effect_hand_R" "bip_hand_R" -0.201778 3.366079 0.494073 13.720569 -12.854922 -0.722948 0 0 0 0 0 0
$definebone "bip_pinky_0_L" "bip_hand_L" 0.068718 -4.878183 -2.144789 73.811833 141.814166 167.303298 0 0 0 0 0 0
$definebone "bip_toe_R" "bip_foot_R" 0.17927 8.472205 -2.031156 0.000001 0 -45.179488 0 0 0 0 0 0
$definebone "bip_ring_0_L" "bip_hand_L" 0.837532 -5.165279 -0.472911 72.067628 147.533247 173.692667 0 0 0 0 0 0
$definebone "bip_thumb_0_R" "bip_hand_R" 1.330677 1.494701 -3.339922 13.274533 -10.097077 -7.239715 0 0 0 0 0 0
$definebone "prp_cord" "bip_pelvis" -8.715168 -0.10091 0.663601 -83.505073 -46.793643 -133.022333 0 0 0 0 0 0
$definebone "bip_thumb_0_L" "bip_hand_L" -1.706749 -2.312637 4.088992 -2.989149 -20.47174 -31.825495 0 0 0 0 0 0
$definebone "bip_index_0_R" "bip_hand_R" -1.747116 3.85454 -1.650733 82.660035 103.700433 104.019143 0 0 0 0 0 0
$definebone "prp_pouch" "bip_pelvis" -6.00824 -0.39045 -8.040259 29.964258 2.742097 -174.522426 0 0 0 0 0 0
$definebone "bip_middle_0_L" "bip_hand_L" 0.781845 -4.828985 1.471179 82.863766 156.31728 169.089543 0 0 0 0 0 0
$definebone "prp_legPouch" "bip_pelvis" 7.187728 3.829735 -6.242617 -43.121614 -4.457028 -173.494496 0 0 0 0 0 0
$definebone "bip_middle_0_R" "bip_hand_R" -2.378677 3.628277 0.433292 75.524113 142.150293 154.919373 0 0 0 0 0 0
$definebone "bip_ring_0_R" "bip_hand_R" -1.105659 3.512394 2.19825 72.067621 147.533247 150.986891 0 0 0 0 0 0
$definebone "weapon_bone_1" "bip_hand_R" 4.428493 9.545699 2.422666 13.46525 -24.792156 -69.918106 0 0 0 0 0 0
$definebone "weapon_bone" "bip_hand_R" 1.06007 3.630159 0.011103 13.46525 -24.792156 -69.918106 0 0 0 0 0 0
$definebone "bip_pinky_0_R" "bip_hand_R" -0.796833 3.212009 3.267369 70.845352 119.470828 132.652847 0 0 0 0 0 0
$definebone "bip_pinky_1_R" "bip_pinky_0_R" -0.000006 2.352123 0.000025 0.000002 0.000001 32.378047 0 0 0 0 0 0
$definebone "bip_pinky_2_R" "bip_pinky_1_R" 0.000003 1.35379 -0.000003 0.000003 0.000001 17.956323 0 0 0 0 0 0
$definebone "bip_ring_1_R" "bip_ring_0_R" 0.000013 2.398308 0.000042 -0.000006 0.000003 39.644532 0 0 0 0 0 0
$definebone "bip_ring_2_R" "bip_ring_1_R" -0.000024 2.25676 -0.000004 -0.000002 0.000008 16.618429 0 0 0 0 0 0
$definebone "bip_middle_1_R" "bip_middle_0_R" 0.000017 3.66662 0.00001 -0.000002 0.000004 33.212041 0 0 0 0 0 0
$definebone "bip_middle_2_R" "bip_middle_1_R" 0.000001 2.728436 -0.000027 0.000003 0.000005 15.200712 0 0 0 0 0 0
$definebone "bip_index_1_R" "bip_index_0_R" -0.000017 3.081718 -0.000004 -0.000001 0.000003 36.919047 0 0 0 0 0 0
$definebone "bip_index_2_R" "bip_index_1_R" 0.000012 2.117352 0.000002 0.000001 0.000002 7.947709 0 0 0 0 0 0
$definebone "bip_thumb_1_R" "bip_thumb_0_R" 0.000025 1.821836 -0.000004 -0.000001 -0.000002 17.258502 0 0 0 0 0 0
$definebone "bip_thumb_2_R" "bip_thumb_1_R" 0.00001 1.32485 0.000001 -0.000002 -0.000002 -5.215694 0 0 0 0 0 0
$definebone "bip_thumb_1_L" "bip_thumb_0_L" -0.000002 -1.82184 0.000002 0.000003 -0.000004 17.258496 0 0 0 0 0 0
$definebone "bip_middle_1_L" "bip_middle_0_L" 0.000001 -3.666677 0.000002 -0.000002 0.000005 47.104017 0 0 0 0 0 0
$definebone "bip_thumb_2_L" "bip_thumb_1_L" -0.000002 -1.32485 0 0.000002 -0.000003 -5.215701 0 0 0 0 0 0
$definebone "bip_index_1_L" "bip_index_0_L" 0 -2.662802 0.000004 -0.000002 0.000009 43.026599 0 0 0 0 0 0
$definebone "bip_pinky_1_L" "bip_pinky_0_L" 0.000001 -2.352095 0 -0.000001 0.000007 32.378047 0 0 0 0 0 0
$definebone "bip_pinky_2_L" "bip_pinky_1_L" 0 -1.353813 0.000002 0.000004 0.000006 17.956323 0 0 0 0 0 0
$definebone "bip_ring_1_L" "bip_ring_0_L" 0 -2.749704 0 -0.000002 0.000005 27.632007 0 0 0 0 0 0
$definebone "bip_ring_2_L" "bip_ring_1_L" 0 -1.753651 -0.000002 0 0.000006 20.139858 0 0 0 0 0 0
$definebone "bip_middle_2_L" "bip_middle_1_L" -0.000001 -1.986103 -0.000004 0.000002 0.000007 16.467221 0 0 0 0 0 0
$definebone "bip_index_2_L" "bip_index_1_L" 0.000002 -1.826832 -0.000001 0.000005 0.000009 8.888223 0 0 0 0 0 0
$definebone "prp_helmet" "bip_head" 0 -7.314529 0 0 0 0 0 0 0 0 0 0
$definebone "medal_bone" "bip_spine_2" 3.742907 -0.29583 -8.249883 -29.279453 0 164 0 0 0 0 0 0
$definebone "prp_starter" "bip_hand_R" -2.602032 0.876684 -1.632072 -2.2741 -110.872453 -111.228695 0 0 0 0 0 0
$definebone "mvm" "bip_pelvis" 3.070946 -0.139153 4.29603 -19.631864 -177.667236 1.655535 0 0 0 0 0 0
$definebone "prop_bone" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_1" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_2" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_3" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_4" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_5" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "prop_bone_6" "bip_pelvis" 0 41.365337 0 0 0 175.25637 0 0 0 0 0 0
$definebone "taunt_effect" "bip_pelvis" 0 41.22364 3.420797 0 0 -175.25637 0 0 0 0 0 0

$bonemerge "bip_pelvis"
$bonemerge "bip_spine_0"
$bonemerge "bip_spine_1"
$bonemerge "bip_spine_2"
$bonemerge "bip_spine_3"
$bonemerge "bip_neck"
$bonemerge "bip_head"
$bonemerge "bip_collar_L"
$bonemerge "bip_upperArm_L"
$bonemerge "bip_lowerArm_L"
$bonemerge "bip_collar_R"
$bonemerge "bip_upperArm_R"
$bonemerge "bip_lowerArm_R"
$bonemerge "bip_hand_R"
$bonemerge "bip_hand_L"
$bonemerge "weapon_bone_L"
$bonemerge "prp_legPouch"
$bonemerge "weapon_bone_1"
$bonemerge "weapon_bone"
$bonemerge "prp_helmet"
$bonemerge "medal_bone"
$bonemerge "mvm"
$bonemerge "prop_bone"
$bonemerge "prop_bone_1"
$bonemerge "prop_bone_2"
$bonemerge "prop_bone_3"
$bonemerge "prop_bone_4"
$bonemerge "prop_bone_5"
$bonemerge "prop_bone_6"
$bonemerge "taunt_effect"


$poseparameter "body_pitch" -45 45 loop 360
$poseparameter "body_yaw" -45 45 loop 360

$ikchain "rhand" "bip_hand_R" knee 0 0 0
$ikchain "lhand" "bip_hand_L" knee 0 0 0
$ikchain "rfoot" "bip_foot_R" knee 0 0 0
$ikchain "lfoot" "bip_foot_L" knee 0 0 0

$weightlist "weights_user_ref" {
	 "bip_pelvis" 0
	 "bip_hip_R" 0
	 "bip_knee_R" 0
	 "bip_spine_0" 0
	 "bip_spine_1" 0
	 "bip_spine_2" 0
	 "bip_spine_3" 0
	 "bip_neck" 0
	 "bip_head" 0
	 "bip_hip_L" 0
	 "bip_knee_L" 0
	 "bip_collar_L" 0
	 "bip_upperArm_L" 0
	 "bip_lowerArm_L" 0
	 "bip_collar_R" 0
	 "bip_upperArm_R" 0
	 "bip_lowerArm_R" 0
	 "bip_foot_L" 0
	 "bip_foot_R" 0
	 "bip_hand_R" 0
	 "bip_hand_L" 0
	 "bip_toe_L" 0
	 "bip_index_0_L" 0
	 "weapon_bone_L" 0
	 "effect_hand_L" 0
	 "effect_hand_R" 0
	 "bip_pinky_0_L" 0
	 "bip_toe_R" 0
	 "bip_ring_0_L" 0
	 "bip_thumb_0_R" 0
	 "prp_cord" 0
	 "bip_thumb_0_L" 0
	 "bip_index_0_R" 0
	 "prp_pouch" 0
	 "bip_middle_0_L" 0
	 "prp_legPouch" 0
	 "bip_middle_0_R" 0
	 "bip_ring_0_R" 0
	 "weapon_bone_1" 0
	 "weapon_bone" 0
	 "bip_pinky_0_R" 0
	 "bip_pinky_1_R" 0
	 "bip_pinky_2_R" 0
	 "bip_ring_1_R" 0
	 "bip_ring_2_R" 0
	 "bip_middle_1_R" 0
	 "bip_middle_2_R" 0
	 "bip_index_1_R" 0
	 "bip_index_2_R" 0
	 "bip_thumb_1_R" 0
	 "bip_thumb_2_R" 0
	 "bip_thumb_1_L" 0
	 "bip_middle_1_L" 0
	 "bip_thumb_2_L" 0
	 "bip_index_1_L" 0
	 "bip_pinky_1_L" 0
	 "bip_pinky_2_L" 0
	 "bip_ring_1_L" 0
	 "bip_ring_2_L" 0
	 "bip_middle_2_L" 0
	 "bip_index_2_L" 0
	 "prp_helmet" 0
	 "medal_bone" 0
	 "prp_starter" 0
	 "mvm" 0
	 "prop_bone" 0
	 "prop_bone_1" 0
	 "prop_bone_2" 0
	 "prop_bone_3" 0
	 "prop_bone_4" 0
	 "prop_bone_5" 0
	 "prop_bone_6" 0
	 "taunt_effect" 0
}

$sequence "ref" {
	"engineer_anims\ref.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
	ikrule "rhand" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 0
	ikrule "lhand" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 1
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 2
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 3
}

$sequence "ragdoll" {
	"engineer_anims\ragdoll.smd"
	activity "ACT_DIERAGDOLL" 1
	fadein 0.2
	fadeout 0.2
	fps 30
	ikrule "rhand" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 0
	ikrule "lhand" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 1
	ikrule "rfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 2
	ikrule "lfoot" release contact 0 fakeorigin 0 0 0 fakerotate 0 0 0 floor 0 height 0 radius 0 range 0 0 0 0 target 3
}

$declaresequence "user_ref"

$declaresequence "ragdollspawn"

$declaresequence "r_handposes"

$declaresequence "r_armposes"

$declaresequence "PRIMARY_aimmatrix_idle"

$declaresequence "PRIMARY_aimmatrix_run"

$declaresequence "PRIMARY_aimmatrix_crouch_idle"

$declaresequence "AttackStand_PRIMARY"

$declaresequence "AttackCrouch_PRIMARY"

$declaresequence "AttackSwim_PRIMARY"

$declaresequence "ReloadStand_PRIMARY"

$declaresequence "ReloadCrouch_PRIMARY"

$declaresequence "ReloadSwim_PRIMARY"

$declaresequence "a_PRIMARY_reload"

$declaresequence "a_PRIMARY_reload_loop"

$declaresequence "b_PRIMARY_reload_loop"

$declaresequence "PRIMARY_reload_end"

$declaresequence "a_PRIMARYcrouch_reload"

$declaresequence "reloadcrouch_PRIMARY_end"

$declaresequence "PRIMARY_reloadcrouch"

$declaresequence "a_PRIMARY_reloadcrouch_loop"

$declaresequence "b_PRIMARY_reloadcrouch_loop"

$declaresequence "a_PRIMARY_reload_airwalk"

$declaresequence "layer_reload_arms_PRIMARY"

$declaresequence "PRIMARY_reload_airwalk"

$declaresequence "layer_reload_arms_PRIMARY_loop"

$declaresequence "PRIMARY_reload_airwalk_loop"

$declaresequence "layer_reload_arms_PRIMARY_end"

$declaresequence "PRIMARY_reload_airwalk_end"

$declaresequence "a_PRIMARY_reload_swim"

$declaresequence "layer_reload_arms_PRIMARY_swim"

$declaresequence "PRIMARY_reload_swim"

$declaresequence "layer_reload_arms_PRIMARY_loop_swim"

$declaresequence "PRIMARY_reload_swim_loop"

$declaresequence "layer_reload_arms_PRIMARY_end_swim"

$declaresequence "PRIMARY_reload_swim_end"

$declaresequence "layer_placeSapper_ArmL"

$declaresequence "PRIMARY_placeSapper"

$declaresequence "SECONDARY_aimmatrix_idle"

$declaresequence "SECONDARY_aimmatrix_run"

$declaresequence "SECONDARY_aimmatrix_crouch_idle"

$declaresequence "AttackStand_SECONDARY"

$declaresequence "AttackSwim_SECONDARY"

$declaresequence "AttackCrouch_SECONDARY"

$declaresequence "layer_reload_standing_arms_SECONDARY"

$declaresequence "layer_reload_airwalk_arms_SECONDARY"

$declaresequence "layer_reload_crouch_arms_SECONDARY"

$declaresequence "ReloadStand_SECONDARY"

$declaresequence "ReloadAirwalk_SECONDARY"

$declaresequence "ReloadCrouch_SECONDARY"

$declaresequence "ReloadSwim_SECONDARY"

$declaresequence "xReloadPrim"

$declaresequence "MELEE_aimmatrix_idle"

$declaresequence "MELEE_aimmatrix_run"

$declaresequence "MELEE_aimmatrix_walk"

$declaresequence "MELEE_aimmatrix_crouch_idle"

$declaresequence "MELEE_ALLCLASS_aimmatrix_idle"

$declaresequence "MELEE_ALLCLASS_aimmatrix_run"

$declaresequence "MELEE_ALLCLASS_aimmatrix_walk"

$declaresequence "MELEE_ALLCLASS_aimmatrix_crouch_idle"

$declaresequence "armslayer_melee_swing"

$declaresequence "bodylayer_Melee_Swing"

$declaresequence "Melee_Swing"

$declaresequence "armslayer_melee_Crouch_swing"

$declaresequence "bodylayer_Melee_Crouch_Swing"

$declaresequence "Melee_Crouch_Swing"

$declaresequence "armslayer_melee_allclass_swing"

$declaresequence "bodylayer_Melee_allclass_Swing"

$declaresequence "Melee_allclass_Swing"

$declaresequence "armslayer_melee_allclass_Crouch_swing"

$declaresequence "bodylayer_Melee_allclass_Crouch_Swing"

$declaresequence "Melee_allclass_Crouch_Swing"

$declaresequence "AttackSwim_MELEE"

$declaresequence "AttackSwim_MELEE_ALLCLASS"

$declaresequence "melee_raw"

$declaresequence "melee_crouchraw"

$declaresequence "PDA_aimmatrix_idle"

$declaresequence "PDA_aimmatrix_run"

$declaresequence "PDA_aimmatrix_crouch_idle"

$declaresequence "armslayer_PDA_fire"

$declaresequence "bodylayer_PDA_fire"

$declaresequence "PDA_fire"

$declaresequence "armslayer_PDA_run_fire"

$declaresequence "bodylayer_PDA_run_fire"

$declaresequence "PDA_run_fire"

$declaresequence "armslayer_PDA_Crouch_fire"

$declaresequence "bodylayer_PDA_Crouch_fire"

$declaresequence "PDA_Crouch_fire"

$declaresequence "layer_fire_standing_arms_PDA"

$declaresequence "AttackStand_PDA"

$declaresequence "AttackCrouch_PDA"

$declaresequence "AttackSwim_PDA"

$declaresequence "BUILDING_aimmatrix_idle"

$declaresequence "BUILDING_aimmatrix_run"

$declaresequence "BUILDING_aimmatrix_crouch_idle"

$declaresequence "ITEM1_aimmatrix_idle"

$declaresequence "ITEM1_aimmatrix_run"

$declaresequence "ITEM1_aimmatrix_crouch_idle"

$declaresequence "ITEM2_aimmatrix_idle"

$declaresequence "ITEM2_aimmatrix_run"

$declaresequence "ITEM2_aimmatrix_crouch_idle"

$declaresequence "armslayer_ITEM2_swing"

$declaresequence "bodylayer_ITEM2_swing"

$declaresequence "ITEM2_swing"

$declaresequence "armslayer_ITEM2_crouch_swing"

$declaresequence "bodylayer_ITEM2_crouch_swing"

$declaresequence "ITEM2_crouch_swing"

$declaresequence "AttackSwim_ITEM2"

$declaresequence "armslayer_ITEM2_swing_hard"

$declaresequence "bodylayer_ITEM2_swing_hard"

$declaresequence "ITEM2_swing_hard"

$declaresequence "armslayer_ITEM2_crouch_swing_hard"

$declaresequence "bodylayer_ITEM2_crouch_swing_hard"

$declaresequence "ITEM2_Crouch_Swing_hard"

$declaresequence "AttackSwim_ITEM2_hard"

$declaresequence "layer_gesture_primary_go_armL"

$declaresequence "gesture_primary_go"

$declaresequence "layer_gesture_primary_cheer_armL"

$declaresequence "gesture_primary_cheer"

$declaresequence "layer_gesture_primary_help_armL"

$declaresequence "gesture_primary_help"

$declaresequence "layer_gesture_secondary_go_armL"

$declaresequence "gesture_secondary_go"

$declaresequence "layer_gesture_secondary_cheer_armL"

$declaresequence "gesture_secondary_cheer"

$declaresequence "layer_gesture_secondary_help_armL"

$declaresequence "gesture_secondary_help"

$declaresequence "layer_gesture_melee_go_armL"

$declaresequence "gesture_melee_go"

$declaresequence "layer_gesture_melee_cheer_armL"

$declaresequence "gesture_melee_cheer"

$declaresequence "layer_gesture_melee_help_armL"

$declaresequence "gesture_melee_help"

$declaresequence "layer_gesture_PDA_go_armL"

$declaresequence "gesture_PDA_go"

$declaresequence "layer_gesture_PDA_cheer_armL"

$declaresequence "gesture_PDA_cheer"

$declaresequence "layer_gesture_PDA_help_armL"

$declaresequence "gesture_PDA_help"

$declaresequence "layer_taunt01"

$declaresequence "taunt01"

$declaresequence "layer_taunt02"

$declaresequence "taunt02"

$declaresequence "layer_taunt03"

$declaresequence "taunt03"

$declaresequence "taunt06"

$declaresequence "layer_taunt07"

$declaresequence "taunt07"

$declaresequence "layer_taunt_replay"

$declaresequence "taunt_replay"

$declaresequence "layer_taunt_laugh"

$declaresequence "taunt_laugh"

$declaresequence "layer_dieviolent"

$declaresequence "dieviolent"

$declaresequence "layer_taunt09"

$declaresequence "taunt09"

$declaresequence "layer_taunt10"

$declaresequence "taunt10"

$declaresequence "layer_taunt_drg_melee"

$declaresequence "taunt_drg_melee"

$declaresequence "taunt_brutallegendinterior"

$declaresequence "taunt_brutallegendin"

$declaresequence "taunt_brutallegendout"

$declaresequence "taunt_brutallegendinblend"

$declaresequence "taunt_brutallegendoutblend"

$declaresequence "taunt_brutallegend"

$declaresequence "taunt_dosido_dance"

$declaresequence "taunt_dosido_intro"

$declaresequence "taunt_hifiveSuccessFull"

$declaresequence "taunt_hifiveSuccess"

$declaresequence "taunt_highFiveStart"

$declaresequence "taunt_highFiveStart_idle"

$declaresequence "BUILDING_DEPLOYED_aimmatrix_idle"

$declaresequence "BUILDING_DEPLOYED_aimmatrix_crouch_idle"

$declaresequence "stand_PRIMARY"

$declaresequence "stand_SECONDARY"

$declaresequence "stand_MELEE"

$declaresequence "stand_MELEE_ALLCLASS"

$declaresequence "stand_LOSER"

$declaresequence "stand_ITEM1"

$declaresequence "stand_ITEM2"

$declaresequence "stand_PDA"

$declaresequence "stand_BUILDING"

$declaresequence "stand_BUILDING_DEPLOYED"

$declaresequence "crouch_PRIMARY"

$declaresequence "crouch_SECONDARY"

$declaresequence "crouch_MELEE"

$declaresequence "crouch_MELEE_ALLCLASS"

$declaresequence "crouch_LOSER"

$declaresequence "crouch_ITEM1"

$declaresequence "crouch_ITEM2"

$declaresequence "crouch_PDA"

$declaresequence "crouch_BUILDING"

$declaresequence "crouch_BUILDING_DEPLOYED"

$declaresequence "a_jumpstart_PRIMARY"

$declaresequence "a_jumpfloat_PRIMARY"

$declaresequence "jumplandPose_PRIMARY"

$declaresequence "jumpland_PRIMARY"

$declaresequence "a_jumpstart_SECONDARY"

$declaresequence "a_jumpfloat_SECONDARY"

$declaresequence "jumplandPose_SECONDARY"

$declaresequence "jumpland_SECONDARY"

$declaresequence "a_jumpstart_MELEE"

$declaresequence "a_jumpfloat_MELEE"

$declaresequence "jumplandPose_MELEE"

$declaresequence "jumpland_MELEE"

$declaresequence "a_jumpstart_MELEE_ALLCLASS"

$declaresequence "a_jumpfloat_MELEE_ALLCLASS"

$declaresequence "jumplandPose_MELEE_ALLCLASS"

$declaresequence "jumpland_MELEE_ALLCLASS"

$declaresequence "a_jumpstart_LOSER"

$declaresequence "a_jumpfloat_LOSER"

$declaresequence "jumplandPose_LOSER"

$declaresequence "jumpland_LOSER"

$declaresequence "a_jumpstart_ITEM1"

$declaresequence "a_jumpfloat_ITEM1"

$declaresequence "jumplandPose_ITEM1"

$declaresequence "jumpland_ITEM1"

$declaresequence "a_jumpstart_ITEM2"

$declaresequence "a_jumpfloat_ITEM2"

$declaresequence "jumplandPose_ITEM2"

$declaresequence "jumpland_ITEM2"

$declaresequence "a_jumpstart_PDA"

$declaresequence "a_jumpfloat_PDA"

$declaresequence "jumplandPose_PDA"

$declaresequence "jumpland_PDA"

$declaresequence "a_jumpstart_BUILDING"

$declaresequence "a_jumpfloat_BUILDING"

$declaresequence "jumplandPose_BUILDING"

$declaresequence "jumpland_BUILDING"

$declaresequence "a_jumpstart_BUILDING_DEPLOYED"

$declaresequence "a_jumpfloat_BUILDING_DEPLOYED"

$declaresequence "jumplandPose_BUILDING_DEPLOYED"

$declaresequence "jumpland_BUILDING_DEPLOYED"

$declaresequence "PRIMARY_aimmatrix_swim"

$declaresequence "s_swimAlign_PRIMARY"

$declaresequence "swim_PRIMARY"

$declaresequence "SECONDARY_aimmatrix_swim"

$declaresequence "s_swimAlign_SECONDARY"

$declaresequence "swim_SECONDARY"

$declaresequence "MELEE_aimmatrix_swim"

$declaresequence "s_swimAlign_MELEE"

$declaresequence "swim_MELEE"

$declaresequence "MELEE_ALLCLASS_aimmatrix_swim"

$declaresequence "s_swimAlign_MELEE_ALLCLASS"

$declaresequence "swim_MELEE_ALLCLASS"

$declaresequence "ITEM1_aimmatrix_swim"

$declaresequence "s_swimAlign_ITEM1"

$declaresequence "swim_ITEM1"

$declaresequence "ITEM2_aimmatrix_swim"

$declaresequence "s_swimAlign_ITEM2"

$declaresequence "swim_ITEM2"

$declaresequence "PDA_aimmatrix_swim"

$declaresequence "s_swimAlign_PDA"

$declaresequence "swim_PDA"

$declaresequence "BUILDING_aimmatrix_swim"

$declaresequence "s_swimAlign_BUILDING"

$declaresequence "swim_BUILDING"

$declaresequence "BUILDING_DEPLOYED_aimmatrix_swim"

$declaresequence "s_swimAlign_BUILDING_DEPLOYED"

$declaresequence "swim_BUILDING_DEPLOYED"

$declaresequence "s_swimAlign_LOSER"

$declaresequence "swim_LOSER"

$declaresequence "run_PRIMARY"

$declaresequence "crouch_walk_PRIMARY"

$declaresequence "SECONDARY_aimmatrix_forward"

$declaresequence "SECONDARY_aimmatrix_reverse"

$declaresequence "run_SECONDARY"

$declaresequence "crouch_walk_SECONDARY"

$declaresequence "run_MELEE"

$declaresequence "crouch_walk_MELEE"

$declaresequence "run_MELEE_ALLCLASS"

$declaresequence "crouch_walk_MELEE_ALLCLASS"

$declaresequence "run_LOSER"

$declaresequence "run_ITEM1"

$declaresequence "crouch_walk_ITEM1"

$declaresequence "run_ITEM2"

$declaresequence "crouch_walk_ITEM2"

$declaresequence "run_PDA"

$declaresequence "crouch_walk_PDA"

$declaresequence "run_BUILDING"

$declaresequence "crouch_walk_BUILDING"

$declaresequence "run_BUILDING_DEPLOYED"

$declaresequence "crouch_walk_BUILDING_DEPLOYED"

$declaresequence "PRIMARY_aimmatrix_airwalk"

$declaresequence "airwalk_PRIMARY"

$declaresequence "airwalk_SECONDARY"

$declaresequence "airwalk_MELEE"

$declaresequence "airwalk_MELEE_ALLCLASS"

$declaresequence "airwalk_LOSER"

$declaresequence "airwalk_ITEM1"

$declaresequence "airwalk_ITEM2"

$declaresequence "airwalk_PDA"

$declaresequence "airwalk_BUILDING"

$declaresequence "airwalk_BUILDING_DEPLOYED"

$declaresequence "a_flinch01"

$declaresequence "a_flinch02"

$declaresequence "a_flinch04"

$declaresequence "PRIMARY_death_headshot"

$declaresequence "PRIMARY_death_backstab"

$declaresequence "PRIMARY_death_burning"

$declaresequence "layer_PRIMARY_stun_begin"

$declaresequence "layer_PRIMARY_stun_middle"

$declaresequence "layer_PRIMARY_stun_end"

$declaresequence "PRIMARY_stun_begin"

$declaresequence "PRIMARY_stun_middle"

$declaresequence "PRIMARY_stun_end"

$declaresequence "SelectionMenu_StartPose"

$declaresequence "SelectionMenu_Anim01"

$declaresequence "SelectionMenu_Idle"

$declaresequence "armslayer_throw_fire"

$declaresequence "throw_fire"

$declaresequence "taunt_conga"

$declaresequence "layer_taunt_dosido_dance"

$declaresequence "taunt_dosido_dance"

$declaresequence "layer_taunt_dosido_intro"

$declaresequence "taunt_dosido_intro"

$declaresequence "taunt_flip_start"

$declaresequence "layer_taunt_flip_success_initiator"

$declaresequence "taunt_flip_success_initiator"

$declaresequence "layer_taunt_flip_success_receiver"

$declaresequence "taunt_flip_success_receiver"

$declaresequence "taunt_rps_start"

$declaresequence "layer_taunt_rps_rock"

$declaresequence "taunt_rps_rock"

$declaresequence "layer_taunt_rps_paper"

$declaresequence "taunt_rps_paper"

$declaresequence "layer_taunt_rps_scissors"

$declaresequence "taunt_rps_scissors"

$declaresequence "layer_taunt_rps_rock_win"

$declaresequence "taunt_rps_rock_win"

$declaresequence "layer_taunt_rps_paper_win"

$declaresequence "taunt_rps_paper_win"

$declaresequence "layer_taunt_rps_scissors_win"

$declaresequence "taunt_rps_scissors_win"

$declaresequence "layer_taunt_rps_rock_lose"

$declaresequence "taunt_rps_rock_lose"

$declaresequence "layer_taunt_rps_paper_lose"

$declaresequence "taunt_rps_paper_lose"

$declaresequence "layer_taunt_rps_scissors_lose"

$declaresequence "taunt_rps_scissors_lose"

$declaresequence "layer_taunt_headbutt_start"

$declaresequence "taunt_headbutt_start"

$declaresequence "layer_taunt_headbutt_success"

$declaresequence "taunt_headbutt_success"

$declaresequence "layer_taunt_killer_time_intro"

$declaresequence "taunt_killer_time_intro"

$declaresequence "layer_taunt_killer_time_outro"

$declaresequence "taunt_killer_time_outro"

$includemodel "player/engineer_user_animations.mdl"
$includemodel "player/engineer_animations.mdl"
$includemodel "workshop/player/animations/engineer_workshop_animations.mdl"

$collisionjoints "engineer_physics.smd"
{
	$mass 100
	$inertia 10
	$damping 0
	$rotdamping 12
	$rootbone "bip_pelvis"

	$jointmassbias "bip_pelvis" 2
	$jointrotdamping "bip_pelvis" 0

	$jointconstrain "prp_cord" x limit -30 120 0
	$jointconstrain "prp_cord" y limit -35 16 0
	$jointconstrain "prp_cord" z limit -130 95 0

	$jointmassbias "bip_hip_R" 0.8
	$jointrotdamping "bip_hip_R" 4
	$jointconstrain "bip_hip_R" x limit -45 25 0
	$jointconstrain "bip_hip_R" y limit -80 35 0
	$jointconstrain "bip_hip_R" z limit -25 25 0

	$jointmassbias "bip_knee_R" 0.8
	$jointrotdamping "bip_knee_R" 3
	$jointconstrain "bip_knee_R" x limit 0 0 0
	$jointconstrain "bip_knee_R" y limit 0 110 0
	$jointconstrain "bip_knee_R" z limit 0 0 0

	$jointmassbias "bip_foot_R" 0.75
	$jointrotdamping "bip_foot_R" 7
	$jointconstrain "bip_foot_R" x limit -10 35 0
	$jointconstrain "bip_foot_R" y limit -19 25 0
	$jointconstrain "bip_foot_R" z limit -42 24 0

	$jointmassbias "bip_hip_L" 0.8
	$jointrotdamping "bip_hip_L" 4
	$jointconstrain "bip_hip_L" x limit -45 25 0
	$jointconstrain "bip_hip_L" y limit -80 45 0
	$jointconstrain "bip_hip_L" z limit -25 25 0

	$jointmassbias "bip_knee_L" 0.8
	$jointrotdamping "bip_knee_L" 3
	$jointconstrain "bip_knee_L" x limit 0 0 0
	$jointconstrain "bip_knee_L" y limit 0 110 0
	$jointconstrain "bip_knee_L" z limit 0 0 0

	$jointmassbias "bip_foot_L" 0.75
	$jointrotdamping "bip_foot_L" 7
	$jointconstrain "bip_foot_L" x limit -10 35 0
	$jointconstrain "bip_foot_L" y limit -19 25 0
	$jointconstrain "bip_foot_L" z limit -42 24 0

	$jointmassbias "bip_spine_0" 1.6
	$jointconstrain "bip_spine_0" x limit -8 55 0
	$jointconstrain "bip_spine_0" y limit -15 15 0
	$jointconstrain "bip_spine_0" z limit -25 25 0

	$jointmassbias "bip_upperArm_R" 0.8
	$jointrotdamping "bip_upperArm_R" 16
	$jointconstrain "bip_upperArm_R" x limit -50 50 0
	$jointconstrain "bip_upperArm_R" y limit -20 55 0
	$jointconstrain "bip_upperArm_R" z limit -80 70 0

	$jointmassbias "bip_lowerArm_R" 1.8
	$jointrotdamping "bip_lowerArm_R" 4
	$jointconstrain "bip_lowerArm_R" x limit 0 0 0
	$jointconstrain "bip_lowerArm_R" y limit 0 0 0
	$jointconstrain "bip_lowerArm_R" z limit -85 20 0

	$jointmassbias "bip_upperArm_L" 0.8
	$jointrotdamping "bip_upperArm_L" 16
	$jointconstrain "bip_upperArm_L" x limit -50 50 0
	$jointconstrain "bip_upperArm_L" y limit -20 55 0
	$jointconstrain "bip_upperArm_L" z limit -70 80 0

	$jointmassbias "bip_lowerArm_L" 1.8
	$jointrotdamping "bip_lowerArm_L" 4
	$jointconstrain "bip_lowerArm_L" x limit 0 0 0
	$jointconstrain "bip_lowerArm_L" y limit -85 20 0
	$jointconstrain "bip_lowerArm_L" z limit 0 0 0

	$jointmassbias "bip_hand_L" 0.6
	$jointrotdamping "bip_hand_L" 8
	$jointconstrain "bip_hand_L" x limit -30 37 0
	$jointconstrain "bip_hand_L" y limit -30 50 0
	$jointconstrain "bip_hand_L" z limit -20 35 0

	$jointmassbias "bip_neck" 1.6
	$jointconstrain "bip_neck" x limit -30 30 0
	$jointconstrain "bip_neck" y limit -50 50 0
	$jointconstrain "bip_neck" z limit -26 23 0

	$jointmassbias "bip_head" 2.5
	$jointrotdamping "bip_head" 8
	$jointconstrain "bip_head" x limit -25 8 0
	$jointconstrain "bip_head" y limit -8 8 0
	$jointconstrain "bip_head" z limit -15 15 0

	$jointmassbias "bip_hand_R" 0.6
	$jointrotdamping "bip_hand_R" 8
	$jointconstrain "bip_hand_R" x limit -37 30 0
	$jointconstrain "bip_hand_R" y limit -40 50 0
	$jointconstrain "bip_hand_R" z limit -35 20 0

	$jointconstrain "prp_legPouch" x limit -57 17 0
	$jointconstrain "prp_legPouch" y limit -35 30 0
	$jointconstrain "prp_legPouch" z limit -20 30 0

	$jointcollide "prp_legPouch" "bip_pelvis"
	$jointcollide "prp_legPouch" "bip_hip_L"
	$jointcollide "prp_cord" "bip_pelvis"
	$jointcollide "prp_cord" "bip_hip_R"
	$jointcollide "bip_foot_R" "bip_foot_L"
	$jointcollide "bip_foot_R" "bip_knee_L"
	$jointcollide "bip_foot_R" "bip_hip_L"
	$jointcollide "bip_knee_R" "bip_foot_L"
	$jointcollide "bip_knee_R" "bip_knee_L"
	$jointcollide "bip_knee_R" "bip_hip_L"
	$jointcollide "bip_hip_R" "bip_foot_L"
	$jointcollide "bip_hip_R" "bip_knee_L"
	$jointcollide "bip_hip_R" "bip_hip_L"
	$jointcollide "bip_hand_R" "bip_knee_R"
	$jointcollide "bip_hand_R" "bip_foot_R"
	$jointcollide "bip_hand_R" "bip_head"
	$jointcollide "bip_hand_R" "bip_spine_0"
	$jointcollide "bip_hand_R" "bip_pelvis"
	$jointcollide "bip_hand_R" "bip_hip_R"
	$jointcollide "bip_lowerArm_R" "bip_head"
	$jointcollide "bip_lowerArm_R" "bip_spine_0"
	$jointcollide "bip_lowerArm_R" "bip_pelvis"
	$jointcollide "bip_lowerArm_R" "bip_hip_R"
	$jointcollide "bip_upperArm_R" "bip_spine_0"
	$jointcollide "bip_hand_L" "bip_knee_L"
	$jointcollide "bip_hand_L" "bip_foot_L"
	$jointcollide "bip_hand_L" "bip_hand_R"
	$jointcollide "bip_hand_L" "bip_head"
	$jointcollide "bip_hand_L" "bip_spine_0"
	$jointcollide "bip_hand_L" "bip_pelvis"
	$jointcollide "bip_hand_L" "bip_hip_L"
	$jointcollide "bip_lowerArm_L" "bip_hand_R"
	$jointcollide "bip_lowerArm_L" "bip_lowerArm_R"
	$jointcollide "bip_lowerArm_L" "bip_head"
	$jointcollide "bip_lowerArm_L" "bip_spine_0"
	$jointcollide "bip_lowerArm_L" "bip_pelvis"
	$jointcollide "bip_lowerArm_L" "bip_hip_L"
	$jointcollide "bip_upperArm_L" "bip_spine_0"
}

$collisiontext
{
	break 
	{
		"model"		"player\gibs\engineergib006"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib001"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib003"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib005"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\random_organ"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib002"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib004"
		"health"		"0"
		"fadetime"		"10"
	}
	break 
	{
		"model"		"player\gibs\engineergib007"
		"health"		"0"
		"fadetime"		"10"
	}
}
