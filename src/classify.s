.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # Check the number of args
    li t0, 5
    bne t0, a0, argc_error

    # Prologue
    addi sp, sp, -48
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    
    lw s0, 4(a1)
    lw s1, 8(a1)
    lw s2, 12(a1)
    lw s3, 16(a1)
    
    # Save a2 and ra
    addi sp, sp, -8
    sw a2, 0(sp)
    sw ra, 4(sp)
    
    # Read pretrained m0
    li a0, 8
    jal malloc      # Allocate memory for row and col number pointers of m0 
    beq x0, a0, malloc_error  # If malloc failed
    
    mv s7, a0       # Set s7 as a pointer to allocated memory
    
    mv a1, a0       # Set a1 as a pointer to the number of rows
    addi a0, a0, 4
    mv a2, a0       # Set a2 as a pointer to the number of cols
    mv a0, s0       # Set a0 as pointer to m0
    jal read_matrix
    
    mv s4, a0       # Save address of m0 to s4
    
    # Free the memory
    #mv a0, t0
    #jal free


    # Read pretrained m1
    li a0, 8
    jal malloc      # Allocate memory for row and col number pointers of m1 
    beq x0, a0, malloc_error  # If malloc failed
    
    mv s8, a0       # Set s8 as a pointer to allocated memory
    
    mv a1, a0       # Set a1 as a pointer to the number of rows
    addi a0, a0, 4
    mv a2, a0       # Set a2 as a pointer to the number of cols
    mv a0, s1       # Set a0 as pointer to m1
    jal read_matrix
    
    mv s5, a0   # Save address of m1 to s5
    
    # Free the memory 
    #mv a0, t0
    #jal free


    # Read input matrix
    li a0, 8
    jal malloc      # Allocate memory for row and col number pointers of input matrix 
    beq x0, a0, malloc_error  # If malloc failed
    
    mv s9, a0       # Set s9 as a pointer to allocated memory
    
    mv a1, a0       # Set a1 as a pointer to the number of rows
    addi a0, a0, 4
    mv a2, a0       # Set a2 as a pointer to the number of cols
    mv a0, s2       # Set a0 as pointer to input matrix
    jal read_matrix
    
    mv s6, a0       # Save address of input matrix to s6
    
    # Free the memory 
    #mv a0, t0
    #jal free

    # Compute h = matmul(m0, input)
    lw t0, 0(s7)    # Load rows number of m0
    lw t1, 4(s9)    # Load cols number of input matrix
    mul s0, t0, t1  # Now set s0 as size of h
    slli a0, s0, 2  # Bytes needed for h
    jal malloc 

    beq a0, x0, malloc_error    # If malloc failed
    
    mv s10, a0      # Set s10 as pointer to h
    
    mv a0, s4       # Set a0 as the start of m0
    lw a1, 0(s7)    # Set a1 as the number of rows of m0
    lw a2, 4(s7)    # Set a2 as the number of cols of m0
    mv a3, s6       # Set a3 as the start of input matrix
    lw a4, 0(s9)    # Set a4 as the number of rows of input matrix
    lw a5, 4(s9)    # Set a5 as the number of cols of input matrix
    mv a6, s10      # Set a6 as pointer to the start of the result matrix
    jal matmul
    
    
    # Compute h = relu(h)
    mv a0, s10      # Set a0 as pointer to h
    mv a1, s0       # Set a1 as size of h
    jal relu
    
    
    # Compute o = matmul(m1, h)
    lw t0, 0(s8)    # Load rows number of m1
    lw t1, 4(s9)    # Load cols number of h(same to input)
    mul s1, t0, t1  # Now set s1 as size of o
    slli a0, s1, 2  # Bytes needed for o
    jal malloc 
    beq a0, x0, malloc_error    # If malloc failed
    
    mv s11, a0      # Set s11 as pointer to o
    
    mv a0, s5       # Set a0 as the start of m1
    lw a1, 0(s8)    # Set a1 as the number of rows of m1
    lw a2, 4(s8)    # Set a2 as the number of cols of m1
    mv a3, s10      # Set a3 as the start of h
    lw a4, 0(s7)    # Set a4 as the number of rows of h(same to m0)
    lw a5, 4(s9)    # Set a5 as the number of cols of h(same to input)
    mv a6, s11      # Set a6 as pointer to the start of the result matrix
    jal matmul


    # Write output matrix o
    mv a0, s3       # Set a0 as pointer to output file
    mv a1, s11      # Set a1 as pointer to o
    lw a2, 0(s8)    # Load rows number of o(same to m1)
    lw a3, 4(s9)    # Load cols number of o(same to h / input)
    jal write_matrix
    
    
    # Compute and return argmax(o)
    mv a0, s11      # Set a0 as pointer to o
    mv a1, s1       # Set a1 as size of o
    jal argmax
    mv s3, a0       # Save return value in s3
 
   
    # Free heap
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    mv a0, s11
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free


    # If enabled, print argmax(o) and newline
    lw a2, 0(sp)
    addi sp, sp, 4
    
    bne x0, a2, continue    # Check if a2 is 0(need to print)
    mv a0, s3
    jal print_int   # Print result
    li a0, '\n'
    jal print_char       # Print a new line
        
    
continue:  
    # Set the value to return 
    mv a0, s3
    lw ra, 0(sp)
    addi sp, sp, 4

    # Epilogue    
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    addi sp, sp, 48

    jr ra
    
# Error handlers:
malloc_error:
    li a0, 26
    j exit
    
argc_error:
    li a0, 31
    j exit
