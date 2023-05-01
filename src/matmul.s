.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    bge x0, a1, Error
    bge x0, a2, Error
    bge x0, a4, Error
    bge x0, a5, Error
    bne a2, a4, Error
    
    # Prologue
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    # Init registers
    mv t0, a6   # Set t0 as the position of mat C to be written
    mv t1, x0   # Set t1 as i
    mv t2, x0   # Set t2 as j
    
    mv s0, a0   # Set s0 as the start pos of Mat A
    mv s1, a3   # Set s1 as the start pos of Mat B
    mv s2, x0   # Set s2 as return value of dot
    mv s3, x0
    # ebreak
outer_loop_start:
    bge t1, a1, outer_loop_end  # If i >= Mat A height, end outer loop
    # ebreak
    mv t2, x0   # j = 0
    mv s1, a3   # Set s1 as the start pos of Mat B
inner_loop_start:
    bge t2, a5, inner_loop_end  # If j >= Mat B width, end inner loop
    
    # Save registers before calling dot
    addi sp, sp, -44
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    sw t0, 28(sp)
    sw t1, 32(sp)
    sw t2, 36(sp)
    
    sw ra, 40(sp)
    # ebreak
    # Calculate the Mat C element
    mv a0, s0  # Set a0 as beginning pos of the Mat A
    mv a1, s1  # Set a1 as beginning pos of the Mat B
    mv a2, a4  # Set num of elements to use (height of Mat B)
    li a3, 1   # Set the stride of arr1(Mat A) as 1
    mv a4, a5  # Set the stride of arr2(Mat B) as its width
    jal dot
    mv s2, a0  # Save return value at s2
    
    # Restore registers after calling dot
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    lw t0, 28(sp)
    lw t1, 32(sp)
    lw t2, 36(sp)
    
    lw ra, 40(sp)
    addi sp, sp, 44
    
    sw s2, 0(t0)    # Save the result to corresponding pos in Mat C
    
    addi t0, t0, 4  # Update t0 to next pos of Mat C
    addi t2, t2, 1  # j++
    slli s3, t2, 2  # Set s3 as offset of Mat B array(s3 = 4 * j)
    add s1, a3, s3  # Update the start pos of Mat B array(To the next col)
    
    j inner_loop_start

inner_loop_end:

    addi t1, t1, 1  # i++
    slli s3, a2, 2  # Set s3 as length of the Mat A array width
    add s0, s0, s3  # Update the start pos of Mat A array(To the next row)
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16

    jr ra

Error:
    li a0, 38
    j exit