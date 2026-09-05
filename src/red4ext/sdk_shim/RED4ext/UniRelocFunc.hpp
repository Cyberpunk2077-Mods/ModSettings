#pragma once

#include <RED4ext/Relocation.hpp>

namespace RED4ext
{
template<typename T>
class UniRelocFunc
{
};

template<typename R, typename... Args>
class UniRelocFunc<R (*)(Args...)> : public UniversalRelocFunc<R (*)(Args...)>
{
    using UniversalRelocFunc<R (*)(Args...)>::UniversalRelocFunc;
};

template<typename C, typename R, typename... Args>
class UniRelocFunc<R (C::*)(Args...)> : public UniversalRelocFunc<R (*)(C*, Args...)>
{
    using UniversalRelocFunc<R (*)(C*, Args...)>::UniversalRelocFunc;
};
} // namespace RED4ext
