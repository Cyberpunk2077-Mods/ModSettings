#pragma once

// clang-format off

// Shadow WopsS stub with jackhumbert's handcrafted RuntimeSettingsVar-backed type.

#include <cstdint>
#include <RED4ext/Common.hpp>
#include <RED4ext/Scripting/IScriptable.hpp>
#include <RED4ext/Scripting/Natives/userSettingsVar.hpp>

namespace RED4ext
{
namespace user
{
RED4EXT_ASSERT_SIZE(SettingsVar, 0x48);

} // namespace user
using userSettingsVar = user::SettingsVar;
using ConfigVar = user::SettingsVar;
} // namespace RED4ext

// clang-format on
