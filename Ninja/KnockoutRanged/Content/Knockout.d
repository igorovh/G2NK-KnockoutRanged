/*
 * Knockout with Ranged Weapons
 *
 * The engine only knocks humans out if the lethal hit was blunt or edge damage. Projectiles deal point damage, so a
 * lethal shot always kills. This patch hooks oCNpc::OnDamage_Condition() and, for lethal shots of the player, restores
 * 1 HP if C_DropUnconscious allows a knockout. The engine then knocks the NPC out as in melee combat.
 */

// oSDamageDescriptor fields and damage type flags
const int Patch_KnockoutRanged_desc_attackerNpc_offset = 8;
const int Patch_KnockoutRanged_desc_dmgMode_offset     = 36;
const int Patch_KnockoutRanged_DAM_BLUNT               = 2;
const int Patch_KnockoutRanged_DAM_EDGE                = 4;
const int Patch_KnockoutRanged_DAM_POINT               = 64;

func void Patch_KnockoutRanged_RestoreInst(var int inst, var int ptr) {
    if (ptr) {
        MEM_AssignInst(inst, ptr);
    } else {
        MEM_AssignInstNull(inst);
    };
};

// Ask the mod scripts whether the victim may be knocked out by the attacker, as the engine does
func int Patch_KnockoutRanged_DropUnconscious(var int victimPtr, var int attackerPtr) {
    var int funcId; funcId = MEM_GetSymbolIndex("C_DROPUNCONSCIOUS");
    if (funcId == -1) {
        var C_Npc victim; victim = _^(victimPtr);
        return (victim.guild < 16);
    };

    var int selfBak; selfBak = _@(self);
    var int otherBak; otherBak = _@(other);
    MEM_AssignInst(self, victimPtr);
    MEM_AssignInst(other, attackerPtr);
    MEM_CallById(funcId);
    var int result; result = MEM_PopIntResult();
    Patch_KnockoutRanged_RestoreInst(self, selfBak);
    Patch_KnockoutRanged_RestoreInst(other, otherBak);
    return result;
};

// Hooks the start of oCNpc::OnDamage_Condition(oSDamageDescriptor&), after the damage was subtracted from the HP
func void Patch_KnockoutRanged_OnDamageCondition() {
    var int victimPtr; victimPtr = ECX;
    var int desc; desc = MEM_ReadInt(ESP + 4);
    if (!victimPtr) || (!desc) {
        return;
    };

    var int attackerPtr; attackerPtr = MEM_ReadInt(desc + Patch_KnockoutRanged_desc_attackerNpc_offset);
    if (!attackerPtr) {
        return;
    };
    var C_Npc attacker; attacker = _^(attackerPtr);
    if (!Npc_IsPlayer(attacker)) {
        return;
    };

    // Melee hits (blunt/edge) already knock out, only point damage of projectiles needs help
    var int dmgMode; dmgMode = MEM_ReadInt(desc + Patch_KnockoutRanged_desc_dmgMode_offset);
    if (!(dmgMode & Patch_KnockoutRanged_DAM_POINT))
    || (dmgMode & (Patch_KnockoutRanged_DAM_BLUNT | Patch_KnockoutRanged_DAM_EDGE)) {
        return;
    };

    var C_Npc victim; victim = _^(victimPtr);
    if (victim.attribute[/*ATR_HITPOINTS*/ 0] > 0) {
        return;
    };

    if (!Patch_KnockoutRanged_DropUnconscious(victimPtr, attackerPtr)) {
        return;
    };

    victim.attribute[/*ATR_HITPOINTS*/ 0] = 1;
};
