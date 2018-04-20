%{
  #include <ctype.h> // For tolower()
  #define NUM_OF_CATEGORIES 13 // Update this if you change categories[]
  const char* categories[] = {"article", "book", "booklet", "inbook", "incollection", "inproceedings", "manual", "mastersthesis", "misc", "phdthesis", "proceedings", "techreport", "unpublished"};
  int counters[NUM_OF_CATEGORIES];

  void onCategoryDetection(char* category) {

    // Ignore "@" at start of category
    char* c = &category[1];

    // Copy string address for looping
    char* c1 = c;
    char* c2 = c;

    // Trim string on "{"
    for ( ; *c1; ++c1) {
      if (*c1 == '{') {
        *c1 = '\0';
      }
    }

    // Category to lowercase one-liner
    for ( ; *c2; ++c2) *c2 = tolower(*c2);

    // Loop over categories, and if there is a match,
    // increase the respective counter
    int i;
    for (i = 0; i < NUM_OF_CATEGORIES; i++) {
      if (strcmp(c, categories[i]) == 0) {
        counters[i]++;
        break;
      }
    }
  }
%}

%%
^@(.*)\{   {onCategoryDetection(yytext);}
.|\n       { /* Ignore all other characters. */ }
%%

int main() {
  yylex();

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
  printf("</body>\n");
  printf("</html>\n");
}
