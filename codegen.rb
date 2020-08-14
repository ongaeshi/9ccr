#
# codegen.rb
#

def gen(node)
  if node.kind == ND_NUM
    puts("  push #{node.val}")
    return
  end

  gen(node.lhs)
  gen(node.rhs)
  
  puts("  pop rdi")
  puts("  pop rax")

  case node.kind
  when ND_ADD
    puts("  add rax, rdi")
  when ND_SUB
    puts("  sub rax, rdi")
  when ND_MUL
    puts("  imul rax, rdi")
  when ND_DIV
    puts("  cqo")
    puts("  idiv rdi")
  when ND_EQ
    printf("  cmp rax, rdi\n")
    printf("  sete al\n")
    printf("  movzb rax, al\n")
  when ND_NE
    printf("  cmp rax, rdi\n")
    printf("  setne al\n")
    printf("  movzb rax, al\n")
  when ND_LT
    printf("  cmp rax, rdi\n")
    printf("  setl al\n")
    printf("  movzb rax, al\n")
  when ND_LE
    printf("  cmp rax, rdi\n")
    printf("  setle al\n")
    printf("  movzb rax, al\n")
  end

  puts("  push rax")
end

def codegen(node)
  # Print out the first half of assembly.
  puts(".intel_syntax noprefix")
  puts(".globl main")
  puts "main:"

  # Traverse the AST to emit assembly.
  gen(node)

  # A result must be at the top of the stack, so pop it
  # to RAX to make it a program exit code.
  puts("  pop rax");
  puts("  ret");
end
