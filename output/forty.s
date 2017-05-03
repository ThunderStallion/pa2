section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 40
  shl eax, 1
  mov [esp-4], eax
  mov eax, [esp-4]
 ret
error_overflow:
  push DWORD 3
  call error
error_non_int:
  push DWORD 1
  call error
error_non_bool:
  push DWORD 2
  call error
