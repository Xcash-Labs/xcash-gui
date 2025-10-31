#pragma once
#include <boost/asio.hpp>

namespace boost { namespace asio {
  // Provide old name for newer Boost (maps io_service -> io_context)
  using io_service = io_context;
}}
