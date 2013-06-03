signature PARSER =
  sig
    type result

    exception SyntaxError

    val parse : TextIO.instream -> result

  end
