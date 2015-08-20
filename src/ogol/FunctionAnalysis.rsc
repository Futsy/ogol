module ogol::FunctionAnalysis

import ogol::Syntax;
import ParseTree;
import vis::Figure;
import vis::Render;

import IO;

alias Uses = rel[str funName1, str funName2];// functions uses

// Find functions that are used in a sequence of commands
Uses funsUsedInCommands(str scopeName, Command* commands) 
  = { 
  *funsUsedInCommand(scopeName, cmd) | cmd <- commands 
};

set[str] allFuns(Program p) 
  = { "<f.id>" | /FunDef f := p };

// Find functions using the function call

Uses funsUsedInCommand(str scopeName, (Command)`to <FunId fid> <VarId* args> <Command* c> end`)
   = { *funsUsedInCommand("<fid>", cmd) | cmd<-c };

Uses funsUsedInCommand(str scopeName,  (Command)`if <Expr e> <Block b>`) {
	return funsUsedInCommands(scopeName, b.commands);
}

Uses funsUsedInCommand(str scopeName,  (Command)`ifelse <Expr e> <Block b1> <Block b2>`) {
	return funsUsedInCommands(scopeName, b1.commands) +
    	   funsUsedInCommands(scopeName, b2.commands);
}

Uses funsUsedInCommand(str scopeName,  (Command)`repeat <Expr e> <Block b>`) {
	return funsUsedInCommands(scopeName, b.commands);
}


default Uses funsUsedInCommand(str scopeName, Command c) 
	= getFunUses(scopeName, c);

Uses getFunUses(str scopeName, Command c) {
   uses = {};
   for(/FunId funid := c){
        uses += <scopeName, "<funid>">;
   };
   return uses;
}

void main(list[value] args){
    Program p = parse(#start[Program], |project://ogol/input/dashed_nested_blocks.ogol|).top;
    FunCalls = funsUsedInCommands("global", p.commands);
    AllCalls = allFuns(p);
    
    println(FunCalls);
    println("Transitive:");
    println(FunCalls+);
    println("Unused:");
    println(AllCalls - FunCalls.funName2);
    
    nodes = [];
    edges = [];
    
    for (call <- AllCalls)
    	nodes += box(text(call), id(call), size(50), fillColor("lightgreen"));
    
    for (funCall <- FunCalls)
    	edges += edge(funCall.funName1, funCall.funName2, toArrow(triangle(20)));
    	
	render(graph(nodes, edges, hint("layered"), gap(100)));
}