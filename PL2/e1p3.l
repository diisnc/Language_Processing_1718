%{
  #include <ctype.h> // For tolower()
  #include <string.h> // For strcpy()

  #define NUM_OF_CATEGORIES 13 // Update this if you change categories[]
  #define MAX_ENTRIES 1024 // Update this if you need more bibtex entries (We could use a dynamic array)
  #define MAX_FIELD_LENGTH 1024 // Update this if bibtex fields can be bigger (We could use a better strcpy)
  #define MAX_SUBSTRINGS 64 // Number of substrings to support on splitStringOnString

  // Data structures for counting category occurences
  const char* categories[] = {"article", "book", "booklet", "inbook", "incollection", "inproceedings", "manual", "mastersthesis", "misc", "phdthesis", "proceedings", "techreport", "unpublished"};
  int counters[NUM_OF_CATEGORIES];

  // Data structures for filtering IDs, authors, and titles
  char* ids[MAX_ENTRIES];
  char* authors[MAX_ENTRIES];
  char* titles[MAX_ENTRIES];

  // State variable - what entry index are we currently on?
  // Starts at -1 because we increment right away,
  // we can't increment at the end of onCategoryDetection
  // because other functions run after it that depend on the counter
  int entryCounter = -1;

  void trimStringEnds(char* string, char* empty) {
    char* copy = string;
    copy++; // Trim first character
    strcpy(empty, copy);
    empty[strlen(empty) - 1] = '\0'; // Last string character becomes \0
  }

  void splitStringOnString(char* str, char* delimiterStr) {

    int numOfSubstrings = 0;
    char* substrings[MAX_SUBSTRINGS];

    // Loop over the string
    int lastSaveIndex = 0;
    char* a = str;
    for ( ; *a; ++a) {

      // Check if next characters are equal to delimiterStr
      char* b = malloc(MAX_FIELD_LENGTH * sizeof(*b));
      b = strcpy(b, a);
      b[strlen(delimiterStr)] = '\0'; // Terminate string for comparison on length of characteres of delimiter
      if (strcmp(a, delimiterStr) == 0) {

        // Add previous string to array
        char* c = malloc(MAX_FIELD_LENGTH * sizeof(*c));
        strcpy(c, a[lastSaveIndex]);
        substrings[numOfSubstrings] = c;

        // Update lastSaveIndex
        lastSaveIndex =

        // Skip to end of delimiter
        // Increment numOfSubstrings
      }
    };

    // Add previous string to array
  }

  void onCategoryDetection(char* line) {

    char* category = malloc(MAX_FIELD_LENGTH * sizeof(*category));
    trimStringEnds(line, category);

    // Category to lowercase
    char* c2 = category;
    for ( ; *c2; ++c2) *c2 = tolower(*c2);

    // Loop over categories, and if there is a match,
    // increase the respective counter
    int matched = 0;
    int i;
    for (i = 0; i < NUM_OF_CATEGORIES; i++) {
      if (strcmp(category, categories[i]) == 0) {
        counters[i]++;
        matched = 1;
        break;
      }
    }
    if (matched == 1) {
      // Increment counter, because there was a match!
      // We'll be storing an entry.
      entryCounter++;
    }
  }

  void onIDDetection(char* line) {
    char *id = malloc(MAX_FIELD_LENGTH * sizeof(*id));
    strcpy(id, line);
    ids[entryCounter] = id;
  }

  void onTitleDetection(char* line) {
    char *title = malloc(MAX_FIELD_LENGTH * sizeof(*title));
    trimStringEnds(line, title);
    titles[entryCounter] = title;
  }

  void onAuthorDetection(char* line) {
    char *author = malloc(MAX_FIELD_LENGTH * sizeof(*author));
    trimStringEnds(line, author);
    authors[entryCounter] = author;
  }
%}

%x ID AUTHOR AUTHOR_BRACKET TITLE

%%
^@string\{                               { /* Ignore @string */ }
^@.+\{                                   { printf("Found category: %s\n", yytext); BEGIN ID; }
<ID>[^,]+                                { printf("Found ID: %s\n", yytext); BEGIN INITIAL; }
^[ ]*author[ ]*=[ ][{"]*                 { printf("Found author: "); BEGIN AUTHOR; }
^[ ]*title[ ]*=[ ]*                      BEGIN TITLE;
<AUTHOR>[^{]                             { printf("%s", yytext); }
<AUTHOR>\{                               { printf("{"); BEGIN AUTHOR_BRACKET; }
<AUTHOR_BRACKET>[^}]                     { printf("%s", yytext); }
<AUTHOR_BRACKET>\}                       { printf("}"); BEGIN AUTHOR; }
<AUTHOR>[}"],                            { printf("\n"); BEGIN INITIAL; }
<TITLE>[{"](\{[^{}"]*\}|[^{}"])*[}"]     { printf("Found title: %s\n", yytext); BEGIN INITIAL; }
.|\n                                     { /* Ignore all other characters. */ }
%%

int main() {
  yylex();
  /*
  printf("<!DOCTYPE html>\n");
  printf("<html>\n");
  printf("<head>\n");
  printf("<title>The best page in the world</title>\n");
  printf("<meta charset=\"utf-8\"/>\n");
  printf("</head>\n");
  printf("<body style=\"margin: 50px\">\n");
  printf("<h1>Category Counter</h1>\n");
  printf("<table>\n");

  // Print categories and counters
  int i;
  for(i = 0; i < NUM_OF_CATEGORIES; i++) {
    printf("<tr>\n");
    printf("<td>%s</td>\n", categories[i]);
    printf("<td>%d</td>\n", counters[i]);
    printf("</tr>\n");
  }
  printf("</table>");

  // Print IDs, titles, and authors
  printf("<br>\n");
  printf("<br>\n");
  printf("<table>\n");
  printf("<td>ID</td>\n");
  printf("<td>Title</td>\n");
  printf("<td>Author</td>\n");
  int j;
  for(j = 0; j <= entryCounter; j++) {
    printf("<tr>\n");
    printf("<td>%s</td>\n", ids[j]);
    printf("<td>%s</td>\n", titles[j]);
    printf("<td>%s</td>\n", authors[j]);
    printf("</tr>\n");
  }

  printf("</table>");
  printf("</body>\n");
  printf("</html>\n");
  */
}
