#
# parse.rb
#

ND_ADD = 0 # +
ND_SUB = 1 # -
ND_MUL = 2 # *
ND_DIV = 3 # /
ND_EQ  = 4 # ==
ND_NE  = 5 # !=
ND_LT  = 6 # <
ND_LE  = 7 # <=
ND_NUM = 8 # Integer

# AST node type
Node = Struct.new(
  :kind,   # Node kind
  :next,   # Next node
  :lhs,    # Left-hand side
  :rhs,    # Right-hand side
  :val,    # Used if kind == ND_NUM
)

def new_node(kind)
  node = Node.new
  node.kind = kind
  node
end

def new_binary(kind, lhs, rhs)
  node = new_node(kind)
  node.lhs = lhs
  node.rhs = rhs
  node
end

def new_num(val)
  node = new_node(ND_NUM)
  node.val = val
  node
end

# program = stmt*
def program
  head = Node.new
  cur = head

  until at_eof do
    cur.next = stmt()
    cur = cur.next
  end

  head.next
end

# stmt = expr ";"
def stmt
  node = expr()
  expect(";")
  node
end

# expr = equality
def expr
  equality()
end

# equality = relational ("==" relational | "!=" relational)*
def equality
  node = relational()

  loop do
    if consume("==")
      node = new_binary(ND_EQ, node, relational())
    elsif consume("!=")
      node = new_binary(ND_NE, node, relational())
    else
      return node
    end
  end
end

# relational = add ("<" add | "<=" add | ">" add | ">=" add)*
def relational
  node = add()

  loop do
    if consume("<")
      node = new_binary(ND_LT, node, add())
    elsif consume("<=")
      node = new_binary(ND_LE, node, add())
    elsif consume(">")
      node = new_binary(ND_LT, add(), node)
    elsif consume(">=")
      node = new_binary(ND_LE ,add(), node)
    else
      return node
    end
  end
end

# add = mul ("+" mul | "-" mul)*
def add
  node = mul()

  loop do
    if consume("+")
      node = new_binary(ND_ADD, node, mul())
    elsif consume("-")
      node = new_binary(ND_SUB, node, mul())
    else
      return node
    end
  end
end

# mul = unary ("*" unary | "/" unary)*
def mul
  node = unary()

  loop do
    if consume("*")
      node = new_binary(ND_MUL, node, unary())
    elsif consume("/")
      node = new_binary(ND_DIV, node, unary())
    else
      return node
    end
  end
end

# unary = ("+" | "-")? unary
#       | primary
def unary
  if consume("+")
    unary()
  elsif consume("-")
    new_binary(ND_SUB, new_num(0), unary())
  else
    primary()
  end
end

# primary = "(" expr ")" | num
def primary
  if consume("(")
    node = expr()
    expect(")")
    return node
  end

  new_num(expect_number())
end
