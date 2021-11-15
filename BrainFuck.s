.data 
memory: .skip 30000 #reserving 30000 bytes in the memory

.text
.global brainfuck

output: .asciz "%c"
input: .asciz "%c"

format_str: .asciz "We should be executing the following code:\n%s"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq $memory, %r13 		#using r13 as a pointer for the "pseudo array"
	movq %rdi, %r12 		#moving the characters into r12

	#r12 - index 
	#r13 - character
	#r15 - number of loops


loopread:

	movb (%r12), %al 		#extracting one byte into rax
	cmp $43, %al 			#comparing it with every brainfuck character 
	je plus
	cmp $45, %al
	je minus
	cmp $46, %al
	je print
	cmp $44, %al 
	je read
	cmp $62, %al 
	je shiftR
	cmp $60, %al 
	je shiftL
	cmp $91, %al
	je startLoop
	cmp $93, %al
	je stopLoop
	cmp $0, %al
	je exit

ignore:
	incq %r12 				#if it's not a specific character, we skip it and redo reading
	jmp loopread

plus:
	incb (%r13) 			#increse the memory value
	incq %r12 				#goign to the next character and redoing the reading
	jmp loopread 

minus: 
	decb (%r13) 			#decrease the memory location
	incq  %r12 				#next character and reread
	jmp loopread

print:
	movq $0, %rax			#printing the character
	movq $output, %rdi
	movq (%r13), %rsi 
	call printf 
	incq %r12 				#going to the next character
	jmp loopread

shiftR:
	incq %r13 				#going to the next memory location
	incq %r12
	jmp loopread

shiftL:
	decq %r13 				#going to a previous memory location 
	incq %r12
	jmp loopread

startLoop:
	pushq %r12 				#(subq $8, %rsp)
	pushq %r12

	movq $1, %r15 			#counting the amounts of loops
	cmpb $0,  (%r13) 		#if the memory location if 0 we skip the whole loop
	je loopSkip

	incq %r12
	jmp loopread

loopSkip:
	incq %r12 				#going through the characters if we skip the loop
	cmpb $91, (%r12) 		#if we have other '[' then we add to the counter
	jne loopSkipEnd			#otherwise we see if its a ']' to end the loop
	incq %r15

loopSkipEnd:
	cmpb $93, (%r12) 		#if it's not a closing bracket we go through the loop
	jne goThroughLoop 		#otherwise we decrement the instances of loops
	decq %r15

goThroughLoop:
	cmpq $0, %r15 			#if in the end we have 0 loops left, we can start decoding again
	jg loopSkip

	addq $16, %rsp 			#move the pointer back to the old location

	incq %r12 
	jmp loopread

stopLoop:

	cmpb $0, (%r13) 		#if the memory value if 0 we stop going through the loop
	jne redoLoop
	add $16, %rsp 			#we won't need to save the initial address of the loop
	incq %r12
	jmp loopread

redoLoop:
	movq (%rsp), %r12 		#if it's not 0 we go again to the initial address of the loop
	incq %r12
	jmp loopread

read:
	
	movq $0, %rax 
	movq $0, %rdi
	leaq (%r13), %rsi
	movq $1, %rdx 
	syscall			
	incq %r12 
	jmp loopread

exit:
	movq %rbp, %rsp 		#when done, we return to main
	popq %rbp
	ret

