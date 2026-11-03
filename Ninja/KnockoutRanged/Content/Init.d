// oCNpc::OnDamage_Condition() in Gothic 2 NotR 2.6, starts with "push -1; push imm32" (7 bytes)
const int Patch_KnockoutRanged_oCNpc__OnDamage_Condition = 6737712; //0x66CF30

// Called by Ninja after Init_Global
func void Ninja_KnockoutRanged_Init() {
    LeGo_MergeFlags(LeGo_HookEngine);

    const int hooked = 0;
    if (hooked) {
        return;
    };

    // Another plugin (e.g. Union) may already have patched the function start
    if (MEM_ReadByte(Patch_KnockoutRanged_oCNpc__OnDamage_Condition) != /*push imm8*/ 106) {
        MEM_Warn("KnockoutRanged: oCNpc::OnDamage_Condition is already patched, the patch is disabled.");
        hooked = 1;
        return;
    };

    HookEngineF(Patch_KnockoutRanged_oCNpc__OnDamage_Condition, 7, Patch_KnockoutRanged_OnDamageCondition);
    hooked = 1;
};
