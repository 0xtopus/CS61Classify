.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue

    # Init registers
    add t0, x0, a0  # Set t0 as address of the first element
    lw t1, 0(t0)    # Set t1 as max value
    add t2, x0, x0  # Set t2 as the index of max
    add t3, x0, x0  # Set t3 as next index
    addi t3, t3, 1  
    addi t0, t0, 4  # Set t0 as the second element
    
    # Handle exception
    bge x0, a1, Error
    beq t3, a1, loop_end   
loop_start:
    lw t4, 0(t0)    # Get next value
    bge t1, t4, loop_continue   # Check if the next greater than the current
    mv t1, t4   # Update max
    mv t2, t3   # Update max index
    
loop_continue:
    addi t3, t3, 1  # Increase count by 1
    addi t0, t0, 4  # Set t0 as the next address
    blt t3, a1, loop_start  # Go through all elements

loop_end:
    mv a0, t2   # Set max index to return
    # Epilogue

    jr ra

# Exception Handler
Error:
    li a0, 36
    j exit