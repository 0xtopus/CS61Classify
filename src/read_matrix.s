.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -12
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    # Save registers
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)
    sw a1, 4(sp)
    sw a2, 0(sp)

    # Call fopen
    j fopen
    
    li t0, -1
    beq a0, t0, fopen_error # If open file fails

    mv s0, a0   # Save file descriptor to s0
    
    # Call fread to read row
    li a2, 1    # Read the row of the given array
    lw a1, 4(sp)    # Load the row pointer(original a1) to fread param
    j fread 
    
    # If an error occurred
    li t0, 1
    bne a0, t0, fread_error
    
    # Call fread to read col
    li a2, 1    # Read the col of the given array
    lw a1, 0(sp)    # Load the col pointer(original a2) to fread param
    mv a0, s0   # Set descriptor to a0
    j fread
    
    # If an error occurred
    li t0, 1
    bne a0, t0, fread_error
    
    # Call malloc
    lw t0, 4(sp)    # t0 as row
    lw t1, 0(sp)    # t1 as col
    mul a0, t0, t1  # Calculate the array size
    mv s1, a0   # Set s1 as size of the array
    j malloc    
    
    beq a0, x0, malloc_error    # If malloc failed
    
    mv s2, a0   # Save pointer of alloctated memory in s2
    
    # Read the matrix from the file
    mv t0, s2   # Set t0 as pointer to address of the array element to be written
    add t1, x0, x0  # Set t1 as count
loop_start_setarray:    
    blt t1, s1, loop_end_setarray   # If all elements are set
    
    mv a0, s0   # Set descriptor
    mv a1, t2   # Set address
    li a2, 1    # Set the number of byte to read
    j fread
    
    # If fread failed
    li t2, 1
    bne a0, t2, fread_error
    
    addi t0, t0, 4  # Move to next array element
    addi t1, t1, 1  # count++
    j loop_start_setarray

loop_end_setarray:
    
    
    # Close the file
    mv a0, s0
    j fclose
    
    # If fclose failed
    li t0, -1
    beq a0, t0, fclose_error
    
    # Restore registers
    lw ra, 12(sp)
    lw a0, 8(sp)
    lw a1, 4(sp)
    lw a2, 0(sp)
    addi sp, sp, 16
    
    mv a0, s2   # Set return value as matrix address
    
    # Epilogue
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 12

    jr ra


# Error handlers:
fopen_error:
    li a0, 27
    j exit
    
malloc_error:
    li a0, 26
    j exit

fclose_error:
    li a0, 28
    j exit

fread_error:
    li a0, 29
    j exit