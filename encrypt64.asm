; =======================================================
; NASM 64-bit Windows — XOR File Encryption / Decryption
; Final Clean Version (No syntax errors)
; =======================================================

section .data
    input_file_name     db "input.txt", 0
    output_file_name    db "output.txt", 0
    key                 db 0x5A                 ; XOR key (change if needed)

    ; Windows API constants
    GENERIC_READ        equ 0x80000000
    GENERIC_WRITE       equ 0x40000000
    OPEN_EXISTING       equ 3
    CREATE_ALWAYS       equ 2
    INVALID_HANDLE_VALUE equ -1

    buffer_size         equ 4096                ; 4 KB buffer

section .bss
    input_handle        resq 1
    output_handle       resq 1
    buffer              resb buffer_size
    bytes_io            resq 1

section .text
    global main
    extern CreateFileA, ReadFile, WriteFile, CloseHandle, ExitProcess

; -------------------------------------------------------
; MAIN FUNCTION
; -------------------------------------------------------
main:

    ; ---------------------------------------------------
    ; 1. Open Input File
    ; ---------------------------------------------------
    mov     rcx, input_file_name              ; LPCSTR lpFileName
    mov     rdx, GENERIC_READ                 ; DWORD dwDesiredAccess
    mov     r8,  0                            ; DWORD dwShareMode
    mov     r9,  0                            ; LPSECURITY_ATTRIBUTES lpSecurityAttributes
    sub     rsp, 40h                          ; Shadow space + align
    mov     dword [rsp+20h], OPEN_EXISTING    ; DWORD dwCreationDisposition
    mov     dword [rsp+28h], 0                ; DWORD dwFlagsAndAttributes
    mov     dword [rsp+30h], 0                ; HANDLE hTemplateFile
    call    CreateFileA
    add     rsp, 40h
    mov     [input_handle], rax

    cmp     rax, INVALID_HANDLE_VALUE
    je      input_file_error_exit

    ; ---------------------------------------------------
    ; 2. Create Output File
    ; ---------------------------------------------------
    mov     rcx, output_file_name
    mov     rdx, GENERIC_WRITE
    mov     r8,  0
    mov     r9,  0
    sub     rsp, 40h
    mov     dword [rsp+20h], CREATE_ALWAYS
    mov     dword [rsp+28h], 0
    mov     dword [rsp+30h], 0
    call    CreateFileA
    add     rsp, 40h
    mov     [output_handle], rax

    cmp     rax, INVALID_HANDLE_VALUE
    je      output_file_error_cleanup

; -------------------------------------------------------
; 3. Encryption Loop
; -------------------------------------------------------
read_data:
    mov     rcx, [input_handle]
    mov     rdx, buffer
    mov     r8,  buffer_size
    mov     r9,  bytes_io
    sub     rsp, 40h
    mov     dword [rsp+20h], 0
    call    ReadFile
    add     rsp, 40h

    cmp     qword [bytes_io], 0
    je      close_files

    mov     rcx, [bytes_io]
    mov     rsi, buffer
    movzx   r10, byte [key]

xor_loop:
    xor     byte [rsi], r10b
    inc     rsi
    dec     rcx
    jnz     xor_loop

    ; ---------------------------------------------------
    ; 4. Write Encrypted Bytes to Output File
    ; ---------------------------------------------------
    mov     rcx, [output_handle]
    mov     rdx, buffer
    mov     r8,  [bytes_io]
    mov     r9,  bytes_io
    sub     rsp, 40h
    mov     dword [rsp+20h], 0
    call    WriteFile
    add     rsp, 40h

    jmp     read_data

; -------------------------------------------------------
; 5. Close Handles and Exit
; -------------------------------------------------------
close_files:
    mov     rcx, [input_handle]
    call    CloseHandle

    mov     rcx, [output_handle]
    call    CloseHandle

    mov     rcx, 0
    call    ExitProcess

; -------------------------------------------------------
; ERROR HANDLERS
; -------------------------------------------------------
output_file_error_cleanup:
    mov     rcx, [input_handle]
    call    CloseHandle

input_file_error_exit:
    mov     rcx, 1
    call    ExitProcess
