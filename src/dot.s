.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Exception handler
    bge x0, a2, length_error
    bge x0, a3, stride_error
    bge x0, a4, stride_error

    # Prologue
    addi sp, sp, -8
    sw s0, 4(sp)
    sw s1, 0(sp)
    
    # Init registers
    add t0, x0, a0  # Set t0 as address of elements of arr0
    add t1, x0, a1  # Set t1 as address of elements of arr1
    add t2, x0, x0  # Set t2 as count of arr0
    add t3, x0, x0  # Set t3 as count of arr1
    lw t4, 0(t0)    # Set t4 as the value of arr0[0]
    lw t5, 0(t0)    # Set t5 as the value of arr1[0]
    
    mul s0, t4, t5  # Set s0 as sum of product results
    addi s1, x0, 4  # Set s1 as length of a word
loop_start:    
    bge  t2, a2, loop_end
    bge  t3, a2, loop_end
        
    add t2, t2, a3  # Increase arr0 count by stride
    mul t6, t2, s1  # Calculate offset of arr0
    add t0, t0, t6  # Get next address of arr0
    lw t4, 0(t0)    # Get next value of arr0
    
    add t3, t3, a4  # Increase arr1 count by stride
    mul t6, t3, s1  # Calculate offset of arr1
    add t1, t1, t6  # Get next address of arr1
    lw t5, 0(t0)    # Get next value of arr1
    
    mul t6, t4, t5  # Get next product
    add s0, s0, t6  # Add next product to sum
        
    j loop_start

loop_end:
    add a0, s0, x0

    # Epilogue
    lw s0, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 8
    
    jr ra

length_error:
    addi a0, x0, 36
    j exit
    
stride_error:
    addi a0, x0, 37
    j exit