#pragma once

// This file is generated from the Game's Reflection data

#include <cstdint>
#include <RED4ext/Common.hpp>
#include <RED4ext/Scripting/IScriptable.hpp>
#include <RED4ext/Scripting/Natives/userRuntimeSettingsVar.hpp>

namespace RED4ext
{
namespace user { 
struct SettingsVar : IScriptable
{
    static constexpr const char* NAME = "userSettingsVar";
    static constexpr const char* ALIAS = "ConfigVar";
    // 1.6  RVA: 0x1D3EB10
    // static constexpr const uintptr_t VFT = 0x31801C8;

    RuntimeSettingsVar * runtimeVar; // 40
};
RED4EXT_ASSERT_SIZE(SettingsVar, 0x48);

} // namespace user
using ConfigVar = user::SettingsVar;
using userSettingsVar = user::SettingsVar;
} // namespace RED4ext
