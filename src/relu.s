.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue

    # Init registers
    
    add t1, x0, x0  # Set t1 as count
    mv t2, a0       # Set t2 as address of the first element
    
    # Examine if the size smaller than 1
    bgt x0, a1, Error
    
loop_start:
    lw t0, 0(t2)   # Set t0 to value of the next element
    bge t0, x0, loop_continue   # If bigger or equal to zero, continue
    
    sw x0, 0(t2)    # Replace the negative element with zero

loop_continue:
    addi t1, t1, 1  # Increase t1 by 1
    addi t2, t2, 4  # Set t2 to address of the next element
    
    blt t1, a1, loop_start  # Loop all elements

loop_end:
    
    # Epilogue

    jr ra
    
# If an exception happens
Error:
    li a0, 36
    j exit