#ifndef TO_STRING_H_
#define TO_STRING_H_

#include <string>
#include <sstream>

#ifndef to_string
template<typename T> std::string to_string(const T& v) {
  std::ostringstream ss;
  ss << v;
  return ss.str() ;
}
#endif

#endif
