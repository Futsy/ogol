module ogol::Syntax                                                                                            
                                                                                                               
/*                                                                                                             
                                                                                                               
Ogol syntax summary                                                                                            
                                                                                                               
Program: Command...                                                                                            
                                                                                                               
Command:                                                                                                       
 * Control flow:                                                                                               
  if Expr Block                                                                                                
  ifelse Expr Block Block                                                                                      
  while Expr Block                                                                                             
  repeat Expr Block                                                                                            
 * Drawing (mind the closing semicolons)                                                                       
  forward Expr; fd Expr; back Expr; bk Expr; home;                                                             
  right Expr; rt Expr; left Expr; lt Expr;                                                                     
  pendown; pd; penup; pu;                                                                                      
 * Procedures                                                                                                  
  definition: to Name [Var...] Command... end                                                                  
  call: Name Expr... ;                                                                                         
                                                                                                               
Block: [Command...]                                                                                            
                                                                                                               
Expressions                                                                                                    
 * Variables :x, :y, :angle, etc.                                                                              
 * Number: 1, 2, -3, 0.7, -.1, etc.                                                                            
 * Boolean: true, false                                                                                        
 * Arithmetic: +, *, /, -                                                                                      
 * Comparison: >, <, >=, <=, =, !=                                                                             
 * Logical: &&, ||                                                                                             
                                                                                                               
Reserved keywords                                                                                              
 if, ifelse, while, repeat, forward, back, right, left, pendown,                                               
 penup, to, true, false, end                                                                                   
                                                                                                               
Bonus:                                                                                                         
 - add literal for colors                                                                                      
 - support setpencolor                                                                                         
                                                                                                               
*/                                                                                                             
                                                                                                               
start syntax Program = Command*;                                                                               
                                                                                                               
syntax FunDef = "to" FunId id VarId* Command* "end";                                                              
                                                                                                               
syntax Command                                                                                                 
  = FunDef                                                                                                     
  | If: 		"if" Expr Block                                                                                
  | IfElse: 	"ifelse" Expr Block Block                                                                      
  | While:		"while" Expr Block                                                                             
  | Repeat:  	"repeat" Expr Block                                                                            
  | Forward:	"forward" Expr ";"                                                                             
  | FD:			"fd" Expr ";"                                                                                  
  | Back:		"back" Expr ";"                                                                                
  | BK:			"bk" Expr ";"                                                                                  
  | Right: 		"right" Expr ";"                                                                               
  | RT:			"rt" Expr ";"                                                                                  
  | Home:		"home;"                                                                                        
  | Left:		"left" Expr ";"                                                                                
  | LT:      	"lt" Expr ";"                                                                                  
  | PenDown: 	"pendown" ";"                                                                                  
  | PD:			"pd" ";"                                                                                       
  | PenUp:		"penup" ";"                                                                                    
  | PU:			"pu" ";"                                                                                       
  | SetColor:   "setcolor" Expr ";"                                                                            
  | Call: 		FunId Expr* ";"                                                                                
  ;                                                                                                            
                                                                                                               
syntax Block
  = "[" Command* commands "]";                                                                                          
                                                                                                               
syntax Expr                                                                                                    
  = VarId                                                                                                      
  | Number                                                                                                     
  | Double                                                                                                     
  | Boolean                                                                                                    
  | bracket "(" Expr ")"
  > left   div: Expr l "/" Expr r                                                                              
  > left   mul: Expr l "*" Expr r                                                                              
  > left ( add: Expr l "+" Expr r                                                                              
         | sub: Expr l "-" Expr r                                                                              
         )                                                                                                                                                                                            
  > left (                                                                                                 
  		  largerorequal: Expr l "\>=" Expr r                                                                   
  		|    largerthan: Expr l "\>"  Expr r                                                                   
  		|   smallerthan: Expr l "\<"  Expr r                                                                   
  		| largerorequal: Expr l "\>=" Expr r                                                                   
  		|smallerorequal: Expr l "\<=" Expr r                                                                   
  		|         equal: Expr l "="   Expr r                                                                   
  		|      notequal: Expr l "!="  Expr r                                                                   
  	)                                                                                                          
  | left(                                                                                                      
      Expr l "&&" Expr r                                                                                       
  	| Expr l "||" Expr r                                                                                       
  )                                                                                                            
  | Color                                                                                                      
  ;                                                                                                            
                                                                                                               
lexical VarId                                                                                                  
  = ":" ([a-zA-Z][a-zA-Z0-9]*) \ Keyword !>> [a-zA-Z0-9];                                                      
                                                                                                               
lexical FunId                                                                                                  
  = ([a-zA-Z][a-zA-Z0-9]*) \ Keyword !>> [a-zA-Z0-9];                                                          
                                                                                                               
lexical Number                                                                                                 
  = [0-9]+ !>> [0-9]                                                                                           
  | "-" [0-9]+ !>> [0-9]                                                                                       
  ;                                                                                                            
                                                                                                               
lexical Double                                                                                                 
  = [0-9]* "." [0-9]+ !>> [0-9]                                                                                
  | "-" + [0-9]* "." [0-9]+ !>> [0-9]                                                                          
  ;                                                                                                            
                                                                                                               
lexical Boolean                                                                                                
  = "true" | "false";                                                                                          
                                                                                                               
lexical Color                                                                                                  
 = "#" [0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F];                                                       
                                                                                                               
layout Standard                                                                                                
  = WhitespaceOrComment* !>> [\ \t\n\r] !>> "--";                                                              
                                                                                                               
lexical WhitespaceOrComment                                                                                    
  = whitespace: Whitespace                                                                                     
  | comment: Comment                                                                                           
  ;                                                                                                            
                                                                                                               
lexical Whitespace                                                                                             
  = [\ \t\n\r]                                                                                                 
  ;                                                                                                            
                                                                                                               
lexical Comment                                                                                                
  = @category="Comment" "--" ![\n\r]* $;                                                                       
                                                                                                               
keyword Keyword 
  = "if"                                                                                         
  | "ifelse"                                                                                                   
  | "while"                                                                                                    
  | "repeat"                                                                                                   
  | "forward"                                                                                                  
  | "fd"                                                                                                       
  | "back"                                                                                                     
  | "bk"                                                                                                       
  | "right"                                                                                                    
  | "rt"                                                                                                       
  | "left"                                                                                                     
  | "lt"                                                                                                       
  | "pendown"                                                                                                  
  | "pd"                                                                                                       
  | "penup"                                                                                                    
  | "pu"                                                                                                       
  | "to"                                                                                                       
  | "true"                                                                                                     
  | "false"                                                                                                    
  | "end"                                                                                                      
  | "setcolor"
  | "home"                                                                                                 
  ;                                                                                                            