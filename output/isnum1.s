section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 0x7FFFFFFF
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
je near temp_l_isNum_16
  mov eax, 0x7FFFFFFF
 ret
temp_l_isNum_16:
  mov eax, 0xFFFFFFFF
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
