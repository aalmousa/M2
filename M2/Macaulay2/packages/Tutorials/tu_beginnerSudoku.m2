doc ///
Node
  Key
    "Beginner tutorial: Shidoku"
  Headline
    A first Macaulay2 session solving a 4x4 Sudoku
  Description
    Text
      This tutorial is for a new Macaulay2 user who has limited knowledge of
      commutative algebra. The goal is to show how Macaulay2 can turn a system
      of polynomial equations into useful information.

      The mathematical problem is a 4-by-4 Sudoku puzzle, sometimes called
      Shidoku. Instead of solving it by hand, we encode the rules as polynomial
      equations and ask Macaulay2 to solve the resulting system.

    Text
      @BOLD "Starting Macaulay2"@

    Text
      After starting Macaulay2, you should see a prompt like this:

    Pre
      i1 :

    Text
      Macaulay2 labels each input line with @TT "i1, i2"@ and so on.
      It labels each output line with @TT "o1, o2"@ and so on.

      If you are continuing from an older session and want a fresh start, you
      can type:

    Pre
      i1 : restart

    Text
      Try a few basic commands.

    Example
      2+3
      2^10
      factor 360

    Text
      Macaulay2 can be used as a calculator, but its main strength is
      computation with algebraic objects such as polynomial rings, ideals,
      modules, maps, complexes, and related structures.

    Text
      @BOLD "Finding help"@

    Text
      A good first habit is to ask Macaulay2 what it knows.

    Example
      help ideal

    Text
      If you do not know the exact name of a command, try @TT "apropos"@ or
      @TT "about"@.

    Example
      apropos "Groebner"

    Text
      In an interactive session, @TT "viewHelp ideal"@ opens the documentation
      page in a browser, and @TT "examples ideal"@ shows examples attached to
      that documentation entry.

    Text
      @BOLD "The puzzle"@

    Text
      Here is a 4-by-4 Sudoku puzzle we will solve. The entries are the
      numbers 1, 2, 3, and 4. The boxes are 2 rows by 2 columns.

    Pre
      +-----+-----+
      | 1 . | . 4 |
      | . 4 | 1 . |
      +-----+-----+
      | . 1 | 4 . |
      | 4 3 | . 1 |
      +-----+-----+

    Text
      Here a dot @TT "."@ means that the entry is not yet known.

    Text
      @BOLD "The rules"@

    Text
      A completed Shidoku board must satisfy the following conditions:

      @UL {
        LI "Each cell contains one of 1, 2, 3, 4.",
        LI "Each row contains each number exactly once.",
        LI "Each column contains each number exactly once.",
        LI "Each 2-by-2 box contains each number exactly once.",
        LI "The given clues must be preserved."
      }@

    Text
      We will translate these rules into polynomial equations.

    Text
      @BOLD "The algebraic idea"@

    Text
      We work over the finite field @TT "ZZ/5"@. Its nonzero elements are
      1, 2, 3, and 4, which are exactly the four symbols allowed in a Shidoku
      puzzle.

      If @TT "x"@ is a variable representing one cell, then the equation

    Pre
      x^4 - 1 = 0

    Text
      forces @TT "x"@ to be one of the nonzero elements of @TT "ZZ/5"@.

      To say that two cells @TT "x"@ and @TT "y"@ contain different symbols,
      we use the equation

    Pre
      (x - y)^4 - 1 = 0

    Text
      This works because every nonzero element @TT "a"@ of @TT "ZZ/5"@
      satisfies @TT "a^4 = 1"@. Thus the equation above says that
      @TT "x-y"@ is nonzero, so @TT "x"@ and @TT "y"@ must be different.

      In this way, a Shidoku puzzle becomes a system of polynomial equations
      whose solutions are exactly the completed boards satisfying all the rules.

    Text
      @BOLD "A polynomial ring for the board"@

    Text
      We represent the unknown board by a 4-by-4 array of variables
      @TT "x_(i,j)"@, where @TT "x_(i,j)"@ is the entry in row @TT "i"@
      and column @TT "j"@.

      We begin by creating a polynomial ring over @TT "ZZ/5"@ with one variable
      for each cell. The shorthand @TT "x_(1,1)..x_(4,4)"@ creates all 16
      variables.

    Example
      R = ZZ/5[x_(1,1)..x_(4,4), MonomialOrder => Lex]
      R_*

    Text
      The list @TT "R_*"@ contains the 16 variables of the ring. For this
      puzzle, however, it is more convenient to organize the variables as a
      4-by-4 table.

    Example
      board = table(toList(1..4), toList(1..4), (i,j) -> x_(i,j));
      matrix board

    Text
      The object @TT "board"@ is a nested list: it is a list whose entries are
      themselves lists. The inner lists are the rows of the board. We can use
      indexing to extract entries. Macaulay2 list indices start at 0, so
      @TT "board#0#0"@ is the upper-left entry.

    Example
      board#0
      board#0#0
      board#3#2

    Text
      This indexing convention is common in programming languages. The puzzle
      itself is written with rows and columns numbered 1 through 4, but
      Macaulay2 lists are indexed from 0 through 3.

    Text
      @BOLD "Rows, columns, and boxes"@

    Text
      The rows of the puzzle are already the rows of @TT "board"@.

    Example
      rows = board;

    Text
      We can build the columns by fixing a column index @TT "j"@ and collecting
      the @TT "j"@th entry from each row.

    Example
      cols = toList apply(0..3, j -> apply(rows, row -> row#j));
      matrix cols

    Text
      The 2-by-2 boxes start in positions @TT "(0,0)"@, @TT "(0,2)"@,
      @TT "(2,0)"@, and @TT "(2,2)"@. The following command builds the four
      boxes. Each box is stored as a list of four variables.

    Example
      boxes = {{board#0#0, board#0#1, board#1#0, board#1#1},
               {board#0#2, board#0#3, board#1#2, board#1#3},
               {board#2#0, board#2#1, board#3#0, board#3#1},
               {board#2#2, board#2#3, board#3#2, board#3#3}};
      boxes

    Text
      We combine the rows, columns, and boxes into one list of regions.

    Example
      regions = flatten {rows, cols, boxes};
      #regions

    Text
      The list @TT "regions"@ has 12 entries: 4 rows, 4 columns, and 4 boxes.

    Text
      @BOLD "Turning the rules into equations"@

    Text
      First, we create the equations saying that every cell contains one of
      @TT "1,2,3,4"@.

    Example
      cellRules = apply(flatten board, x -> x^4 - 1);
      #cellRules

    Text
      Next, we create the equations saying that entries in the same row,
      column, or box are pairwise different.

      The function @TT "subsets(L,2)"@ gives all 2-element subsets of a list
      @TT "L"@. Therefore the following function takes a list of cells and
      returns the equations forcing all pairs of cells in that list to be
      different.

    Example
      pairwiseDifferent = L -> apply(subsets(L, 2), p -> (p#0 - p#1)^4 - 1);

    Text
      We apply this function to each region and then flatten the resulting
      nested list of equations.

    Example
      regionRules = flatten apply(regions, pairwiseDifferent);
      #regionRules

    Text
      Finally, we encode the given clues.

    Example
      clues = {(1,1,1), (1,4,4),
               (2,2,4), (2,3,1),
               (3,2,1), (3,3,4),
               (4,1,4), (4,2,3), (4,4,1)};

    Text
      A clue @TT "(i,j,n)"@ means that the entry in row @TT "i"@ and column
      @TT "j"@ is @TT "n"@. Since the clue uses 1-based row and column numbers
      but Macaulay2 uses 0-based list indices, we subtract 1 from the row and
      column numbers.

    Example
      entry = clue -> (board#(clue#0-1))#(clue#1-1);
      clueRules = apply(clues, clue -> entry clue - clue#2);
      clueRules

    Text
      We now collect all the equations into one ideal.

    Example
      I = ideal flatten {cellRules, regionRules, clueRules};

    Text
      The ideal @TT "I"@ contains all the equations describing the puzzle.

    Text
      @BOLD "Solving with a Groebner basis"@

    Text
      To solve the puzzle, we compute a Groebner basis for @TT "I"@.

    Example
      G = gb I;
      transpose gens G

    Text
      With the lexicographic monomial order, the Groebner basis is easy to read.
      It consists of linear equations determining the 16 cells.

      For example, an equation like @TT "x_(1,2)-2"@ says that the entry in
      row 1, column 2 is 2. An equation like @TT "x_(1,3)+2"@ says that
      @TT "x_(1,3)=-2"@, which means @TT "x_(1,3)=3"@ in @TT "ZZ/5"@.

    Example
      dim I
      degree I

    Text
      The output @TT "dim I = 0"@ tells us that the ideal defines a
      zero-dimensional solution set, so there are only finitely many solutions.

      In this example, the Groebner basis directly gives one value for each
      variable. The output @TT "degree I = 1"@ records that the quotient has
      degree 1, which is the algebraic shadow of the uniqueness of the solution
      in this case.

    Text
      @BOLD "Reading the completed board automatically"@

    Text
      We could read the solution by hand from the Groebner basis, but it is more
      convenient to let Macaulay2 build the completed board.

      Reducing a variable by the Groebner basis gives its value. For example:

    Example
      x_(1,2) % G
      x_(1,3) % G

    Text
      The value of a cell may be printed as @TT "-2"@ instead of @TT "3"@,
      because @TT "-2 = 3"@ in @TT "ZZ/5"@. The following helper function
      converts a field element to one of the symbols @TT "1,2,3,4"@.

    Example
      toSymbol = a -> (
          matches := select({1,2,3,4}, n -> a == n);
          if #matches == 1 then first matches else error "entry is not determined"
          );

    Text
      Now we write a function that takes a board and a Groebner basis and
      returns the completed board.

    Example
      boardFromIdeal = (B,G) -> matrix pack(4,
          apply(flatten B, x -> toSymbol(x % G))
          );

      boardFromIdeal(board, G)

    Text
      The completed Shidoku board is:

    Pre
      +-----+-----+
      | 1 2 | 3 4 |
      | 3 4 | 1 2 |
      +-----+-----+
      | 2 1 | 4 3 |
      | 4 3 | 2 1 |
      +-----+-----+

    Text
      The main pattern in this tutorial is common in Macaulay2:

      @UL {
        LI "create a polynomial ring,",
        LI "build algebraic objects such as ideals from lists of equations,",
        LI "compute a Groebner basis or another invariant,",
        LI "interpret the output in terms of the original problem."
      }@

    Text
      @BOLD "Exercises to try"@

    Text
      Here are some ways to experiment with the tutorial.

    Text
      1. Remove one clue from the list @TT "clues"@ and recompute the ideal.
      What happens to @TT "degree I"@? Does the puzzle still have a unique
      solution?

    Text
      2. Change one clue to an incorrect value. For example, replace
      @TT "(4,2,3)"@ by @TT "(4,2,4)"@. What do @TT "gb I"@,
      @TT "dim I"@, and @TT "degree I"@ tell you?

    Text
      3. Try a different monomial order, such as @TT "MonomialOrder => GRevLex"@.
      Is the Groebner basis still as easy to read? Does
      @TT "boardFromIdeal(board,G)"@ still find the solution?

    Text
      4. Use @TT "subsets({a,b,c,d},2)"@ directly on a small list.
      How does this explain the definition of @TT "pairwiseDifferent"@?

    Text
      5. Write a function @TT "shidokuIdeal"@ whose input is a list of clues
      and whose output is the corresponding ideal.

    Text
      6. Write a function that prints the list of rows, columns, and boxes for
      the board. Use it to check that the four boxes were constructed in the
      order you expected.

    Text
      7. Try a 6-by-6 Sudoku puzzle with 2-by-3 boxes. Hint: work over
      @TT "ZZ/7"@ and replace the equations @TT "x^4-1"@ and
      @TT "(x-y)^4-1"@ by equations using the exponent 6.

    Text
      8. Try encoding a full 9-by-9 Sudoku puzzle. What field should you use?
      What exponent should appear in the equations?
///
