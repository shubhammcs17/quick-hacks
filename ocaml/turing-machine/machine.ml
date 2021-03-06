(*
  Implementation of a turing machine.
*)


type state   = string
type rule    = state * Tape.symbol * state * Tape.symbol * Tape.direction
type machine = rule list * state * state * Tape.tape

exception Converged
exception Deadlock


(*
  New turing machine.
*)
let create rules start_state stop_state symbols =
  rules, start_state, stop_state, (Tape.create symbols)


(*
  Apply one rule.
*)
let step machine =
  let (rules, state, stop_state, tape) = machine in
  if state = stop_state then
    raise Converged
  else
    let predicate (s, c, _, _, _) = (s = state && c = (Tape.read tape)) in
    try
      let (_, _, s, c, d) = List.find predicate rules in
      rules, s, stop_state, (Tape.step c d tape)
    with
      | Not_found -> raise Deadlock


(*
  Apply rules until:
  - no rule applies (diverge)
  - we reach the stop_state (converge)
*)
let rec run machine =
  try
    let m = step machine in
    run m
  with
    | Converged -> machine


(*
  Current state.
*)
let state machine =
  let _, state, _, _ = machine in
  state


(*
  Get contents of the tape as a triple:
  - list of symbols before the reading head
  - symbol at the reading head
  - list of symbols after the reading head
*)
let tape machine =
  let _, _, _, tape = machine in
  Tape.contents tape
