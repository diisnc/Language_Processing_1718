%{
  #include <ctype.h> // For tolower()
  #include <string.h> // For strcpy()

  #define MAX_ENTRIES 10000 // Update this if you need more bibtex entries (We could use a dynamic array)
  #define MAX_AUTHORS 10000 // Update this if you need to allow more authors in total
  #define MAX_FIELD_LENGTH 2048 // Update this if bibtex fields can be bigger (We could use a better strcpy)

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
  }

  void storeID(char* line) {
    // Unlike title, ID doesn't have to be trimmed
    char *id = malloc(MAX_FIELD_LENGTH * sizeof(*id));
    strcpy(id, line);
    currentID = id;
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

  void storeData() {

    // Check if there is data to store
    // (This could be called at the start of the file)
    if (currentAuthorsLength == 0) {
      return;
    }

    // Stopped writing an author, increment
    currentAuthorsLength++;

    // For each current author
    int i;
    for (i = 0; i < currentAuthorsLength; i++) {

      // Find author in all authors array
      int found = 0;
      int authorIndex = -1;
      int j;
      for (j = 0; j < allAuthorsLength; j++) {

        // If found, get the index
        if (strcmp(currentAuthors[i], allAuthors[j]) == 0) {
          authorIndex = j;
          found = 1;
          break;
        }
      }
      // If not found, append and index = allAuthorsLength
      if (found == 0) {
        char *s = malloc(MAX_FIELD_LENGTH * sizeof(*s));
        strcpy(s, currentAuthors[i]);
        allAuthors[allAuthorsLength] = s;
        authorIndex = allAuthorsLength;
        allAuthorsLength++;
      }

      // Add ID and Title string to the string in allWorks
      // in the index of that author
      if (found == 0) {
        char* n = malloc(MAX_FIELD_LENGTH * sizeof(*n));
        allWorks[authorIndex] = n;
      }

      strcat(allWorks[authorIndex], currentTitle);
      strcat(allWorks[authorIndex], " (");
      strcat(allWorks[authorIndex], currentID);
      strcat(allWorks[authorIndex], "), ");
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
^[ ]*(author|AUTHOR)[ ]*=[ ]*[{"]*       BEGIN AUTHOR;
^[ ]*(title|TITLE)[ ]*=[ ]*              BEGIN TITLE;
<AUTHOR>\{                               { oneCharOfAuthor("{"); BEGIN AUTHOR_BRACKET; }
<AUTHOR>[^{\n\r]                           { oneCharOfAuthor(yytext); }
<AUTHOR>[}"],                            BEGIN INITIAL;
<AUTHOR>[ \n\r]+and[ \n\r]+                  { anotherAuthor(); }
<AUTHOR>\n                               { /* Ignore newlines in the middle of author names */ }
<AUTHOR_BRACKET>[^}]                     { oneCharOfAuthor(yytext); }
<AUTHOR_BRACKET>\}                       { oneCharOfAuthor("}"); BEGIN AUTHOR; }
<TITLE>[{"](\{[^{}"]*\}|[^{}"])*[}"]     { storeTitle(yytext); BEGIN INITIAL; }
.|\n                                     { /* Ignore all other characters. */ }
%%

int main() {
  yylex();

  // One last storeData();
  // (Needed because storeData is called at the start of a new entry,
  // because we can't rely on a specific field to be the last of an entry)
  storeData();

  // allAuthorsLength is actually allAuthorsMaxIndex.
  // We should fix that in the future!
  allAuthorsLength--;

  printf("Authors and Works\n");

  int j;
  for(j = 0; j <= allAuthorsLength; j++) {
    printf("\n%s: ", allAuthors[j]);
    printf("%s\n", allWorks[j]);
  }
}
