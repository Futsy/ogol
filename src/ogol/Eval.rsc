module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;
import util::Math;
import String;
import ParseTree;
import IO;

alias FunEnv = map[FunId id, FunDef def];
alias VarEnv = map[VarId id, Value val];

data Value
  = boolean(bool b)
  | number(real i)
  | color(int c)
  ;

// Booleans
Value eval((Expr)`true`, VarEnv env)
  = boolean(true);

Value eval((Expr)`false`, VarEnv env)
  = boolean(false);
  
// Numbers
Value eval((Expr)`<Number n>`, VarEnv env)
  = number(toReal(unparse(n)));

// Doubles
Value eval((Expr)`<Double d>`, VarEnv env)
  = number(toReal(unparse(d)));

// Color
Value eval((Expr)`<Color c>`, VarEnv env)
  = color(unparse(c));

// Variables
Value eval((Expr)`<VarId x>`, VarEnv env)
  = env[x];

// Arithmetic
Value eval((Expr)`<Expr lhs> * <Expr rhs>`, VarEnv env)
  = number(x * y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);
    
Value eval((Expr)`<Expr lhs> / <Expr rhs>`, VarEnv env)
  = number(x / y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);
    
Value eval((Expr)`<Expr lhs> + <Expr rhs>`, VarEnv env)
  = number(x + y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> - <Expr rhs>`, VarEnv env)
  = number(x - y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> \> <Expr rhs>`, VarEnv env)
  = boolean(x > y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> \< <Expr rhs>`, VarEnv env)
  = boolean(x < y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> = <Expr rhs>`, VarEnv env)
  = boolean(x == y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> \>= <Expr rhs>`, VarEnv env)
  = boolean(x >= y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> \<= <Expr rhs>`, VarEnv env)
  = boolean(x <= y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> != <Expr rhs>`, VarEnv env)
  = boolean(x != y)
  when
    number(x) := eval(lhs, env),
    number(y) := eval(rhs, env);

Value eval((Expr)`<Expr lhs> && <Expr rhs>`, VarEnv env)
  = boolean(x && y)
  when
    boolean(x) := eval(lhs, env),
    boolean(y) := eval(rhs, env);
  
Value eval((Expr)`<Expr lhs> || <Expr rhs>`, VarEnv env)
  = boolean(x || y)
  when
    boolean(x) := eval(lhs, env),
    boolean(y) := eval(rhs, env);

alias Turtle = tuple[int dir, bool pendown, Point position];
alias State = tuple[Turtle turtle, Canvas canvas];

// Top-level eval function
FunEnv collectFunDefs(Program p)
  = ( f.id: f | 
  /FunDef f := p ); 

Canvas eval(p: (Program)`<Command* cmds>`) {
  funenv = collectFunDefs(p);
  varEnv = ();
  state = <<0, false, <0, 0>>, []>;
  
  for (c <- cmds)
  	state = evalCommand(c, funenv, varEnv, state);
  
  return state.canvas;
}

State evalBlock(b: (Program)`<Command* cmds>`, FunEnv fenv, VarEnv venv, State state) {
  for (c <- cmds)
  	state = evalCommand(c, fenv, venv, state);
  return state;
}

State evalCommand((Command)`ifelse <Expr e> <Block b1> <Block b2>`, FunEnv fenv, VarEnv venv, State state) {
  if (eval(e, venv) == boolean(true)) {
    return evalBlock(b1, fenv, venv, state);
  }
  return evalBlock(b2, fenv, venv, state);
}

State evalCommand((Command)`while <Expr e> <Block b1>`, FunEnv fenv, VarEnv venv, State state) {
  while (eval(e, env) == boolean(true)) {
  	state = evalBlock(b, fenv, venv, state);
  }
  return state;
}

State evalCommand((Command)`forward <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
  Point startPos = state.turtle.position;
  
  state.turtle.position.x = state.turtle.position.x + toInt(toReal(eval(e, venv).i) * sin(state.turtle.dir * PI() / 180));
  state.turtle.position.y = state.turtle.position.y + toInt(toReal(eval(e, venv).i) * cos(state.turtle.dir * PI() / 180));
  
  return moveTurtle(state, startPos, state.turtle.position);
}

State evalCommand((Command)`back <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
  Point startPos = state.turtle.position;
  
  state.turtle.position.x = state.turtle.position.x + toInt(toReal(eval(e, venv).i) * sin((state.turtle.dir + 180) * PI() / 180));
  state.turtle.position.y = state.turtle.position.y + toInt(toReal(eval(e, venv).i) * cos((state.turtle.dir + 180) * PI() / 180));
  
  return moveTurtle(state, startPos, state.turtle.position);
}

State moveTurtle(State state, Point startPos, Point endPos) {
  if (state.turtle.pendown) {
    state.canvas += [line(startPos, endPos)];
  }
  return state;
}

State evalCommand((Command)`pendown;`, FunEnv fenv, VarEnv venv, State state) {
  state.turtle.pendown = true;
  return state;
}

State evalCommand((Command)`penup;`, FunEnv fenv, VarEnv venv, State state) {
  state.turtle.pendown = false;
  return state;
}

State evalCommand((Command)`right <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
  state.turtle.dir += toInt(eval(e, venv).i);
  return state;
}

State evalCommand((Command)`left <Expr e>;`, FunEnv fenv, VarEnv venv, State state) {
  state.turtle.dir -= toInt(eval(e, venv).i);
  return state;
}

State evalCommand((Command)`home;`, FunEnv fenv, VarEnv venv, State state) {
  state.turtle.position.x = 0;
  state.turtle.position.y = 0;
  return state;
}

State evalCommand((Command)`<FunId f> <Expr* es>;`, FunEnv fenv, VarEnv venv, State state) {
	// wip
	return state;
}