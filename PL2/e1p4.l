%{
  #include <ctype.h> // For tolower()
  #include <string.h> // For strcpy()

  #define MAX_AUTHORS 10000 // Update this if you need to allow more authors in total
  #define MAX_FIELD_LENGTH 2048 // Update this if bibtex fields can be bigger (We could use a better strcpy)

  // Globals
  char* authorIN; //string to save the input (desired author)
  char* allAuthors[MAX_AUTHORS]; // Data structure for the main author's correlated authors
  char* currentAuthors[MAX_AUTHORS];
  //int startedWritingCurrentAuthor = 0;
  int currentAuthorsLength = 0;
  int allAuthorsLength = 0;



  void appendCharToString(char* string, char c) {
    string[strlen(string) + 1] = '\0';
    string[strlen(string)] = c;
  }

  void oneCharOfAuthor(char* str) {
    char* author = malloc(MAX_FIELD_LENGTH * sizeof(*author));
    currentAuthors[currentAuthorsLength] = author;
    appendCharToString(currentAuthors[currentAuthorsLength], str[0]);
  }

  void anotherAuthor() {
    currentAuthorsLength++;
  }

  /*
    NOTE: if we do not have removed the duplicates in this funtion it was ok
          because, in dot language, in a graph, a node is connected only to another
          node, and if there is a lot of occurences of one of the nodes, it draws 
          lots of arrows -> usefull to check who is the author that correlates more
          with the input author -> write this on work report
  */
  void checkAuthors(){
      int found = 0;
      int foundFinal = 0;
      int authorIndex = -1;
      int i;
      
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
      if(found){
        for(i = 0; i < currentAuthorsLength; i++){

          //do not add himself
          if(i != authorIndex){
            int j;
            
            for(j = 0; j < allAuthorsLength; j++){

              if (strcmp(currentAuthors[i], allAuthors[j]) == 0) {
                foundFinal = 1;
                break;
              } 
            }

            //if correlated author is not in allAuthors array, add to it
            if(!foundFinal){
              strcat(allAuthors[currentAuthorsLength], currentAuthors[i]);
              allAuthorsLength++;
            }
          
          }
        
        }
      
      }

  // Reset needed variables
  currentAuthorsLength = 0;
  }
%}

%x AUTHOR 

%%
^[ ]*(author|AUTHOR)[ ]*=[ ]*[{"]*       BEGIN AUTHOR;
<AUTHOR>{
  [^{\n\r]                                { oneCharOfAuthor(yytext); }
  [ \n\r]+and[ \n\r]+                     { anotherAuthor(); }
  [}"],                                   { checkAuthors(); BEGIN INITIAL; }
  \n                                      { /* Ignore newlines in the middle of author names */ }
} 
.|\n                                    { /* Ignore all other characters. */ }                                   
%%                                    


int main() {
  yylex();

  // allAuthorsLength is actually allAuthorsMaxIndex.
  // We should fix that in the future!
  allAuthorsLength--;


  printf("Diagraph G {\n");

  //to print the quotation marks, it is necessary to escape them!
  int i;
  for(i = 0; i <= allAuthorsLength; i++){
    printf("  \"%s\"", authorIN);
    printf(" -> ");
    printf("\"%s\"\n", allAuthors[i]);
  }

  printf("}");
}
