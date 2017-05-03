section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 1
  shl eax, 1
  mov [esp-4], eax
  mov eax, 2
  shl eax, 1
  mov [esp-8], eax
  mov eax, [esp-8]
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
