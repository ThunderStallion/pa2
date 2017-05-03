section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 41
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-8], eax
  mov eax, 12
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-12], eax
  mov eax, [esp-8]
  cmp eax, [esp-12]
jg near temp_l_pass_11
  mov eax, 0x7FFFFFFF
jmp near temp_l_finished_12
temp_l_pass_11:
  mov eax, 0xFFFFFFFF
temp_l_finished_12:
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
