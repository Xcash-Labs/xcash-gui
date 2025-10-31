#pragma once
#include <boost/asio/steady_timer.hpp>
namespace boost { namespace asio {
  using deadline_timer = steady_timer; // map old name to new
}}