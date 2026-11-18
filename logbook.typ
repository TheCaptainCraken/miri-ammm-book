// Your AMMM logbook. Write below, rebuild, keep going.
//
// THREE FUNCTIONS, that's all:
//
//   #session("12 Nov")
//       Starts a study session. Everything below it belongs to that date.
//
//   #exercise("ch4-p3")[ your answer ]
//       One answered item (exercise, Your turn, Stop box, pretest),
//       with the id printed in the book: ch4-p3, ch6-w2, ...
//
//   #mistake[what I did][what I should have done]
//       Put it INSIDE an exercise. It shows up in red there, and it is
//       listed automatically on the first page with its id and date.
//
// Example:
//
//   #session("12 Nov")
//   #exercise("ch4-p3")[
//     Entering $x_2$, theta = 3/2, leaving $x_4$.
//     #mistake[took the row with a positive coefficient][only rows with a negative coefficient count]
//   ]
//
// Anything else is plain Typst: *bold*, $x_1 + x_2 <= 4$, - lists, `code`.
// Build:  typst compile logbook.typ   (the craken fonts come with the package)

#import "logbook-template.typ": *
#show: logbook

// ---- write below this line ---------------------------------------------------
