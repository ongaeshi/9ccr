#
# tokenize.rb
#

TK_RESERVED = 0
TK_NUM = 1
TK_EOF = 2

# Token type
Token = Struct.new(
  :kind, # Token kind
  :next, # Next token
  :val,  # If kind is TK_NUM, its value
  :str,  # Token string
  :pos   # Token position in user_input
)

# Input program
$user_input = nil

# Current token
$token = nil

# Reports an error and exit.
def error(msg)
  STDERR.puts msg
  exit(1)
end

# Reports an error location and exit.
def error_at(msg, pos)
  STDERR.puts $user_input
  STDERR.puts " " * pos + "^ " 
  STDERR.puts msg
  exit(1)
end

# Consumes the current token if it matches `op`.
def consume(op)
  if $token.kind != TK_RESERVED || $token.str != op
    return false
  end
  $token = $token.next
  true
end

# Ensure that the current token is `op`.
def expect(op)
  if $token.kind != TK_RESERVED || $token.str != op
    error_at("expected '#{op}'", $token.pos)
  end
  $token = $token.next
end

# Ensure that the current token is TK_NUM.
def expect_number
  error_at("expected a number", $token.pos) if $token.kind != TK_NUM
  val = $token.val
  $token = $token.next
  val
end

def at_eof
  $token.kind == TK_EOF
end

# Create a new token and add it as the next token of `cur`.
def new_token(kind, cur, str, pos)
  tok = Token.new
  tok.kind = kind
  tok.str = str
  tok.pos = pos
  cur.next = tok
  tok
end

def startswith(p, q)
  p.include?(q)
end

# Tokenize `user_input` and returns new tokens.
def tokenize
  s = StringScanner.new($user_input)
  head = Token.new
  head.str = ""
  head.next = nil
  cur = head

  until s.eos? do
    # Skip whitespace characters.
    next if s.scan(/\s+/)

    # Multi-letter punctuator
    if s.scan(/(==)|(!=)|(<=)|(>=)/)
      cur = new_token(TK_RESERVED, cur, s[0], s.pos - s.matched_size)
      next
    end

    # Single-letter punctuator
    if s.scan(/[[:punct:]]/)
      cur = new_token(TK_RESERVED, cur, s[0], s.pos - s.matched_size)
      next
    end

    # Integer literal
    if s.scan(/[0-9]+/)
       cur = new_token(TK_NUM, cur, s[0], s.pos - s.matched_size)
       cur.val = s[0].to_i
       next
    end

    error_at("invalid token", s.pos)
  end

  new_token(TK_EOF, cur, "", s.pos)

  # cur = head.next
  # while cur do
  #   p "#{cur.kind}: #{cur.str}"
  #   cur = cur.next
  # end

  head.next
end

