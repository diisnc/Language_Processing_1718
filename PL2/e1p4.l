%{
  #include <ctype.h> // For tolower()
  #include <string.h> // For strcpy()
  #include <stdio.h>

  #define MAX_AUTHORS 10000 // Update this if you need to allow more authors in total
  #define MAX_FIELD_LENGTH 2048 // Update this if bibtex fields can be bigger (We could use a better strcpy)

  // Globals
  char authorIN[50]; //string to save the input (desired author)
  char* allAuthors[MAX_AUTHORS]; // Data structure for the main author's correlated authors
  char* currentAuthors[MAX_AUTHORS];
  int startedWritingCurrentAuthor = 0;
  int currentAuthorsLength = 0;
  int allAuthorsLength = 0;





  void appendCharToString(char* string, char c) {
    string[strlen(string) + 1] = '\0';
    string[strlen(string)] = c;
  }

  void oneCharOfAuthor(char* str) {
    
    if (!startedWritingCurrentAuthor) {
      char* author = malloc(MAX_FIELD_LENGTH * sizeof(*author));
      currentAuthors[currentAuthorsLength] = author;
      startedWritingCurrentAuthor = 1;
    }
    appendCharToString(currentAuthors[currentAuthorsLength], str[0]);
  }



  void anotherAuthor() {
    startedWritingCurrentAuthor = 0;
    currentAuthorsLength++;
  }

  /*
    NOTE: if we do not have removed the duplicates in this funtion it was ok
          because, in dot language, in a graph, a node is connected only to another
          node, and if there is a lot of occurences of one of the nodes, it draws 
          lots of arrows -> usefull to check who is the author that correlates more
          with the input author -> write this on work report
  */
  void checkAuthors() {
      int found = 0;
      int foundFinal = 0;
      int authorIndex = -1;
      int i;

      // Stopped writing authors, increment
      currentAuthorsLength++;

      // Find authorIN in currentAuthors array
      for (i = 0; i < currentAuthorsLength; i++) {
        
        // If found, get the index
        if (strcmp(currentAuthors[i], authorIN) == 0) {
          authorIndex = i;
          found = 1;
          break;
        }
      }

      //if found, add to allAuthors array all the correlated authors (except himself)
      //it is also necessary to check if the correlated author is not already in the
      //allAuthors array (avoiding repeated correlated authors)
      if(found) {

        for(i = 0; i < currentAuthorsLength; i++) {
          
          //do not add himself
          if(i != authorIndex) {
            int j;
            
            for(j = 0; j < allAuthorsLength; j++) {
              if (strcmp(currentAuthors[i], allAuthors[j]) == 0) {
                foundFinal = 1;
                break;
              } 
            }
            
            //if correlated author is not in allAuthors array, add to it
            if(!foundFinal) {
              char *s = malloc(MAX_FIELD_LENGTH * sizeof(*s));
              strcpy(s, currentAuthors[i]);
              allAuthors[allAuthorsLength] = s;
              allAuthorsLength++;
            }
          
          }
        
        }
      
      }

  // Reset needed variables
  currentAuthorsLength = 0;
  startedWritingCurrentAuthor = 0;
  }
%}

%x AUTHOR AUTHOR_BRACKET

%%
^[ ]*(author|AUTHOR)[ ]*=[ ]*[{"]*        BEGIN AUTHOR;
<AUTHOR>{
  \{                                      { oneCharOfAuthor("{"); BEGIN AUTHOR_BRACKET; }
  [^{\n\r]                                { oneCharOfAuthor(yytext); } 
  [ \n\r]+and[ \n\r]+                     { anotherAuthor(); }
  [}"],                                   { checkAuthors(); BEGIN INITIAL; }
  .|\n                                    { /* Ignore newlines in the middle of author names */ }
}                                      
<AUTHOR_BRACKET>{
  [^}]                                    { oneCharOfAuthor(yytext); }
  \}                                      { oneCharOfAuthor("}"); BEGIN AUTHOR; }
} 
.|\n                                      { /* Ignore all other characters. */ }                                   
%%                                    


/*

Example: ./e1p4 < exemplo-utf8.bib > results.txt -author "J.J. Almeida"

argv[0] = ./exec
argv[1] = -autor
argv[2] = "<authorIn>"

*/
int main(int argc, char** argv) {
  
  if(argc >= 3) {
    strcpy(authorIN, argv[2]);
    
    yylex();

    allAuthorsLength--;

    printf("digraph G {\n");
    printf("  ratio = fill;\n");
    printf("  node [style=filled];\n");

    //to print the quotation marks, it is necessary to escape them!
    int i;
    for(i = 0; i <= allAuthorsLength; i++) {
      printf("  \"%s\"", authorIN);
      printf(" -> ");
      printf("\"%s\"", allAuthors[i]);
      printf(" [color=\"0.650 0.700 0.700\"];\n");
    }

    printf("}");
  } else {
    fprintf(stderr, "Argumentos insuficientes!\n");
  }
}
