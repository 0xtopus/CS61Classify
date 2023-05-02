.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    # Store registers
    addi sp, sp, -20
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    
    mv s1, a1   # Set s1 as the pointer to matrix
    mv s2, a2   # Set s2 as the number of rows
    mv s3, a3   # Set s3 as the number of cols
    
    # Open the file
    li a1, 1    # Set write-only permission 
    jal fopen   # Open the file
    li t0, -1
    beq t0, a0, fopen_error  # If fopen failed
    
    mv s0, a0   # Set s0 as the file descriptor
    
    # ebreak
    # Write number of rows and cols to the file    
    addi a1, sp, 12   # Set a1 as a pointer to number of rows
    li a2, 1
    li a3, 4
    jal fwrite
    
    li t0, 1    
    bne t0, a0, fwrite_error    # If fwrite failed
    
    mv a0, s0   # Set a0 as the file descriptor
    addi a1, sp, 16   # Set a1 as a pointer to number of cols
    li a2, 1
    li a3, 4
    jal fwrite
    
    li t0, 1    
    bne t0, a0, fwrite_error    # If fwrite failed


    # Write matrix to file
    mv a0, s0   # Set a0 as the file descriptor
    mul t0, s2, s3  # Set t0 as number of elements in array
    mv a1, s1
    mv a2, t0
    li a3, 4
    jal fwrite
    
    mul t0, s2, s3     
    bne t0, a0, fwrite_error    # If fwrite failed
    
    
    # Close the file
    mv a0, s0
    jal fclose
    
    li t0, -1
    beq a0, t0, fclose_error    # If fclose failed
    

    # Restore registers
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    lw a3, 16(sp)
    addi sp, sp, 20
    
    
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    
    jr ra

# Error handlers:
fopen_error:
    li a0, 27
    j exit
    
fwrite_error:
    li a0, 30
    j exit
    
fclose_error:
    li a0, 28
    j exit
    
