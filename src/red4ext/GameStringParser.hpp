#pragma once

#include <cstddef>
#include <cstdint>

namespace ModSettings::Interop {
static_assert(sizeof(uintptr_t) == 8, "The game parser ABI requires x64.");
// Cyberpunk 2.31's RTTI slot 0x70 takes a buffer view, not an SDK CString.
// This view borrows its data; it must never free the caller's string storage.
struct StringBuffer {
  const char* data;
  uint32_t size;
  uint32_t alignment = 8;
  uint64_t allocator[2] = {};
};
static_assert(sizeof(StringBuffer) == 0x20);
static_assert(offsetof(StringBuffer, size) == 0x08);

inline bool FromString(const void* type, void* output, const char* text, uint32_t length) {
  if (!type || !output || !text) return false;
  using Parser = bool (*)(const void*, void*, const StringBuffer&);
  const auto table = *static_cast<const uintptr_t* const*>(type);
  auto parse = reinterpret_cast<Parser>(table[0x70 / sizeof(uintptr_t)]);
  if (!parse) return false;
  const StringBuffer buffer{text, length};
  return parse(type, output, buffer);
}

template<class Type, class String, class Value>
bool ReadValue(const Type* type, Value* output, const String& text) {
  if (!output) return false;
  Value parsed = *output;
  if (!FromString(type, &parsed, text.c_str(), text.Length())) return false;
  *output = parsed;
  return true;
}
} // namespace ModSettings::Interop
