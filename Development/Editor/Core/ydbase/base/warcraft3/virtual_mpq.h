#pragma once

#include <base/config.h>
#include <boost/filesystem.hpp>
#include <Windows.h>

namespace base { namespace warcraft3 { namespace virtual_mpq {
	
	_BASE_API void open_path(const boost::filesystem::path& p, uint32_t priority);
	_BASE_API void initialize(HMODULE module_handle);
}}}
