section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here: 

  mov eax, 43
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-8], eax
  mov eax, 3
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-12], eax
  mov eax, [esp-8]
  sub eax, [esp-12]
jo near error_overflow
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-8], eax
  mov eax, 24
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-12], eax
  mov eax, [esp-8]
  sub eax, [esp-12]
jo near error_overflow
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-8], eax
  mov eax, 2
  shl eax, 1
  mov [esp-4], eax
  and  eax, DWORD 0x1
  cmp eax, DWORD 0x0
jne near error_non_int
  mov eax, [esp-4]
  mov [esp-12], eax
  mov eax, [esp-8]
  imul eax, [esp-12]
jo near error_overflow
  shr eax, 1
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
