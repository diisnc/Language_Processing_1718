%{
  #include <ctype.h> // For tolower()
  #include <string.h> // For strcpy()

  #define MAX_ENTRIES 1024 // Update this if you need more bibtex entries (We could use a dynamic array)
  #define MAX_AUTHORS 64 // Update this if you need to allow more authors per entry
  #define MAX_FIELD_LENGTH 5000 // Update this if bibtex fields can be bigger (We could use a better strcpy)

  // Globals
  char* currentTitle;
  char* currentID;
  char* currentAuthors[MAX_AUTHORS];
  int currentAuthorsLength = 0;
  int startedWritingCurrentAuthor = 0;
  char* allAuthors[MAX_AUTHORS];
  int allAuthorsLength = 0;
  char* allWorks[MAX_AUTHORS];


  void trimStringEnds(char* string, char* empty) {
    char* copy = string;
    copy++; // Trim first character
    strcpy(empty, copy);
    empty[strlen(empty) - 1] = '\0'; // Last string character becomes \0
  }

  void appendCharToString(char* string, char c) {
    string[strlen(string) + 1] = '\0';
    string[strlen(string)] = c;
  }

  void storeTitle(char* line) {
    char *title = malloc(MAX_FIELD_LENGTH * sizeof(*title));
    trimStringEnds(line, title);
    currentTitle = title;

    printf("Stored title\n");
  }

  void storeID(char* line) {
    char *id = malloc(MAX_FIELD_LENGTH * sizeof(*id));
    trimStringEnds(line, id);
    currentID = id;
  }

  void oneCharOfAuthor(char* str) {

    if (!startedWritingCurrentAuthor) {
      char* author = malloc(MAX_FIELD_LENGTH * sizeof(*author));
      author[0] = 'T';
      currentAuthors[currentAuthorsLength] = author;
      startedWritingCurrentAuthor = 1;
    }
    appendCharToString(currentAuthors[currentAuthorsLength], str[0]);
  }

  void anotherAuthor() {
    startedWritingCurrentAuthor = 0;
    currentAuthorsLength++;
  }

  void storeData() {

    // Check if there is data to store
    // (This could be called at the start of the file)
    if (currentAuthorsLength == 0) {
      return;
    }

    printf("storeData\n");

    // Stopped writing an author, increment
    currentAuthorsLength++;

    // For each current author
    int i;
    for (i = 0; i < currentAuthorsLength; i++) {

      printf("author: %s\n", currentAuthors[i]);

      // Find author in all authors array
      int found = 0;
      int authorIndex = -1;
      int j;
      for (j = 0; j < allAuthorsLength; j++) {

        // If found, get the index
        if (strcmp(currentAuthors[i], allAuthors[j]) == 0) {
          printf("Author found: currentAuthors %d:\"%s\" and allAuthors %d:\"%s\"\n", i, currentAuthors[i], j, allAuthors[j]);
          authorIndex = j;
          found = 1;
          break;
        }
      }
      // If not found, append and index = allAuthorsLength
      if (found == 0) {
        printf("Author not found\n");
        char *s = malloc(MAX_FIELD_LENGTH * sizeof(*s));
        strcpy(s, currentAuthors[i]);
        allAuthors[allAuthorsLength] = s;
        authorIndex = allAuthorsLength;
        allAuthorsLength++;
      }

      printf("author index: %d\n", authorIndex);
      printf("author name: %s\n", allAuthors[authorIndex]);

      // Add ID and Title string to the string in allWorks
      // in the index of that author
      if (found == 0) {
        printf("Initializing allWorks[%d]\n", authorIndex);
        char* n = malloc(MAX_FIELD_LENGTH * sizeof(*n));
        allWorks[authorIndex] = n;
      }

      strcat(allWorks[authorIndex], currentTitle);
      strcat(allWorks[authorIndex], " (");
      strcat(allWorks[authorIndex], currentID);
      strcat(allWorks[authorIndex], "), ");

      printf("works now is: %s\n", allWorks[authorIndex]);
    }

    // Reset needed variables
    currentAuthorsLength = 0;
    startedWritingCurrentAuthor = 0;
  }
%}

%x ID AUTHOR AUTHOR_BRACKET TITLE

%%
^@string\{                               { /* Ignore @string */ }
^@.+\{                                   { storeData(); BEGIN ID; }
<ID>[^,]+                                { storeID(yytext); BEGIN INITIAL; }
^[ ]*author[ ]*=[ ]*[{"]*                BEGIN AUTHOR;
^[ ]*title[ ]*=[ ]*                      BEGIN TITLE;
<AUTHOR>\{                               { oneCharOfAuthor("{"); BEGIN AUTHOR_BRACKET; }
<AUTHOR>[ ]and[ ]                        { anotherAuthor(); }
<AUTHOR>[^{]                             { oneCharOfAuthor(yytext); }
<AUTHOR_BRACKET>[^}]                     { oneCharOfAuthor(yytext); }
<AUTHOR_BRACKET>\}                       { oneCharOfAuthor("}"); BEGIN AUTHOR; }
<AUTHOR>[}"],                            BEGIN INITIAL;
<TITLE>[{"](\{[^{}"]*\}|[^{}"])*[}"]     { storeTitle(yytext); BEGIN INITIAL; }
.|\n                                     { /* Ignore all other characters. */ }
%%

int main() {
  yylex();

  int j;
  for(j = 0; j <= allAuthorsLength; j++) {
    printf("%s: ", allAuthors[j]);
    printf("%s\n", allWorks[j]);
  }
}
