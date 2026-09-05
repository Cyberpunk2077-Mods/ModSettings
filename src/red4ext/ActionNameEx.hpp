#pragma once

#include <RED4ext/Common.hpp>
#include <RED4ext/RED4ext.hpp>
#include <RED4ext/Scripting/Natives/Generated/ink/ActionName.hpp>
#include <RedLib.hpp>

struct ActionNameEx : Red::ink::ActionName
{
    Red::CName ToName()
    {
        // inkActionName stores CName at 0x40; generated stub only exposes padding.
        return *reinterpret_cast<Red::CName*>(this->unk40);
    }
};

RTTI_EXPAND_CLASS(Red::ink::ActionName, ActionNameEx, {
    RTTI_METHOD(ToName);
});
