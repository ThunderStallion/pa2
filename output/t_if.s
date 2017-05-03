section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 0xFFFFFFFF
  mov [esp-4], eax
  mov eax, [esp-4]
  cmp eax, 0xFFFFFFFF
je near temp_then_1
  cmp eax, 0x7FFFFFFF
je near temp_else_2
jmp near error_non_bool
temp_then_1:
  mov eax, 42
  shl eax, 1
jmp near temp_end_3
temp_else_2:
  mov eax, 13
  shl eax, 1
temp_end_3:
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
