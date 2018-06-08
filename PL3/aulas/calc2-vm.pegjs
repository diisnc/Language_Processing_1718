{
  var regs = {}  // registos necessários para a máquina
  var prog = []  // programa da VM gerado
  var contaCiclos = 0; 
  var contaIfs = 0;
  prog.push("\tpushn 26", "\tpushn 10", "start");
}

Prog
  = cl:ComList { return prog.join('\n') + cl + "\nstop";}

ComList
  = c:Command cl:(_ Command)* {
    return cl.reduce( function( result, element) {
      return result + element[1];
      }, c);
    }

Command
  = "print" _ exp:Exp { return exp +"\n\twritei"; }
  / id:Id _ '=' _ exp:Exp { return exp + "\n\tstoreg " + (id.charCodeAt(0)-'a'.charCodeAt(0)).toString();
                          }
  / "read" _ id:Id { return "\n\tread" + "\n\tatoi" + "\n\tstoreg "+(id.charCodeAt(0)-'a'.charCodeAt(0)).toString();}
  / "repeat" _ '(' _ exp:Exp _ ')' _ '{' _ cl:ComList _ '}' {
        contaCiclos++;
        return exp +
               "\n\tstoreg " + String(25+contaCiclos) +
               "\nciclo" + String(contaCiclos) + ":" +
               "\n\tpushg " + String(25+contaCiclos) +
               "\n\tjz fciclo" + contaCiclos +
               cl +
               "\n\tpushg " + String(25+contaCiclos) +
               "\n\tpushi 1" +
               "\n\tsub" +
               "\n\tstoreg " + String(25+contaCiclos) +
               "\n\tjump ciclo" + String(contaCiclos) +
               "\nfciclo" + String(contaCiclos) + ":";
      }      
  / "while" _ '(' _ c:Cond _ ')' _ '{' _ cl:ComList _ '}'
     { contaCiclos++;
       return "\nciclo" + String(contaCiclos) + ":" +
              c + 
              "\n\tjz fciclo" + String(contaCiclos) + 
              cl +
              "\n\tjump ciclo" + String(contaCiclos) +
              "\nfciclo" + String(contaCiclos) + ":"; }
  / "if" _ '(' _ c:Cond _ ')' _ '{' _ cl:ComList _ '}'
    {
      contaIfs ++;
      return c + "\n\tjz fimif" + String(contaIfs) +
             cl +
             "\nfimif" + String(contaIfs) + ":"
    }
  
Cond
  = c:Cond2 cs:(_ "or" _ Cond2)* {
    return cs.reduce((res, element)=>{
      return res + element[3] + "\n\tor";
    }, c);
  }
  
Cond2
  = c:Cond3 cs:(_ "and" _ Cond3)* {
    return cs.reduce((res, element)=>{
      return res + element[3] + "\n\tand";
    }, c);
  }
  
Cond3
  = '!' _ c:Cond  { return c + "\nnot"; }
  / '(' _ c:Cond _ ')' { return c; }
  / c:CondRel  { return c; }
  
CondRel
  = e:Exp r:(_ ("==" / "!=" / ">=" / "<=" / '>' / '<') _ Exp)? {
      var res = ""
      if(r){ 
        res += e
        switch(r[1]) {
          case "<": res += r[3] + "\n\tinf"
                    break
          case ">": res += r[3] + "\n\tsup"
                    break
          case ">=": res += r[3] + "\n\tsupeq"
                    break
          case "<=": res += r[3] + "\n\tinfeq"
                    break
          case "==": res += r[3] + "\n\tequal"
                    break
          case "!=": res += r[3] + "\n\tequal\n\tnot"
                    break
        }
      } else
          res = e
    return res
  }
        
  
Exp
  = t:Termo ts:(_ ('+' / '-') _ Termo)* {
      return ts.reduce(function(result, element) {
        if (element[1] === "+") { return result + element[3] + "\n\tadd"; }
        if (element[1] === "-") { return result + element[3] + "\n\tsub"; }
      }, t);
    }
  
Termo
  = f:Factor fs:(_ ('*' / '/') _ Factor)* {
      return fs.reduce(function(result, element) {
        if (element[1] === "*") { return result + element[3] + "\n\tmul"; }
        if (element[1] === "/") { return result + element[3] + "\n\tdiv"; }
      }, f);
    }
  
Factor
  = v:Num { return("\n\tpushi " + v.toString()); }
  / id:Id { return("\n\tpushg " + (id.charCodeAt(0)-'a'.charCodeAt(0)).toString()); 
          }
  / '(' _ exp:Exp _ ')' { return exp; }
  
Num
  = [0-9]+ { return text(); }

Id
  = [a-z] { return text(); }


_ "whitespace"
  = [ \t\n\r]*