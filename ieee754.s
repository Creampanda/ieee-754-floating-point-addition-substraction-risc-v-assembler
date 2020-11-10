.global __start

.text

__start:
  li  s1, 0x45a4f500 # first num 5278.625
  li  s2, 0xc583b1f0 # second num -4214.2421875  #answer =  1064.3828125 = 0x44850c40
  xor  s7, s1, s2 # getting sign bit 
  li   s4, 0x7f800000 # constant for getting exp
before_cmp:  
  and  t1, s1, s4 # в t1 - first exp
  mv   s5, t1 # saving exp
  and  t2, s2, s4 # t2 - second exp
  bgt  t1, t2, _main # if t1>t2 jump main
  bne  t1, t2, change_operands #if t1 != t2 go swap operands
  li   s4,0x007fffff # const for mantissa
  and  t1, s1, s4 # if exponents equal, compare mantiss
  and  t2, s2, s4
  bgt  t1, t2, _main # if t1<t2 swap
change_operands:
  mv   s3, s1
  mv   s1, s2
  mv   s2, s3
  j before_cmp
_main:
  srli t1, t1, 0x17 # move exp to lower bits
  srli t2, t2, 0x17
  sub  t3, t1, t2 # get difference in exps
  li   s4,0x007fffff # const for mantissa
  and  t1, s1, s4 # get mantissa from operands
  and  t2, s2, s4
  li   s4, 0x00800000 # const for get normalized num 
  or   t1, t1, s4 # making nums normalized
  or   t2, t2, s4
  srl  t2, t2, t3 # shift the difference
  bltz s7, different_signs # if numbers different signs 
  add  t4, t1, t2 # get mantissa
  #if >= 0x01000000
  li   t5, 0x00ffffff 
  ble  t4, t5, finish # watch if need to change exp 
  li   t5, 0x00800000
  add  s5, s5, t5 # adding to exp
  srli t4, t4, 0x1  
finish:
  li   s4, 0x007fffff # const for mantissa
  and  t4, t4, s4 # get mantissa
  add  s5, s5, t4 # adding mantissa to exp
  # if the bigger number is positive - answer is positive
  # if the bigger number is negative - answer is negative
  bgtz s1, first_positive #Branch if > zero
  li   s4, 0x80000000 # -0
  or   s5, s5, s4 # make answer negative
first_positive:
  addi s5, s5, 0
  j first_positive
  

different_signs:
  sub  t4, t1, t2 # get mantissa
  beqz t4, decrease_exp # if we get 0 we decrease exp
loop:
  bge  t4, s4, finish
  slli t4, t4, 0x1 # shift left to make num normalized
  sub  s5, s5, s4 # decreae exp
  j loop
decrease_exp:
  sub  s5, s5, s4 # decrease exp
  j finish
