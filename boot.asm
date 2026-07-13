bits 16
org 0x7C00


mov si,message
call print_string









shell:
    call print_newline
    mov si,prompt
    call print_string
    
    mov di, buffer
    call read_string
    
    ;compare input with the help command
    
    mov si, buffer
    mov di, command_help
    call compare_string
    
    cmp al,1
    je help_command
    
    ;compare input with clear command
    
    mov si, buffer
    mov di, command_clear
    call compare_string
    
    cmp al,1
    je clear_command
    
    
    ;if command not matched
    
    mov si, command_unknown
    call print_string
    
    jmp shell    
    
jmp $



print_newline:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    ret
    


print_string:
    mov ah, 0x0E
    
    .next:
        lodsb
        cmp al,0
        je .done

        int 0x10
        jmp .next

    .done:
        ret
    
print_char:
    mov ah,0x0E
    int 0x10
    ret
    


read_string:
    .next_key:
        mov ah,0x00
        int 0x16            ;Wait for input
        
        cmp al,0x0D         ;Compare if enter was pressed
        je .done            ;check if bit changed then jump to done
        
        cmp al,0x08
        je .backspace
        
        
        stosb               ;store AL into [DI], DI++
        call print_char
        jmp .next_key
        
    .done:
        mov al,0            ;Terminate String
        stosb
        ret
    
    .backspace:
        cmp di,buffer
        je .next_key
        
        dec di
        
        mov al,0x08
        call print_char
        
        mov al, ' '
        call print_char
        
        mov al, 0x08
        call print_char
        
        jmp .next_key
        
    
    
clear_command:
    mov ah,0x00
    mov al,0x03
    int 0x10
    
    jmp shell
    


compare_string:
    .next:
        mov al,[si]
        mov bl,[di]
        
        cmp al,bl
        jne .not_equal
        
        cmp al,0
        jmp .equal
        
        inc si
        inc di
        
        jmp .next
    
    .not_equal:
        mov al,0
        ret
    
    .equal:
        mov al,1
        ret
        
help_command:
    mov si, help_message
    call print_string
    jmp shell






message db 'Hello vivek I am your new operating system Vivek Bhaiya OS built by mr vivek bhaiya',0  
prompt db 0x0d,0x0a,'VivekOs>',0
command_help db 'help',0
command_unknown db 0x0d,0x0a,'Unknown command given please use right command',0
help_message db 0x0d,0x0a,'Hello Shree Krishna Ji here to help you!',0
command_clear db 'clear',0

buffer times 50 db 0


times 510-($-$$) db 0



dw 0xAA55