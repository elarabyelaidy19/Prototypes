# CS 110L: Safety in Systems Programming

**Stanford University — Spring 2020**
**Instructors:** Ryan Eberhardt and Armin Namavari
**Schedule:** T/Th 10:30am - 11:20am

Source: <https://reberhardt.com/cs110l/spring-2020/>

---

## Table of Contents

- [Lecture 01: Welcome to CS 110L](#lecture-01-welcome-to-cs-110l)
- [Lecture 02: Memory Safety](#lecture-02-memory-safety)
- [Lecture 03: Error Handling](#lecture-03-error-handling)
- [Lecture 04: Object Oriented Rust](#lecture-04-object-oriented-rust)
- [Lecture 05: Traits and Generics](#lecture-05-traits-and-generics)
- [Lecture 06: Smart Pointers](#lecture-06-smart-pointers)
- [Lecture 07: Pitfalls in Multiprocessing](#lecture-07-pitfalls-in-multiprocessing)
- [Lecture 08: Google Chrome](#lecture-08-google-chrome)
- [Lecture 09: Intro to Multithreading](#lecture-09-intro-to-multithreading)
- [Lecture 10: Shared Memory](#lecture-10-shared-memory)
- [Lecture 11: Synchronization](#lecture-11-synchronization)
- [Lecture 12: Channels](#lecture-12-channels)
- [Lecture 13: Scalability and Availability](#lecture-13-scalability-and-availability)
- [Lecture 14: Information Security](#lecture-14-information-security)
- [Lecture 15: Futures I](#lecture-15-futures-i)
- [Lecture 16: Futures II](#lecture-16-futures-ii)
- [Lecture 17: Macros](#lecture-17-macros)
- [Lecture 18: Reflecting on Rust](#lecture-18-reflecting-on-rust)

---

## Lecture 01: Welcome to CS 110L
*Tuesday, April 7, 2020*

```
Welcome to CS 110L 👋

    Ryan Eberhardt and Armin Namavari
              April 7, 2020
Who are we?
Armin Namavari

! Coterm (class of '19 undergrad)
! Interested in security/building secure systems, applied cryptography, theory
! I've used Rust in the context of research on Tock, an embedded OS
! During shelter-in-place I've been...
    ○ been learning how to longboard
    ○ finger-knitting a blanket
    ○ trying to cook new things
! I like climbing and playing ultimate!
Ryan Eberhardt

! Coterm focused on systems and security
! I like growing things
Ryan Eberhardt

!   Coterm focused on systems and security
!   I like growing things
!   Pretty into music, especially funk, jazz, and fusion
!   I love doing pottery
!   Complete Rust impostor
!   But I do know CS 110 pretty well
HUGE thanks to Will Crichton for course material, advice, and feedback!
Who are you?
                          Who are you?
Fun and quirky community of 33 registered (as of Monday) + a few auditors!
Who are you?
                            Who are you?
                          Why are you taking this class?

! I want to learn Rust!
! Enhance what I will learn in CS110
! I'm growing to love systems, and I hate errors. CS 110L says it'll help me with this
! I am developing more interest in maintaining secure code, particularly in low-level
  systems, so this course seems like it'd be great for me.
! The projects look super cool! Also, in general, I think systems is really difficult for
  me, but despite this, I genuinely thought the content of 107 was really interesting
  and thus I think it'd be great for me to be able to explore these topics more deeply.
                           Who are you?
                 Have you heard anything about Rust before?

! Most people: “Nope.”
! Note: If you have taken CS 242 (two people), you will likely have seen most of the
  content from the first half of the class. (Feel free to stay for the second half!)
 Who are you?


           Say hi on #social!
(Let us know if you need a Slack invite.)
Why Rust?
             Why Rust?


                Why not C/C++?

Why not GC’ed languages (Java, Python, Go, etc.)
Why not C/C++?


  (topic of Thursday’s lecture)
“Convert a String to Uppercase in C,” taken VERBATIM from Tutorials Point


#include <stdio.h>
#include <string.h>
int main() {
   char s[100];
   int i;
   printf("\nEnter a string : ");
   gets(s);
   for (i = 0; s[i]!='\0'; i++) {
      if(s[i] >= 'a' && s[i] <= 'z') {
          s[i] = s[i] -32;
      }
   }
   printf("\nString in Upper Case = %s", s);
   return 0;
}
     Anatomy of a Stack Frame
                                                                                           High addresses
; push call arguments, in reverse                                    … previous stuff …
push    3
push    2
push    1                                                            Function parameters
call    callee    ; call subroutine ‘callee'

       callee:                                                         Return address
       push    ebp                     ; save old call frame
       mov     ebp, esp                ; initialize new call frame   Saved base pointer
       ...do stuff...
       mov     esp, ebp
       pop     ebp                     ; restore old call frame
       ret                             ; return
                                                                       Local variables

add           esp, 12         ; remove call arguments from frame


From https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl                           Low addresses
  Anatomy of a Stack Frame
                                                                          High addresses
; push call arguments, in reverse                   … previous stuff …
push    3
push    2
push    1                                           Function parameters
call    callee    ; call subroutine ‘callee'

   callee:                                            Return address
   push    ebp        ; save old call frame
   mov     ebp, esp   ; initialize new call frame   Saved base pointer
   ...do stuff...


                                                      Local variables


                                                                          Low addresses
  Anatomy of a Stack Frame
                                                                          High addresses
; push call arguments, in reverse                   … previous stuff …
push    3
push    2
push    1                                           Function parameters
call    callee    ; call subroutine ‘callee'

   callee:                                            Return address
   push    ebp        ; save old call frame
   mov     ebp, esp   ; initialize new call frame   Saved base pointer
   ...do stuff...


                                                      Local variables


                                                                          Low addresses
  Anatomy of a Stack Frame
                                                                          High addresses
; push call arguments, in reverse                   … previous stuff …
push    3
push    2
push    1                                           Function parameters
call    callee    ; call subroutine ‘callee'

   callee:                                            Return address
   push    ebp        ; save old call frame
   mov     ebp, esp   ; initialize new call frame   Saved base pointer
   ...do stuff...


                                                      Local variables


                                                                          Low addresses
  Anatomy of a Stack Frame
                                                                          High addresses
; push call arguments, in reverse                   … previous stuff …
push    3
push    2
push    1                                           Function parameters
call    callee    ; call subroutine ‘callee'

   callee:                                            Return address
   push    ebp        ; save old call frame
   mov     ebp, esp   ; initialize new call frame   Saved base pointer
   ...do stuff...
   mov     esp, ebp
   pop     ebp        ; restore old call frame
   ret                ; return
                                                      Local variables


                 💣😓
                                                                          Low addresses
 Morris Worm (circa 1988)
int main(int argc, char *argv[]) {
  char line[512];
  struct sockaddr_in sin;
  int i, p[2], pid, status;
  i = sizeof (sin);
  if (getpeername(0, &sin, &i) < 0) fatal(argv[0], "getpeername");
  if (gets(line) == NULL) exit(1);
  register char *sp = line;
  ...
  if ((pid = fork()) == 0) {
    close(p[0]);
    if (p[1] != 1) {
      dup2(p[1], 1);
      close(p[1]);
    }
    execv("/usr/ucb/finger", av);
    _exit(1);
  }
  ...
}
“Convert a String to Uppercase in C,” circa 2020

#include <stdio.h>
#include <string.h>
int main() {
   char s[100];
   int i;
   printf("\nEnter a string : ");
   gets(s);
   for (i = 0; s[i]!='\0'; i++) {
      if(s[i] >= 'a' && s[i] <= 'z') {
          s[i] = s[i] -32;
      }
   }
   printf("\nString in Upper Case = %s", s);
   return 0;
}
  Okay, well, I’m smarter than that.

Professional engineers don’t make such silly mistakes, right?
 “Like many modern cars, our car’s cellular capabilities facilitate a variety of safety and
 convenience features (e.g. the car can automatically call for help if it detects a crash).
However, long-range communication channels also offer an obvious target for potential
                                      attackers…”


The car has a 3G modem, but 3G service isn’t available everywhere (this was especially
 true in 2011, when the paper was written). As such, the car also has an analog audio
 modem with an associated telephone number! “To synthesize a digital channel in this
   environment, the manufacturer uses Airbiquity’s aqLink software modem to covert
                     between analog waveforms and digital bits.”
“As mentioned earlier, the aqLink code explicitly supports packet sizes up to 1024 bytes.
 However, the custom code that glues aqLink to the Command program assumes that
 packets will never exceed 100 bytes or so (presumably since well-formatted command
                             messages are always smaller)”


 “We also found that the entire attack can be implemented in a completely blind
fashion — without any capacity to listen to the car’s responses. Demonstrating this, we
  encoded an audio file with the modulated post-authentication exploit payload and
 loaded that file onto an iPod. By manually dialing our car on an office phone and then
   playing this “song” into the phone’s microphone, we are able to achieve the same
                             results and compromise the car.”


               http://www.autosec.org/pubs/cars-usenixsec2011.pdf
Umm… Well I just won’t work for a car company?
                              One-byte overflow in Chrome OS:
https://googleprojectzero.blogspot.com/2016/12/chrome-os-exploit-one-byte-overflow-and.html
Spot the overflow


      char buffer[128];
      int bytesToCopy = packet.length;
      if (bytesToCopy < 128) {
          strncpy(buffer, packet.data, bytesToCopy);
      }
Spot the overflow


      char buffer[128];
      int bytesToCopy = packet.length;
      if (bytesToCopy < 128) {        Proper bounds check
          strncpy(buffer, packet.data, bytesToCopy);
      }      Use of strncpy (avoiding unsafe strcpy)
Spot the overflow


Signed char buffer[128];
       int bytesToCopy = packet.length;
       if (bytesToCopy < 128) {
           strncpy(buffer, packet.data, bytesToCopy);
       }
                                  Cast to size_t (unsigned)
More reasons to come on Thursday
Aside: doesn’t Valgrind tell you about these things?

==1234== Memcheck, a memory error detector
==1234== Copyright (C) 2002-2011, and GNU GPL'd, by Julian Seward et al.
==1234== Using Valgrind-3.7.0 and LibVEX; rerun with -h for copyright info
==1234== Command: ./poop
==1234==
==1234== Invalid write of size 8
==1234==    at 0x400BCF: poop (main.c:24)
==1234==    by 0x400CCC: plop (main.c:100)
==1234==    by 0x400DFF: main (main.c:200)
==1234== Address 0x51f25c0 is 16 bytes inside a block of size 20 alloc'd
==1234==    at 0x4C2B6CD: malloc (in /usr/lib/valgrind/vgpreload_memcheck-amd64-linux.so)
==1234==    by 0x400BBB: poop (main.c:20)
==1234==    by 0x400CCC: plop (main.c:100)
==1234==    by 0x400DFF: main (main.c:200)
Why not use GC’ed languages?
Dear X,

I am looking forward to meeting you, and to a great year in Kimball!

Please consider an idea that I think will make life just a tiny bit better for everyone in the dorm this
year.

Last year, a number of us noticed that some people in the dorm were pretty messy, their rooms
were a mess, and trash piled up.

It turns out that not only are these trash piles unpleasant, but they can be a hazard, potentially even
to others.

According to The Cardinal Safety Letter (2012) :

“We have seen some fairly impressive mountains of trash overflowing the little dorm room trash
cans. This is not sanitary in the least!”

We also know that exhortations to clean up too often fall on deaf ears.

… more pleas follow …
The good news is that we have a completely painless solution that will be totally inclusive,
promote a clean dorm, reduce stress, and engages with Stanford’s goal of sustainability.

It’s all set to go, just pending your go-ahead.

I will collect the trash from each room in Kimball every week* to help everyone maintain a
clean living environment. For less than $.50 per student per weekday, we’ll take out everyone’s
trash for all 10 weeks of the quarter.* By using dorm funds, it doesn’t really cost anyone
anything, yet we all benefit.

It’s a great use of dorm funds, because it’ll benefit every member of the dorm equally, which is
exactly what dorm funds are for.

It’s free for the residents: all we have to do is tie our bags of trash, place them outside our
doors by midnight on Sunday, and I’ll pick them up on Monday – providing a clean start to the
week. Students will be saved the hassle and unpleasantness of completing this tiresome
chore, and none of us will have to put up with the messy consequences of piles of trash in
dorm rooms.

For just $25 per student, the entire dorm’s trash is taken care of for the entire quarter.
A twist

! Instead of putting your trash outside, leave it inside your room
! The GC will come knocking when it’s time to clean up
Downsides of garbage collection

! Expensive
    ! No matter what type of garbage collection is used, there will always be nontrivial
       memory overhead
! Disruptive
    ! Drop what you’re doing — it’s time for GC!
! Non-deterministic
    ! When will the next GC pause be? Who knows! Depends on how much memory
       is being used
! Precludes manual optimization
    ! In some situations, you may want to structure your data in memory in a specific
       way in order to achieve high cache performance
    ! GC can’t know how you will use memory, so it optimizes for the average use
       case
Note latency spikes every 2 minutes
LinkedIn Engineering:
“In our production environments, we have seen unexplainable large
STW pauses ( > 5 seconds) in our mission-critical Java applications.”
https://engineering.linkedin.com/blog/2016/02/eliminating-large-jvm-gc-pauses-caused-by-background-io-traffic
Latency matters

!   User interfaces
!   Games
!   Self-driving cars
!   Payment processing
!   High frequency trading
Garbage collectors aren’t all about safety

! Later in the quarter, we’ll learn about race conditions
! Garbage collection does not preclude race conditions! Memory safety issues
  persist even in garbage-collected environments
Design goals of Rust
About CS 110L 👋
Course outline

! Corequisite: CS 110
! Pass/fail
   ! You will get out what you put in
! First 3-4 weeks: Safety in a CS 107 context
! Rest of course: Safety in a CS 110 context
! Components:
   ! Lecture
   ! Weekly exercises (20%)
   ! Two projects (60%)
   ! Participation (20%)
Projects

! Project 1: Mini GDB
! Project 2: High-performance web server
! Functionality grading only
   ! The Rust compiler will be your interactive style grader!
! These projects are intended to give you additional experience in building real
  systems, while having to think about some of the safety issues we’re
  discussing
! Have a different idea? Let us know!
Exercises

! Each week, we’ll give you some small programming problems to reinforce
  the week’s lecture material
! Expected time: 1-3 hours
! In addition, you’ll be asked to complete an anonymous survey about how the
  class is going and how we can improve
Week 1 Exercise

! The first week, we'll be mainly covering conceptual material about Rust in
  lecture
! But that's no excuse for you to not start playing around with the language and
  getting used to its syntax!
! The first exercise will be to implement a simple hangman command line game.
! Our goal is to expose you to some of Rust's syntax without you having to deal
  with some of its quirks (which we'll discuss in more detail next week).
! You'll probably have to do some of your own searching through docs/stack
  overflow/etc, but we're available on Slack to support you! (as are your fellow
  classmates)
Work for Thursday

Before class, spend 10 minutes trying to spot as many bugs as you can find in
this code snippet:
https://web.stanford.edu/class/cs110l/lecture-notes/lecture-02/
(From the course website, click “Lecture notes” under Lecture 2)
```

---

## Lecture 02: Memory Safety
*Thursday, April 9, 2020*

```
Memory Safety in Rust

    Ryan Eberhardt and Armin Namavari
              April 7, 2020
Last lecture Ryan told us the bad news
          about C and C++…
This lecture, I’m going to tell you how
Rust addresses some of those issues
 Disclaimer: you can still write buggy Rust
programs! Rust just makes it harder to make
         certain kinds of mistakes!
Why is it so easy to screw up in C?
A Memory Exercise

! You should have completed this before class today!
   ○ We thank Will Crichton for this exercise and for giving us permission to
       use it in this class!
! Discuss your answers to the exercise in groups (we'll assign you to different
  breakout rooms in Zoom)
Dangling Pointers
Vec* vec_new() {
  Vec vec;
  vec.data = NULL;
  vec.length = 0;
  vec.capacity = 0;
  return &vec; // OOF
}
Double Frees
void main() {
  Vec* vec = vec_new();
  vec_push(vec, 107);

    int* n = &vec->data[0];
    vec_push(vec, 110);
    printf("%d\n", *n);

    free(vec->data);
    vec_free(vec); // YIKES
}
Iterator Invalidation
void main() {
  Vec* vec = vec_new();
  vec_push(vec, 107);

    int* n = &vec->data[0];
    vec_push(vec, 110);
    printf("%d\n", *n); // :(

    free(vec->data);
    vec_free(vec);
}
Memory Leaks
void vec_push(Vec* vec, int n) {
  if (vec->length == vec->capacity) {
    int new_capacity = vec->capacity * 2;
    int* new_data = (int*) malloc(new_capacity);
    assert(new_data != NULL);

        for (int i = 0; i < vec->length; ++i) {
          new_data[i] = vec->data[i];
        }

        vec->data = new_data; // OOP: we forget to free the old data
        vec->capacity = new_capacity;
    }

    vec->data[vec->length] = n;
    ++vec->length;
}
It is Incredibly Hard to Reason about Programs

!   Sometimes impossible (see CS 103, 154)
!   Sometimes more than impossible*
!   How do we get around this?
!   A: The language and the compiler!


    Image Source: https://www.newyorker.com/culture/culture-desk/living-in-alan-turings-future
The Language and the Compiler

! In order to make it easier to reason about programs, Rust needs to place some
  restrictions on the programs you can write.
     ! This makes it difficult (sometimes impossible) to write certain programs in safe
        Rust (we will talk about unsafe Rust later in the course).
! A lot of the cool guarantees we get from Rust come the checks its compiler
  performs
! Rust can sometimes exceed the performance of C because of compiler
  optimizations.
! If you want to delve deeper into these topics, be sure to take CS 242 (Programming
  Languages) and CS 143 (Compilers) as well as their follow-ons — these particular
  topics are outside of the scope of CS110L, but let us know if you’d like us to point you
  to relevant resources for learning more.
Dangling Pointers
Vec* vec_new() {
  Vec vec;              Wouldn’t it be nice if the compiler realized that
  vec.data = NULL;      vec “lives” within those two curly braces and
                        therefore its address shouldn’t be returned from
  vec.length = 0;
                        the function?
  vec.capacity = 0;
  return &vec; // OOF
}
Double Frees
void main() {
  Vec* vec = vec_new();
  vec_push(vec, 107);
                              Wouldn’t it be nice if the compiler enforced
    int* n = &vec->data[0];   that once free is called on a variable, that
    vec_push(vec, 110);       variable can no longer be used?
    printf("%d\n", *n);

    free(vec->data);
    vec_free(vec); // YIKES
}
Iterator Invalidation
void main() {
  Vec* vec = vec_new();
  vec_push(vec, 107);
                                Wouldn’t it be nice if the compiler stopped us
                                from modifying the data n was pointing to (as it
    int* n = &vec->data[0];     does in vec_push)?
    vec_push(vec, 110);
    printf("%d\n", *n); // :(

    free(vec->data);
    vec_free(vec);
}
Memory Leaks
void vec_push(Vec* vec, int n) {
  if (vec->length == vec->capacity) {
    int new_capacity = vec->capacity * 2;
    int* new_data = (int*) malloc(new_capacity);
    assert(new_data != NULL);                       Wouldn’t it be nice if the compiler noticed when
                                                    a piece of heap data no longer had anything
          for (int i = 0; i < vec->length; ++i) {   pointing to it? (and so then it could safely be
            new_data[i] = vec->data[i];
          }
                                                    freed?)

          vec->data = new_data; // OOP
          vec->capacity = new_capacity;
    }

        vec->data[vec->length] = n;
        ++vec->length;
}
Pause
How does Rust prevent us from making
      the errors we just saw?
Ownership

! The reason you ran into trouble when decomposing your code!
! From the Rust Book:
Controlling references to resources is a broader
idea in systems programming that isn’t unique
                    to Rust
Ownership in Context
fn main() {
    let s: String = "im a lil string”.to_string();
    let u = s;
    println!("{}", s); // println!(“{}”, u) compiles just fine!
}

Note: you can copy/paste this code and run it in your browser @ https://play.rust-lang.org/ !

error[E0382]: borrow of moved value: `s`
 --> src/main.rs:7:20
  |
5 |     let s: String = "im a lil string".to_string();
  |         - move occurs because `s` has type `std::string::String`, which does not implement the `Copy` trait
6 |     let u = s;
  |             - value moved here
7 |     println!("{}", s);
  |                    ^ value borrowed here after move
Ownership in Context
fn om_nom_nom(s: String) {
    println!("I have consumed {}", s);
}

fn main() {
    let s: String = "im a lil string".to_string();
    om_nom_nom(s);
    println!("{}", s);
}

error[E0382]: borrow of moved value: `s`
 --> src/main.rs:8:20
  |
6 |     let s: String = "im a lil string".to_string();
  |         - move occurs because `s` has type `std::string::String`, which does not implement the `Copy` trait
7 |     om_nom_nom(s);
  |                - value moved here
8 |     println!("{}", s);
  |                    ^ value borrowed here after move
With great power comes great responsibility
fn om_nom_nom(s: String) {
    println!("I have consumed {}", s);
}

fn main() {
    let s: String = "im a lil string".to_string();
    om_nom_nom(s);
    println!("{}", s);
}


 ! Each “owner” has the responsibility to clean up after itself
 ! When you move s into om_nom_nom, om_nom_nom becomes the owner of s, and it will free
   s when it’s no longer needed in that scope
     ! Technically the s parameter in om_nom_nom become the owner
 ! That means you can no longer use it in main!
An Exception to the Syntax: Copying
Given what we just saw, how can the following be valid syntax?

fn om_nom_nom(n: u32) {
    println!("{} is a very nice number", n);
}

fn main() {
    let n: u32 = 110;
    let m = n;                             Output:
    om_nom_nom(n);                         110 is a very nice number
                                           110 is a very nice number
    om_nom_nom(m);
                                           220
    println!("{}", m + n);
}
Wait a minute… that seems restrictive and
 must make it really hard to write code!
Thought experiment

! Say you have a group of lawyers that are reviewing and signing a contract over
  Google Docs
   ! Is this realistic? Nope :) But just pretend!
! What are some ground rules we’d need to set in order to avoid chaos?
   ! If someone modifies the contract before everyone else reviews/signs it,
       that’s fine
   ! But if someone modifies the contract while others are reviewing it, people
       might miss changes and think they’re signing a contract that says
       something else
   ! We should allow a single person to modify, or everyone to read, but not both
Borrowing Intuition

! I should be able to have as many “const” pointers to a piece of data that I
  like
! However if I have a “non-const” pointer to a piece of data at the same time,
  this could invalidate what the other const pointers are viewing (e.g. they can
  become dangling pointers…)
! If I have at most one “non-const” pointer at any given time, this should be
  OK.
Borrowing

! We can have multiple shared (immutable) references at once (with no
  mutable references) to a value.
! We can have only one mutable reference at once (no shared references to it)
! This is a paradigm that pops up a lot in systems programming, especially
  when you have “readers” and “writers.” In fact, you’ll see it in CS110 once
  you start talking about threading and concurrency.
Lifetimes

! The lifetime of a value starts when it’s created and ends the last time it’s
  used
! Rust doesn’t let you have a reference to a value that lasts longer than the
  value’s lifetime
! Rust computes lifetimes at compile time using static analysis (this is often an
  over-approximation)
! Rust calls the special “drop” function on a value once its lifetime ends (this is
  essentially a destructor).
Borrowing Example
fn change_it_up(s: &mut String) {
    *s = "goodbye".to_string();
}

fn make_it_plural(word: &mut String) {
    word.push('s');
}

fn let_me_see(s: &String) {
    println!("{}", s);
}

fn main() {
    let mut s = "hello".to_string();
    change_it_up(&mut s);
    let_me_see(&s);
    make_it_plural(&mut s);
    let_me_see(&s);
    // let's make it even more plural
    s.push(’s'); // does this seem strange?
    let_me_see(&s);
}
Borrowing Example: Vectors
fn main() {
    let v = vec![1, 2, 3];
    for i in v.iter_mut(){
        *i = 5;
    }
    for i in v.iter() {
        println!("{}", i);
    }
}

error[E0596]: cannot borrow `v` as mutable, as it is not declared as mutable
 --> src/main.rs:3:14
  |
2 |     let v = vec![1, 2, 3];
  |         - help: consider changing this to be mutable: `mut v`
3 |     for i in v.iter_mut(){
  |              ^ cannot borrow as mutable

error: aborting due to previous error
Reminder: The ownership and borrowing
  rules are enforced at compile time!
So what?

! This is a big deal — you only compile the program once, but you can run the
  executable as many times as you like afterward
! This is essentially making a fixed cost investment in our preprocessing.
! It’s generally desirable to shift checks from runtime to compile time.
    ! Generally, there is a tension between security and performance. Rust
        tries to give you both.
    ! Just don’t screw up your compiler :(
    ! Many security vulnerabilities pop up from making fancy optimizations
A Reminder: The First Assignment

! Again we just want you to get familiar with the basic syntax so we can talk
  about fancier concepts next week.
! You’ll definitely see ownership and borrowing in action — hopefully seeing it
  in this context and wrestling with the compiler/borrow checker will solidify
  your understanding (there’s only so much you can get from the lecture by
  itself)
! Please ask questions on Slack and help each other out!
Additional Resources/Readings

! Ownership and borrowing for visual learners!
! A great resource on iterating over vectors in Rust
! A Medium article about ownership, borrowing, and lifetimes
! CS242 lecture notes — shout out to Will Crichton to providing advice on
  explaining some of these concepts!
! The Rust book
! Check out sections 4.1 and 4.2 (deeper explanation of lifetimes)
```

---

## Lecture 03: Error Handling
*Tuesday, April 14, 2020*

```
Ownership (cont.) and
  Error Handling

    Ryan Eberhardt and Armin Namavari
              April 14, 2020
Congrats on finishing week 1!
General notes

! If you ever need an extension, just let us know
     ! This class is supposed to be fun
     ! Sleep deprivation -> coronavirus
! This class is in Rust, but it’s not a Rust class
     ! You Won’t Believe This One Weird Fact
     ! This class is more about exposure to ideas you can take with you
     ! Rust is a response to the problems of C/C++. If you never use Rust again in your life, it
        would still be good to know about
          ! The problems with C/C++
          ! How people are responding
          ! The problems with that response
     ! There are lots of great questions on Slack. Don’t be intimidated by fancy lingo flying
        around
Today’s lecture

! Recap ownership
! Work through some examples of ownership in code
! Talk about error handling in Rust
Ownership
Ownership — in C!
/* Get status of the virtual port (ex. tunnel, patch).
 *
 * Returns '0' if 'port' is not a virtual port or has no errors.
 * Otherwise, stores the error string in '*errp' and returns positive errno
 * value. The caller is responsible for freeing '*errp' (with free()).
 *
 * This function may be a null pointer if the ofproto implementation does
 * not support any virtual ports or their states.
 */
int (*vport_get_status)(const struct ofport *port, char **errp);


                                Open vSwitch
/**
 * @note Any old dictionary present is discarded and replaced with a copy of the new one. The
 * caller still owns val is and responsible for freeing it.
 */
int av_opt_set_dict_val(void *obj, const char *name, const AVDictionary *val, int search_flags);


                                             ffmpeg
/**
  * iscsi_boot_create_target() - create boot target sysfs dir
  * @boot_kset: boot kset
  * @index: the target id
  * @data: driver specific data for target
  * @show: attr show function
  * @is_visible: attr visibility function
  * @release: release function
  *
  * Note: The boot sysfs lib will free the data passed in for the caller
  * when all refs to the target kobject have been released.
  */
struct iscsi_boot_kobj *
iscsi_boot_create_target(struct iscsi_boot_kset *boot_kset, int index,
                 void *data,
                 ssize_t (*show) (void *data, int type, char *buf),
                 umode_t (*is_visible) (void *data, int type),
                 void (*release) (void *data))
{
      return iscsi_boot_create_kobj(boot_kset, &iscsi_boot_target_attr_group,
                           "target%d", index, data, show, is_visible,
                           release);
}
EXPORT_SYMBOL_GPL(iscsi_boot_create_target);

                                 Linux kernel
/* Looks up a port named 'devname' in 'ofproto'. On success, returns 0 and
 * initializes '*port' appropriately. Otherwise, returns a positive errno
 * value.
 *
 * The caller owns the data in 'port' and must free it with
 * ofproto_port_destroy() when it is no longer needed. */
int (*port_query_by_name)(const struct ofproto *ofproto,
                          const char *devname, struct ofproto_port *port);


                               Open vSwitch
/**
 * dvb_unregister_frontend() - Unregisters a DVB frontend
 *
 * @fe: pointer to &struct dvb_frontend
 *
 * Stops the frontend kthread, calls dvb_unregister_device() and frees the
 * private frontend data allocated by dvb_register_frontend().
 *
 * NOTE: This function doesn't frees the memory allocated by the demod,
 * by the SEC driver and by the tuner. In order to free it, an explicit call to
 * dvb_frontend_detach() is needed, after calling this function.
 */
int dvb_unregister_frontend(struct dvb_frontend *fe);


                                  Linux kernel
static void mapper_count_similar_free(mapper_t* pmapper, context_t* _) {
     mapper_count_similar_state_t* pstate = pmapper->pvstate;
     slls_free(pstate->pgroup_by_field_names);

    // lhmslv_free will free the keys: we only need to free the void-star values.
    for (lhmslve_t* pa = pstate->pcounts_by_group->phead; pa != NULL; pa = pa->pnext) {
         unsigned long long* pcount = pa->pvvalue;
         free(pcount);
    }
    lhmslv_free(pstate->pcounts_by_group);

    ...
}


                                          Miller
Compile time vs run time
What does my Rust code actually do?

! Passing ownership: just passes a pointer
   ! The compiler will insert the appropriate free() call for you
! Passing references: just passes a pointer
! Explicit copy: copies memory!
Will it compile?


     Live demo
“One thing that’s confusing is why sometimes I need to &var and other
     times I can just use var: for example, set.contains(&var), but
                        set.insert(var) – why?"
Error handling
// Imagine this is code for a network server that has just received and is
// processing a packet of data.
size_t len = packet.length;
void *buf = malloc(len);
memcpy(buf, packet.data, len);
// Do stuff with buf
// ...
free(buf);
Two issues

! Use of NULL in place of a real value
! Lack of proper error handling
Handling nulls
“I call it my billion-dollar mistake. It was the invention of the null reference in 1965. At
that time, I was designing the first comprehensive type system for references in an object
oriented language (ALGOL W). My goal was to ensure that all use of references should be
absolutely safe, with checking performed automatically by the compiler. But I couldn't
resist the temptation to put in a null reference, simply because it was so easy to
implement. This has led to innumerable errors, vulnerabilities, and system crashes, which
have probably caused a billion dollars of pain and damage in the last forty years.”

- Tony Hoare
NULL pointer dereferences
Why are NULLs so dangerous?

 What should we do about it?
fn feeling_lucky() -> Option<String> {
    if get_random_num() > 10 {
        Some(String::from("I'm feeling lucky!"))
    } else {
        None
    }
}
fn feeling_lucky() -> Option<String> {
    if get_random_num() > 10 {
        Some(String::from("I'm feeling lucky!"))
    } else {
        None
    }
}


     if feeling_lucky().is_none() {
         println!("Not feeling lucky :(");
     }
           fn feeling_lucky() -> Option<String> {
               if get_random_num() > 10 {
                   Some(String::from("I'm feeling lucky!"))
               } else {
                   None
               }
           }


let message = feeling_lucky().unwrap_or(String::from("Not lucky :("));
fn feeling_lucky() -> Option<String> {
    if get_random_num() > 10 {
        Some(String::from("I'm feeling lucky!"))
    } else {
        None
    }
}


 match feeling_lucky() {
     Some(message) => {
         println!("Got message: {}", message);
     },
     None => {
         println!("No message returned :-/");
     },
 }
Handling errors
Error handling in C

! If a function might encounter an error, its return type is made to be int (or
  sometimes void*).
! If the function is successful, it returns 0. Otherwise, if an error is
  encountered, it returns -1. (If the function is returning a pointer, it returns a
  valid pointer in the success case, or NULL if an error occurs.)
! The function that encountered the error sets the global variable errno to be
  an integer indicating what went wrong. If the caller sees that the function
  returned -1 or NULL, it can check errno to see what error was encountered
#define EPERM           1       /* Operation not permitted */               #define EL2HLT          51   /* Level 2 halted */
#define ENOENT          2       /* No such file or directory */             #define EBADE           52   /* Invalid exchange */
#define ESRCH           3       /* No such process */                       #define EBADR           53   /* Invalid request descriptor */
#define EINTR           4       /* Interrupted system call */               #define EXFULL          54   /* Exchange full */
#define EIO             5       /* I/O error */                             #define ENOANO          55   /* No anode */
#define ENXIO           6       /* No such device or address */             #define EBADRQC         56   /* Invalid request code */
#define E2BIG           7       /* Arg list too long */                     #define EBADSLT         57   /* Invalid slot */
#define ENOEXEC         8       /* Exec format error */                     #define EBFONT          59   /* Bad font file format */
#define EBADF           9       /* Bad file number */                       #define ENOSTR          60   /* Device not a stream */
#define ECHILD         10       /* No child processes */                    #define ENODATA         61   /* No data available */
#define EAGAIN         11       /* Try again */                             #define ETIME           62   /* Timer expired */
#define ENOMEM         12       /* Out of memory */                         #define ENOSR           63   /* Out of streams resources */
#define EACCES         13       /* Permission denied */                     #define ENONET          64   /* Machine is not on the network */
#define EFAULT         14       /* Bad address */                           #define ENOPKG          65   /* Package not installed */
#define ENOTBLK        15       /* Block device required */                 #define EREMOTE         66   /* Object is remote */
#define EBUSY          16       /* Device or resource busy */               #define ENOLINK         67   /* Link has been severed */
#define EEXIST         17       /* File exists */                           #define EADV            68   /* Advertise error */
#define EXDEV          18       /* Cross-device link */                     #define ESRMNT          69   /* Srmount error */
#define ENODEV         19       /* No such device */                        #define ECOMM           70   /* Communication error on send */
#define ENOTDIR        20       /* Not a directory */                       #define EPROTO          71   /* Protocol error */
#define EISDIR         21       /* Is a directory */                        #define EMULTIHOP       72   /* Multihop attempted */
#define EINVAL         22       /* Invalid argument */                      #define EDOTDOT         73   /* RFS specific error */
#define ENFILE         23       /* File table overflow */                   #define EBADMSG         74   /* Not a data message */
#define EMFILE         24       /* Too many open files */                   #define EOVERFLOW       75   /* Value too large for defined data type */
#define ENOTTY         25       /* Not a typewriter */                      #define ENOTUNIQ        76   /* Name not unique on network */
#define ETXTBSY        26       /* Text file busy */                        #define EBADFD          77   /* File descriptor in bad state */
#define EFBIG          27       /* File too large */                        #define EREMCHG         78   /* Remote address changed */
#define ENOSPC         28       /* No space left on device */               #define ELIBACC         79   /* Can not access a needed shared library */
#define ESPIPE         29       /* Illegal seek */                          #define ELIBBAD         80   /* Accessing a corrupted shared library */
#define EROFS          30       /* Read-only file system */                 #define ELIBSCN         81   /* .lib section in a.out corrupted */
#define EMLINK         31       /* Too many links */                        #define ELIBMAX         82   /* Attempting to link in too many shared libraries */
#define EPIPE          32       /* Broken pipe */                           #define ELIBEXEC        83   /* Cannot exec a shared library directly */
#define EDOM           33       /* Math argument out of domain of func */   #define EILSEQ          84   /* Illegal byte sequence */
#define ERANGE         34       /* Math result not representable */         #define ERESTART        85   /* Interrupted system call should be restarted */
#define EDEADLK        35       /* Resource deadlock would occur */         #define ESTRPIPE        86   /* Streams pipe error */
#define ENAMETOOLONG   36       /* File name too long */                    #define EUSERS          87   /* Too many users */
#define ENOLCK         37       /* No record locks available */             #define ENOTSOCK        88   /* Socket operation on non-socket */
#define ENOSYS         38       /* Function not implemented */              #define EDESTADDRREQ    89   /* Destination address required */
#define ENOTEMPTY      39       /* Directory not empty */                   #define EMSGSIZE        90   /* Message too long */
#define ELOOP          40       /* Too many symbolic links encountered */   #define EPROTOTYPE      91   /* Protocol wrong type for socket */
#define EWOULDBLOCK    EAGAIN   /* Operation would block */                 #define ENOPROTOOPT     92   /* Protocol not available */
#define ENOMSG         42       /* No message of desired type */            #define EPROTONOSUPPORT 93   /* Protocol not supported */
#define EIDRM          43       /* Identifier removed */                    #define ESOCKTNOSUPPORT 94   /* Socket type not supported */
#define ECHRNG         44       /* Channel number out of range */           #define EOPNOTSUPP      95   /* Operation not supported on transport endpoint */
#define EL2NSYNC       45       /* Level 2 not synchronized */              #define EPFNOSUPPORT    96   /* Protocol family not supported */
#define EL3HLT         46       /* Level 3 halted */                        #define EAFNOSUPPORT    97   /* Address family not supported by protocol */
#define EL3RST         47       /* Level 3 reset */                         #define EADDRINUSE      98   /* Address already in use */
#define ELNRNG         48       /* Link number out of range */              #define EADDRNOTAVAIL   99   /* Cannot assign requested address */
#define EUNATCH        49       /* Protocol driver not attached */          ...
#define ENOCSI         50       /* No CSI structure available */
    ssize_t siz = msgrcv(msqid, msgp, msgsz, msgtyp, msgflg);
    if (siz<0) { // msgrcv failed and has set errno
       if (errno == ENOMSG)
          dosomething();
       else if (errno == EAGAIN)
          dosomethingelse();
       /// etc
       else {
           syslog(LOG_DAEMON|LOG_ERR, "msgrcv failure with %s\n",
                  strerror(errno));
           exit(EXIT_FAILURE);
       };
    };


https://stackoverflow.com/questions/46013418/how-to-check-the-value-of-errno
CVE-2015-8812

! Critical Linux kernel vulnerability: by sending a malformed network packet, a
  remote attacker could execute arbitrary code in the kernel
! A set of kernel networking functions were returning -1 for error, 0 for
  success, but also other values for “warnings”
    ! Returned NET_XMIT_CN (defined to be 2) when congestion was
        detected
! Code calling these functions saw nonzero return code and assumed there
  was a network error
! Freed memory that was still being used for the network. Use-after-free +
  double free!
 The fix

--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -149,7 +149,7 @@ static int iwch_l2t_send(struct t3cdev *tdev, struct sk_buff *skb, struct
l2t_en
     error = l2t_send(tdev, skb, l2e);
     if (error < 0)
          kfree_skb(skb);
-    return error;
+    return error < 0 ? error : 0;
  }


                                           😰
Most languages use exceptions
What are some downsides of exceptions?
Exceptional Exceptions

! Failure modes are hard to spot: any function can throw any exception at any
  time
! Hard to manage in evolving codebases
! Especially hard when manual memory management is involved
Error handling in Rust

! If an unrecoverable error occurs, panic
   if sad_times() {
     panic!("Sad times!");
   }
! If a recoverable error may occur, return a Result
    ! Result<T, E> can either be Ok(some value of type T) or
        Err(some value of type E)
Usage of Result

    fn poke_toddler() -> Result<&'static str, &'static str> {
        if get_random_num() > 10 {
            Ok("Hahahaha!")
        } else {
            Err("Waaaaahhh!")
        }
    }

    fn main() {
        match poke_toddler() {
            Ok(message) => println!("Toddler said: {}", message),
            Err(cry) => println!("Toddler cried: {}", cry),
        }
    }
unwrap() and expect()


 // Panic if the baby cries:
 let ok_message = poke_toddler().unwrap();
 // Same thing, but print a more descriptive panic message:
 let ok_message = poke_toddler().expect("Toddler cried :(“);


 // Read line from stdin
 let mut line = String::new();
 io::stdin().read_line(&mut line).expect("Failed to read from stdin");
```

---

## Lecture 04: Object Oriented Rust
*Thursday, April 16, 2020*

*No slides available for this lecture.*

---

## Lecture 05: Traits and Generics
*Tuesday, April 21, 2020*

```
Traits and Generics

   Ryan Eberhardt and Armin Namavari
             April 21, 2020
The Plan for Today

!   Introduce traits
!   Introduce generics
!   See examples in real world systems! (if time permits)
!   Next time: wrap up traits/generics + discuss smart pointers!
!   Next week: Multiprocessing pitfalls and multiprocessing in Rust!
!   *Heads up: I will be switching between slides/code — hopefully the context
    switching won’t incur too much overhead.
Please ask Questions!

! Or else I will happily blast through the slides
! Feel free to unmute yourself
! I can also look for hands when I pause for questions
 Grouping Related Functionality Together

  ! What are some ways you’ve seen this in other languages?


Sources: https://www.chegg.com/homework-help/questions-and-answers/c-programming-create-required-classes
header-implementation-files-implement-following-hier-q18713018, https://qph.fs.quoracdn.net/main-
qimg-4e054f260faefa31e66e02d2345091f3.webp
Traits — Some Common Ones in Rust

! What can this type do?
    ! Display (lecture example)
    ! Clone/Copy (exercises)
    ! Iterator/IntoIterator (exercises)
    ! Eq/Partial Eq (exercises)
! Allows us to override functionality
    ! Drop (lecture example)
    ! Deref (later)
! Allows us to define default implementations
    ! ToString (will see later how this interacts with Display)
! Allows us to overload operators
    ! +, -, *, /, >, <, ==, !=, etc. (lecture example)
Linked List Traits

! Playground example here (from last lectures notes)
! Let’s see Display and Drop in action!
Deriving Traits

! Provide reasonable default implementations
! Common w/ Eq/PartialEq, Copy/Clone, Debug
   ! PartialEq for f64: NaN != NaN
! Point playground example
pub trait Copy: Clone {
    // Empty.
}
Defining Your Own Traits

! What if we wanted a trait to describe things that have (L2) norms? e.g.
  Vec<f64>, or say our new Point type.
! ComputeNorm example with Point (also, overloading “+”)
   ! Playground link
   ! Associated type with Add — will pop up with iterators too!
Generics

! You’ve seen them before: Vec<T>, Box<T>, Option<T>, Result<T, E>
! Soon: LinkedList<T> (exercises)
! MyOption<T>, MatchingPair<T>
   ! Playground link
Trait Bounds and Syntax in Functions

! Sometimes we want to specify trait bounds — i.e. for what kinds of types
  can we call this function?
    ! Generalize previous example: playground link
! identity_fn, print_excited, print_min
    ! Playground link
Trait Bounds in ToString

impl<T: fmt::Display + ?Sized> ToString for T {
    #[inline]
    default fn to_string(&self) -> String {
        use fmt::Write;
        let mut buf = String::new();
        buf.write_fmt(format_args!("{}", self))
            .expect("a Display implementation returned an error
unexpectedly");
        buf.shrink_to_fit();
        buf
    }
}
Zero Cost Abstractions

! How expensive is it to keep track of all this information?
! Thanks to the magic of the Rust compiler, it’s not too expensive!
! e.g. Generics => multiple versions of compiled code for different types
   ! Compiler infers which one to use based on type of a piece of data
! Read more here
Examples in Real World Systems (e.g. Tock)

! Tock is an embedded OS for low-powered IoT (Internet of Things) devices
! It’s written in Rust!
! You can see traits everywhere
    ! Here is just one file
    ! Using traits to define a syscall interface
! You can’t do anything like this in C!
Additional Reading

! CS242 Notes on Traits
! About Common Rust Traits
! The Rust Book on Traits
```

---

## Lecture 06: Smart Pointers
*Thursday, April 23, 2020*

```
Smart Pointers

Ryan Eberhardt and Armin Namavari
          April 23, 2020
The Plan for Today

! Review Box<T>
! Introduce Rc<T>
! Introduce RefCell<T>
Please ask Questions!

! Or else I will happily blast through the slides
! Feel free to unmute yourself
! Ryan: “At the end of the quarter, I’ll randomly select at least three people that
  participated 10 times, and I’ll make you a custom mug (see @paintedpeas) if
  you’re still around campus once I can access a ceramics studio again.
  Asking or answering a question in lecture (out loud, or in the chat) or on
  Slack all count as participation.”
Box<T>

! You’ve seen this already in the context of LinkedList
! Have a unique pointer to a chunk of heap memory
! What are some limitations of Box<T>?
Rc<T>

! What if I want to have multiple pointers to the same chunk of heap memory?
! Recall borrowing rules: can have multiple immutable references OR at most
  one mutable reference.
! Rc<T> lets you have multiple immutable references to a chunk of heap
  memory (i.e. we can’t modify this chunk of memory)
   ! Why do we need this?
   ! A: Rust’s borrow checking rules!
! Caution: you can get memory leaks if you create reference cycles! (if you
  need reference cycles, you need to throw other smart pointer types into the
  mix)
 Example: Adding Multiple Views to Our List

  ! What if we want to be able to have our linked lists “intersect” one another so
    that they can share certain parts while the data structure is immutable? (this
    is a paradigm common in functional data structures)
  ! This can let us see into the “history” of our data structure!
  ! These are sometimes known as persistent data structures
  ! Playground example
      ! Start
      ! End


Image: https://doc.rust-lang.org/book/ch15-04-rc.html
RefCell<T>

! RefCell let’s you “lie” to the compiler by providing interior mutability
! That is, you can have shared references to the cell, but you can mutate what’s
  inside of it!
! Its new function doesn’t heap allocate, here are the things that do.
! This is still safe because it will enforce the reference rules at runtime (but this is
  now an additional cost)
! (try_)borrow/borrow_mut
! Common pattern: Rc<RefCell<T>>
    ! You will often see this in fancier data structures that have multiple pointers
        pointing to the same piece of data, which might have to support mutability
Additional Reading

! The Rust book on Rc
! The Rust book on RefCell
! CS242 on Smart Pointers (this will show you how Box and Rc are
  implemented under the hood!)
! Quora thread about applications of persistent data structures (e.g. version
  control, optimizing React applications)
   ! Concurrency
```

---

## Lecture 07: Pitfalls in Multiprocessing
*Tuesday, April 28, 2020*

```
Multiprocessing

 Ryan Eberhardt and Armin Namavari
           April 28, 2020
Hello week 4!


 You’re killing it!! 🎉 🔥
Class logistics

! Week 3 exercises due Wednesday
   ! Please let us know if you get stuck / feel confused! We want you to
        sleep!
   ! Also, remember you can substitute any week’s exercises for a blog post
        if you’d like!
! First project (mini GDB) will be coming out late this week, due two weeks later
   ! You’ll be free to work with a partner!
   ! We’ll have some way for you to find someone to work with if you’d like
        (suggestions welcome)
! No exercise this week (just the survey)
This week

! Taking a brief break from Rust-land!
! Today: why you shouldn’t use fork(), pipe(), or signal() 🔥 🚒
! Thursday: multiprocessing case study of Google Chrome
Don’t call fork()
Why fork? 🍴

! Get concurrent execution (i.e. run another piece of your own program at the
  same time)
! Invoke external functionality on the system (i.e. run a different executable)
Concurrent execution

! How might we mess this up? (live code)
Concurrent execution

! How might we mess this up?
   ! Accidentally nesting forks when spawning multiple child processes
   ! Runaway children
   ! Using data structures when threads are involved
   ! Failure to clean up (zombie processes)
Concurrent execution

! I argue: It’s better to take the code you want to run concurrently and put it in
  a separate executable
    ! You won’t inherit data from the parent process’s virtual address space,
       but that’s the point
    ! Use arguments or pipes to provide whatever information is needed for
       the child process to run
Why fork? 🍴

! Get concurrent execution (i.e. run another piece of your own program at the
  same time)
! Invoke external functionality on the system (i.e. run a different executable)
Invoking external functionality

! How do you start a subprocess?
   ! fork(), then exec()
! Almost every fork() is followed by an exec()
! Why didn’t they just make a combined syscall?
Child processes in Windows


BOOL CreateProcessW(                            BOOL CreateProcessAsUserW(
   LPCWSTR               lpApplicationName,        HANDLE                hToken,
   LPWSTR                lpCommandLine,            LPCWSTR               lpApplicationName,
   LPSECURITY_ATTRIBUTES lpProcessAttributes,      LPWSTR                lpCommandLine,
   LPSECURITY_ATTRIBUTES lpThreadAttributes,       LPSECURITY_ATTRIBUTES lpProcessAttributes,
   BOOL                  bInheritHandles,          LPSECURITY_ATTRIBUTES lpThreadAttributes,
   DWORD                 dwCreationFlags,          BOOL                  bInheritHandles,
   LPVOID                lpEnvironment,            DWORD                 dwCreationFlags,
   LPCWSTR               lpCurrentDirectory,       LPVOID                lpEnvironment,
   LPSTARTUPINFOW        lpStartupInfo,            LPCWSTR               lpCurrentDirectory,
   LPPROCESS_INFORMATION lpProcessInformation      LPSTARTUPINFOW        lpStartupInfo,
);                                                 LPPROCESS_INFORMATION lpProcessInformation
                                                );
fork() and exec() rationale

! The Unix approach is simple and powerful
   ! You can make any desired customizations to your child process before it
      executes the desired binary
   ! Change environment variables, rewire file descriptors, block/unblock
      signals, take control of the terminal, enable debugging, etc.
! Simple != easy
   ! malloc() and free() are simple, too!
Common multiprocessing tactic

! Let fork() and exec() be. The power is there if you need it.
! Define a higher-level abstraction to take care of the common cases
   ! You’re implementing one such simple abstraction in CS 110 assign3!
   ! Usually, these abstractions allow a “pre-exec function” to be specified,
       which is called after fork() but before exec()
   ! With such an abstraction, really no reason to call fork() or exec()!
Command in Rust

! Build a Command:
   Command::new("ps")
       .args(&["--pid", &pid.to_string(), "-o", "pid= ppid= command="])
! Run, and get the output in a buffer:
   let output = Command::new("ps")
       .args(&["--pid", &pid.to_string(), "-o", "pid= ppid= command="])
       .output()
       .expect("Failed to execute subprocess”)
    ! Includes exit status, stdout, and stderr
Command in Rust

! Run (without swallowing output), and get the status code:
   let status = Command::new("ps")
       .args(&["--pid", &pid.to_string(), "-o", "pid= ppid= command="])
       .status()
       .expect("Failed to execute subprocess")
! Spawn and immediately return:
   let child = Command::new("ps")
       .args(&["--pid", &pid.to_string(), "-o", "pid= ppid= command="])
       .spawn()
       .expect("Failed to execute subprocess")
    ! This returns a Child, which you need to wait on at some point!
      let status = child.wait()
Command in Rust

! Pre-exec function:
   use std::os::unix::process::CommandExt;
   ...
   let cmd = Command::new("ls");
   unsafe {
       cmd.pre_exec(function_to_run);
   }
   let child = cmd.spawn();
    ! The unsafe block acts as a warning to avoid allocating memory or accessing
      shared data in the presence of threads
    ! It’s quite rare that you would need to specify a pre_exec function (the Command
      API takes care of most things), but you’ll need it for Project 1
Concurrent execution

! How might we mess this up?
   ! Accidentally nesting forks when spawning multiple child processes
   ! Runaway children
   ! Using data structures when threads are involved
   ! Failure to clean up (zombie processes)
      ! You could implement a struct with a Drop trait that calls wait()
Don’t call pipe()
Problems with pipes

What can you think of?
Problems with pipes

! Leaked file descriptors
! Calling close() on bad values
  Example:
  if (close(fds[1] == -1)) {
        printf("Error closing!");
  }
! Use-before-pipe (i.e. use of uninitialized ints)
! Use-after-close
Potential solution

! Add a layer of abstraction!
! Writing to a stdin pipe:
   let mut child = Command::new("cat")
           .stdin(Stdio::piped())
           .stdout(Stdio::piped())
           .spawn()?;
   child.stdin.as_mut().unwrap().write_all(b"Hello, world!\n")?;
   let output = child.wait_with_output()?;
! The os_pipe crate allows for creating arbitrary pipes. (The Drop trait closes
  the pipe.)
Aside
Don’t call signal()
Is it safe?

! Discuss in groups
   ! Introduce yourself!
   ! See Lecture Notes on course website
(Continued next time)
```

---

## Lecture 08: Google Chrome
*Thursday, April 30, 2020*

```
Multiprocessing (part 2)

     Ryan Eberhardt and Armin Namavari
               April 30, 2020
Project logistics

! Project (mini gdb) coming out tomorrow, due May 18
! You’re also welcome to propose your own project! Run your idea by us
  before you start working on it
   ! Rust tooling (e.g. annotate code showing where values get dropped)
   ! Write a raytracer
   ! Pick a command-line tool and try to beat its performance (e.g. grep)
   ! Implement a simple database
Today

! (From last time) Why you shouldn’t use signal() 🔥 🚒
! Multiprocessing case study of Google Chrome
Don’t call signal()
signal() is dead. Long live sigaction()
signal() is dead. Long live sigaction()


 Portability

 The only portable use of signal() is to set a signal's disposition to SIG_DFL or SIG_IGN. The
 semantics when using signal() to establish a signal handler vary across systems (and
 POSIX.1 explicitly permits this variation); do not use it for this purpose.
 POSIX.1 solved the portability mess by specifying sigaction(2), which provides explicit
 control of the semantics when a signal handler is invoked; use that interface instead of
 signal().


                           Check out the man page if you have time!
Exit on ctrl+c


                 void handler(int sig) {
                     exit(0);
                 }

                 int main() {
                     signal(SIGINT, handler);
                     while (true) {
                         sleep(1);
                     }
                     return 0;
                 }


                    Looks good! ✅
Count number of SIGCHLDs received
       static volatile int sigchld_count = 0;

       void handler(int sig) {
           sigchld_count += 1;
       }

       int main() {
           signal(SIGCHLD, handler);
           const int num_processes = 10;
           for (int i = 0; i < num_processes; i++) {
               if (fork() == 0) {
                    sleep(1);
                    exit(0);
               }
           }
           while (waitpid(-1, NULL, 0) != -1) {}
           printf("All %d processes exited, got %d SIGCHLDs.\n",
               num_processes, sigchld_count);
           return 0;
       }

        Okay if we were to use sigaction ⚠
Count number of running processes
        static volatile int running_processes = 0;

        void handler(int sig) {
            while (waitpid(-1, NULL, WNOHANG) > 0) {
                running_processes -= 1;
            }
        }

        int main() {
            signal(SIGCHLD, handler);
            const int num_processes = 10;
            for (int i = 0; i < num_processes; i++) {
                if (fork() == 0) {
                     sleep(1);
                     exit(0);
                }
                running_processes += 1;
                printf("%d running processes\n", running_processes);
            }
            while(running_processes > 0) {
                pause();
            }
            printf("All processes exited! %d running processes\n", running_processes);
            return 0;
        }


    Not safe (concurrent use of running_processes) 🚫
Print on ctrl+c

                  void handler(int sig) {
                      printf("Hehe, not exiting!\n");
                  }

                  int main() {
                      signal(SIGINT, handler);
                      while (true) {
                          printf("Looping...\n");
                          sleep(1);
                      }
                      return 0;
                  }


                          Not safe!! 🚫
Print on ctrl+c

                  void handler(int sig) {
                      printf("Hehe, not exiting!\n");
                  }

                  int main() {
                      signal(SIGINT, handler);
                      while (true) {
                          printf("Looping...\n");
                          sleep(1);
                      }
                      return 0;
                  }


                          Not safe!! 🚫
void print_hello(int sig) {     int main() {
    printf("Hello world!\n");       const char* message = "Hello world ";
}                                   const size_t repeat = 1000;

                                    char *repeated_msg = malloc(repeat * strlen(message) + 2);
                                    for (int i = 0; i < repeat; i++) {
                                        strcpy(repeated_msg + (i * strlen(message)), message);
                                    }
                                    repeated_msg[repeat * strlen(message)] = '\n';
                                    repeated_msg[repeat * strlen(message) + 1] = '\0';

                                    signal(SIGUSR1, print_hello);
                                    if (fork() == 0) {
                                        pid_t parent_pid = getppid();
                                        while (true) {
                                            kill(parent_pid, SIGUSR1);
                                        }
                                        return 0;
                                    }

                                    while (true) {
                                        printf(repeated_msg);
                                    }

                                    free(repeated_msg);
                                    return 0;
                                }
Async-safe functions

! vfprintf is a 1787-line function!
   1309   /* Lock stream. */
   1310   _IO_cleanup_region_start ((void (*) (void *)) &_IO_funlockfile, s);
   1311   _IO_flockfile (s);
! Apparently also does some other async-unsafe business
! You should avoid functions that use global state
   ! Many functions do this, even if you may not realize it
   ! malloc and free are not async-signal-safe!
! List of safe functions: http://man7.org/linux/man-pages/man7/signal-safety.
  7.html
What should we do?
Avoiding signal handling

! Anything substantial should not be done in a signal handler
! How can we handle signals, then?
! The “self-pipe” trick was invented in the early 90s:
   ! Create a pipe
   ! When you’re awaiting a signal, read from the pipe (this will block until
      something is written to it)
   ! In the signal handler, write a single byte to the pipe
    Avoiding signal handling

     ! signalfd added official support for this hack
int main(int argc, char *argv[]) {                   for (;;) {
    sigset_t mask;                                       s = read(sfd, &fdsi,
    int sfd;                                                 sizeof(struct signalfd_siginfo));
    struct signalfd_siginfo fdsi;                        if (s != sizeof(struct signalfd_siginfo))
    ssize_t s;                                               handle_error("read");

    sigemptyset(&mask);                                  if (fdsi.ssi_signo == SIGINT) {
    sigaddset(&mask, SIGINT);                                printf("Got SIGINT\n");
    sigaddset(&mask, SIGQUIT);                           } else if (fdsi.ssi_signo == SIGQUIT) {
                                                             printf("Got SIGQUIT\n");
    /* Block signals so that they aren't handled             exit(EXIT_SUCCESS);
       according to their default dispositions */        } else {
                                                             printf("Read unexpected signal\n");
    if (sigprocmask(SIG_BLOCK, &mask, NULL) == -1)       }
        handle_error("sigprocmask");                 }

    sfd = signalfd(-1, &mask, 0);
    if (sfd == -1) handle_error("signalfd");
What about asynchronous signal handling?

! I thought part of the benefit of signal handlers was you can handle events
  asynchronously! (You can be doing work in your program, and quickly take a
  break to do something to handle a signal)
! Reading from a pipe or signalfd precludes concurrency: I’m either doing work,
  or reading to wait for a signal, but not both at the same time
! How can we address this?
    ! Use threads
        ! Can still have concurrency problems!
        ! But we have more tools to reason about and control those problems
    ! Use non-blocking I/O (week 8)
Ctrlc crate

! Rust has a ctrlc crate: register a function to be executed on ctrl+c (SIGINT)
! How does it work?
   ! Creates a self-pipe
   ! Installs a signal handler that writes to the pipe when SIGINT is received
   ! Spawns a thread: loop { read from pipe; call handler function; }
! The Rust borrow checker prevents data races caused by concurrent access/
  modification from threads. If your handler function touches data in a racey
  way, the compiler will complain
Why is this different?

! printf from signal handler can deadlock:
   ! printf from main body of code calls flock()
   ! signal handler interrupts execution. printf from signal handler calls flock()
   ! signal handler can’t continue until main code releases lock, but main code
        can’t continue until the signal handler exits
! printf from threads are safe:
   ! printf from main thread calls flock()
   ! printf from signal handling thread calls flock() and is blocked
   ! printf from main thread finishes
   ! printf from signal handling thread finishes
! malloc() calls (including the ones printf makes) work similarly.
Why is this different?

! Threads and signal handlers have the same concurrency problems
! But the scheduling of code is completely different
! Threads:
    ! Multiple (usually) equal-priority threads of execution that constantly swap on the
        processor
    ! Can use locks to protect data
! Signal handlers:
    ! Handler will completely preempt all other code and hog the CPU until it finishes
    ! Can’t use locks or any other synchronization primitives
          ! In fact, signal handlers should avoid all kinds of blocking! (Why?)
    ! Consequently, signal handlers play very poorly with library code. Libraries don’t know
        what signal handlers you have installed or what those signal handlers do, so they can’t
        disable signal handling to protect themselves from concurrency problems
Google Chrome
Processes

                   pid = 1000                             pid = 1001

                                         P
                      stack
                                    IGSTO                    stack
                                  S
                         heap                                   heap
                   data/globals                           data/globals
                         code
                                             pipe               code

                                              pipe
              file descriptor table:                 file descriptor table:

               1     2      3     …                   1     2      3     …
                saved registers:                       saved registers:

              %rax %rbx %rcx                         %rax %rbx %rcx
              %rdx %rsp         %rip                 %rdx %rsp         %rip


            Processes can synchronize using signals and pipes
Threads

                              pid = 1000              tid = 1001
                                                            stack
                                     stack
                                                       saved registers:

                                     heap             %rax %rbx %rcx
                                  data/globals
                                                      %rdx %rsp %rip
                                     code


                             file descriptor table:   tid = 1002
                                                            stack
                              1    2     3       …
                                                       saved registers:
                               saved registers:
                                                      %rax %rbx %rcx
                             %rax %rbx %rcx
                                                      %rdx %rsp %rip
                             %rdx %rsp %rip


  Threads are similar to processes; they have a separate stack and saved registers (and
  a handful of other separated things). But they share most resources across the process
Threads

                      pid = 1000                    tid = 1001
                             stack1

                             stack2

                              heap

                          data/globals

                              code


                      file descriptor table:       file descriptor table:


                       1 2 3 …                      1 2 3 …
                        saved registers:             saved registers:

                      %rax %rbx %rcx               %rax %rbx %rcx

                      %rdx %rsp %rip               %rdx %rsp %rip


    Under the hood, a thread gets its own “process control block” and is scheduled
    independently, but it is linked to the process that spawned it
Considerations when designing a browser

!   Speed
!   Memory usage
!   Battery/CPU usage
!   Ease of development
!   Security, stability
Considerations when designing a browser

! Speed
   ! Typically faster to share memory and to use lightweight synchronization primitives
! Memory usage
   ! Processes use more memory
! Battery/CPU usage
   ! Threads incur less context switching overhead
! Ease of development
   ! Communication is WAY easier using threads
   ! (That being said, bugs caused by multithreading are extremely hard to track
       down)
! Security, stability
   ! Multiprocessing provides isolation. Multithreading does not.
Modern browsers are essentially operating systems


            https://developer.mozilla.org/en-US/docs/Web/API
Modern browsers are essentially operating systems

!   Storage APIs
!   Concurrency APIs
!   Hardware APIs (e.g. communicate with MIDI devices, even GPU)
!   Run assembly
!   Run Windows 95: https://win95.ajf.me/
Motivation for Chrome

It's nearly impossible to build a rendering engine that never crashes or hangs. It's also nearly
impossible to build a rendering engine that is perfectly secure.
In some ways, the state of web browsers around 2006 was like that of the single-user, co-
operatively multi-tasked operating systems of the past. As a misbehaving application in such
an operating system could take down the entire system, so could a misbehaving web page in
a web browser. All it took is one browser or plug-in bug to bring down the entire browser and
all of the currently running tabs.
Modern operating systems are more robust because they put applications into separate
processes that are walled off from one another. A crash in one application generally does not
impair other applications or the integrity of the operating system, and each user's access to
other users' data is restricted.

              https://www.chromium.org/developers/design-documents/multi-process-architecture
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
     releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
     M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years of
     investment into developer education, fuzzing, Vulnerability Reward Programs, etc. Note that
     this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for
several reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
     releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
     M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years of
     investment into developer education, fuzzing, Vulnerability Reward Programs, etc. Note that
     this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future
     Chrome releases. There were 10 potentially exploitable bugs in renderer components in
     M69, 5 in M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite
     years of investment into developer education, fuzzing, Vulnerability Reward Programs, etc.
     Note that this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
     releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
     M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years
     of investment into developer education, fuzzing, Vulnerability Reward Programs,
     etc. Note that this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
     releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
     M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years of
     investment into developer education, fuzzing, Vulnerability Reward Programs, etc. Note that
     this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
      releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
      M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years of
      investment into developer education, fuzzing, Vulnerability Reward Programs, etc. Note that
      this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned
     into an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always effective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Motivation for Chrome

Compromised renderer processes (also known as "arbitrary code execution" attacks in the renderer
process) need to be explicitly included in a browser’s security threat model. We assume that
determined attackers will be able to find a way to compromise a renderer process, for several
reasons:
  • Past experience suggests that potentially exploitable bugs will be present in future Chrome
     releases. There were 10 potentially exploitable bugs in renderer components in M69, 5 in
     M70, 13 in M71, 13 in M72, 15 in M73. This volume of bugs holds steady despite years of
     investment into developer education, fuzzing, Vulnerability Reward Programs, etc. Note that
     this only includes bugs that are reported to us or are found by our team.
  • Security bugs can often be made exploitable: even 1-byte buffer overruns can be turned into
     an exploit.
  • Deployed mitigations (like ASLR or DEP) are not always eﬀective.

                     https://www.chromium.org/Home/chromium-security/site-isolation
Aside: What does Firefox’s architecture look like?
Chrome architecture


REALLY CUTE diagrams from https://developers.google.com/web/updates/2018/09/inside-browser-part1
                                         (great read!)
Chrome architecture


REALLY CUTE diagrams from https://developers.google.com/web/updates/2018/09/inside-browser-part1
                                         (great read!)
  Chrome architecture


IPC channels = pipes

Message passing model                                                      Sandboxed processes: no access
                                                                           to network, filesystem, etc
Events (e.g. click,
keystroke, etc) are                                                        If there is embedded content, may
relayed through                                                            use multiple threads to render that
these pipes! No                                                            content and manage
signals                                                                    communication between frames


   https://www.chromium.org/developers/design-documents/multi-process-architecture (slightly out of date)
Not good enough

! What does all this work buy us?
   ! Isolation between tabs
   ! Isolation between (potentially malicious) websites and the host
! What does it not buy us?
   ! Isolation between resources within a tab
Not good enough

                http://www.evil.com

                                      Welcome to Evil!


                                                         PIN: 1234


     Same-origin policy: www.evil.com can embed bank.com, but cannot interact with
                               bank.com or see its data
Not good enough

! Site Isolation Project (2015-2019) aimed to put resources for different origins in
  different processes
! Extremely difficult undertaking. Cross-frame communication is common (JS
  postMessage API), and embedded frames need to share render buffers
    ! Involved rearchitecting the most core parts of Chrome
! Became especially important in Jan 2018: Spectre and Meltdown
    ! When the hardware fails to uphold its guarantees, JS can read arbitrary
        process memory (even kernel memory, and even if your software has no
        bugs)!
! Paper/video: https://www.usenix.org/conference/usenixsecurity19/presentation/
  reis
Anatomy of a sandbox escape

! https://blog.chromium.org/2012/05/tale-of-two-pwnies-part-1.html (2012 but
  it’s more accessible than some other writeups)
    ! First exploit chains together six bugs to escape the sandbox
    ! Second one uses ten(!!)
! https://googleprojectzero.blogspot.com/2019/04/virtually-unlimited-memory-
  escaping.html (2019)
More relevant reading

! How Chrome does fork():
  http://neugierig.org/software/chromium/notes/2011/08/zygote.html
  Fun related bug report: https://bugs.chromium.org/p/chromium/issues/detail?id=35793
   What steps will reproduce the problem?
   1. Develop a webapp, use chrome's devtools, minding your own business
   2. In the meantime, let chrome silently autoupdate in the background

   What is the expected result?
   Devtools continue working

   What happens instead?
   Devtools break after refreshing the page after the autoupdate happened.
```

---

## Lecture 09: Intro to Multithreading
*Tuesday, May 5, 2020*

```
Intro to Multithreading

    Ryan Eberhardt and Armin Namavari
              May 5, 2020
Class logistics

! Fill out weekly survey by Wednesday night
! First project (mini GDB) is out
   ! You’ll be free to work with a partner!
   ! We’ll have some way for you to find someone to work with if you’d like
        (suggestions welcome)
   ! This is going to be a very systems-y project — you’ll be dealing with
        registers, assembly, multiprocessing etc. so get ready for that!
   ! It’s going to be like trace but even more fun :^)
! By this Sunday, aim to complete Milestone 4
You rock! 🧗

! Our journey so far
   ! Learned a new model for managing memory safety
   ! Met new, explicit types for the purposes of handling nulls and errors
   ! Worked with a new alternative to inheritance in object-oriented
       programming
   ! Implemented generic container types
   ! Used with heap-allocated memory and reference-counted pointers
   ! Battled a lot of compiler errors (and hopefully learned from them!)
   ! Learned about ways to safely use constructs such as fork, pipes, and
       signals
You rock! 🧗

! The journey ahead
   ! Next two weeks: how to do safe multithreading
   ! Week 7: asynchronous programming
   ! Week 8: robustness in networked services
   ! Week 9: looking back and looking around
   ! Week 10: case studies and guest lectures
Plan for Today

! Revisit discussion of Google Chrome
! Introduce multithreading in Rust
! If time permits: introduce locks/mutexes
Google Chrome
Considerations when designing a browser

! Speed
   ! Typically faster to share memory and to use lightweight synchronization primitives
! Memory usage
   ! Processes use more memory
! Battery/CPU usage
   ! Threads incur less context switching overhead
! Ease of development
   ! Communication is WAY easier using threads
   ! (That being said, bugs caused by multithreading are extremely hard to track
       down)
! Security, stability
   ! Multiprocessing provides isolation. Multithreading does not.
Modern browsers are essentially operating systems


            https://developer.mozilla.org/en-US/docs/Web/API
Modern browsers are essentially operating systems

!   Storage APIs
!   Concurrency APIs
!   Hardware APIs (e.g. communicate with MIDI devices, even GPU)
!   Run assembly
!   Run Windows 95: https://win95.ajf.me/
Motivation for Chrome

It's nearly impossible to build a rendering engine that never crashes or hangs. It's also nearly
impossible to build a rendering engine that is perfectly secure.
In some ways, the state of web browsers around 2006 was like that of the single-user, co-
operatively multi-tasked operating systems of the past. As a misbehaving application in such
an operating system could take down the entire system, so could a misbehaving web page in
a web browser. All it took is one browser or plug-in bug to bring down the entire browser and
all of the currently running tabs.
Modern operating systems are more robust because they put applications into separate
processes that are walled off from one another. A crash in one application generally does not
impair other applications or the integrity of the operating system, and each user's access to
other users' data is restricted.

              https://www.chromium.org/developers/design-documents/multi-process-architecture
Chrome architecture


REALLY CUTE diagrams from https://developers.google.com/web/updates/2018/09/inside-browser-part1
                                         (great read!)
Chrome architecture


REALLY CUTE diagrams from https://developers.google.com/web/updates/2018/09/inside-browser-part1
                                         (great read!)
  Chrome architecture


IPC channels = pipes

Message passing model                                                      Sandboxed processes: no access
                                                                           to network, filesystem, etc
Events (e.g. click,
keystroke, etc) are                                                        If there is embedded content, may
relayed through                                                            use multiple threads to render that
these pipes! No                                                            content and manage
signals                                                                    communication between frames


   https://www.chromium.org/developers/design-documents/multi-process-architecture (slightly out of date)
Not good enough

! What does all this work buy us?
   ! Isolation between tabs
   ! Isolation between (potentially malicious) websites and the host
! What does it not buy us?
   ! Isolation between resources within a tab
Not good enough

                http://www.evil.com

                                      Welcome to Evil!


                                                         PIN: 1234


     Same-origin policy: www.evil.com can embed bank.com, but cannot interact with
                               bank.com or see its data
Not good enough

! Site Isolation Project (2015-2019) aimed to put resources for different origins in
  different processes
! Extremely difficult undertaking. Cross-frame communication is common (JS
  postMessage API), and embedded frames need to share render buffers
    ! Involved rearchitecting the most core parts of Chrome
! Became especially important in Jan 2018: Spectre and Meltdown
    ! When the hardware fails to uphold its guarantees, JS can read arbitrary
        process memory (even kernel memory, and even if your software has no
        bugs)!
! Paper/video: https://www.usenix.org/conference/usenixsecurity19/presentation/
  reis
Anatomy of a sandbox escape

! https://blog.chromium.org/2012/05/tale-of-two-pwnies-part-1.html (2012 but
  it’s more accessible than some other writeups)
    ! First exploit chains together six bugs to escape the sandbox
    ! Second one uses ten(!!)
! https://googleprojectzero.blogspot.com/2019/04/virtually-unlimited-memory-
  escaping.html (2019)
More relevant reading

! How Chrome does fork():
  http://neugierig.org/software/chromium/notes/2011/08/zygote.html
  Fun related bug report: https://bugs.chromium.org/p/chromium/issues/detail?id=35793
   What steps will reproduce the problem?
   1. Develop a webapp, use chrome's devtools, minding your own business
   2. In the meantime, let chrome silently autoupdate in the background

   What is the expected result?
   Devtools continue working

   What happens instead?
   Devtools break after refreshing the page after the autoupdate happened.
Multithreading
Perils of concurrency

! Why is multithreading nice?
! Why is multithreading dangerous?
   ! Race conditions
   ! Deadlock (more on Thursday and next week)
Perils of concurrency


      https://hci.cs.siue.edu/NSF/Files/Semester/Week13-2/PPT-Text/Slide13.html
          https://hackaday.com/2015/10/26/killed-by-a-machine-the-therac-25/
Perils of concurrency


            http://radonc.wikidot.com/radiation-accident-therac25
 Perils of concurrency
After each overdose the creators of Therac-25 were contacted. After the first incident the AECL
responses was simple: “After careful consideration, we are of the opinion that this damage could
not have been produced by any malfunction of the Therac-25 or by any operator error (Leveson,
1993).”

After the 2nd incident the AECL sent a service technician to the Therac-25 machine, he was
unable to recreate the malfunction and therefore conclude nothing was wrong with the software.
Some minor adjustments to the hardware were changed but the main problems still remained.

It was not until the fifth incident that any formal action was taken by the AECL. However it was a
physicist at the hospital where the 4th and 5th incident took place in Tyler, Texas who actually was
able to reproduce the mysterious "malfunction 54". The AECL finally took action and made a
variety of changes in the software of the Therac-25 radiation treatment system.

       http://radonc.wdfiles.com/local--files/radiation-accident-therac25/Therac_UGuelph_TGall.pdf
Investigation results:
• The failure occurred only when a particular nonstandard sequence of keystrokes was entered on
   the VT-100 terminal which controlled the PDP-11 computer: an "X" to (erroneously) select 25 MeV photon
   mode followed by "cursor up", "E" to (correctly) select 25 MeV Electron mode, then "Enter", all within eight
   seconds.
• The design did not have any hardware interlocks to prevent the electron-beam from operating in its high-
   energy mode without the target in place.
• The engineer had reused software from older models. These models had hardware interlocks that masked
   their software defects.
• The hardware provided no way for the software to verify that sensors were working correctly.
• The equipment control task did not properly synchronize with the operator interface task, so that
   race conditions occurred if the operator changed the setup too quickly. This was missed during testing,
   since it took some practice before operators were able to work quickly enough to trigger this failure mode.
• The software set a flag variable by incrementing it, rather than by setting it to a fixed non-zero value.
   Occasionally an arithmetic overflow occurred, causing the flag to return to zero and the software to bypass
   safety checks.


           https://en.wikipedia.org/wiki/Therac-25 and http://sunnyday.mit.edu/papers/therac.pdf
What are race conditions?

! Race condition:
  A race condition or race hazard is the condition of an electronics, software, or
  other system where the system's substantive behavior is dependent on the
  sequence or timing of other uncontrollable events. (Wikipedia)
! Data race:
  Multiple threads access a value, where at least one of them is writing
   ! This should sound familiar!
Rust’s design pays off

! Rust’s design goals:
    ! How do you do safe systems programming?
    ! How do you make concurrency painless?
    ! How do you make it fast?
! “Initially these [first two] problems seemed orthogonal, but to our amazement,
  the solution turned out to be identical: the same tools that make Rust safe
  also help you tackle concurrency head-on.” (Rust blog)
! Compiler enforces rules for safe concurrency. “Thread safety isn't just
  documentation; it's law.”
! There’s very little in the core language specific to threading! (Only two traits!)
Hello world!
use std::{thread, time};
use rand::Rng;

const NUM_THREADS: u32 = 20;

fn main() {                                Parameters for closure function (none, in this case)
    let mut threads = Vec::new();
    println!("Spawning {} threads...", NUM_THREADS);
    for _ in 0..NUM_THREADS {                             Closure/lambda function borrows
        threads.push(thread::spawn(|| {                   any referenced variables
             let mut rng = rand::thread_rng();
             thread::sleep(time::Duration::from_millis(rng.gen_range(0, 5000)));
             println!("Thread finished running!");
        }));                             A panic in a thread will not crash the entire program
    }
    // wait for all the threads to finishNeed to check if the thread panicked
    for handle in threads {
        handle.join().expect("Panic happened inside of a thread!");
    }
    println!("All threads finished!");
}
                                         Playground
Extroverts demo (CS 110)
 static const char *kExtroverts[] = {
    "Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
    "Tagalong Introvert Jerry"
 };
 static const size_t kNumExtroverts = sizeof(kExtroverts)/sizeof(kExtroverts[0]) - 1;

 static void *recharge(void *args) {
   const char *name = kExtroverts[*(size_t *)args];
   printf("Hey, I'm %s. Empowered to meet you.\n", name);
   return NULL;
 }

 int main() {
   printf("Let's hear from %zu extroverts.\n", kNumExtroverts);
   pthread_t extroverts[kNumExtroverts];
   for (size_t i = 0; i < kNumExtroverts; i++)           Passes a pointer to i, but then the
     pthread_create(&extroverts[i], NULL, recharge, &i); main thread changes i on the
   for (size_t j = 0; j < kNumExtroverts; j++)
     pthread_join(extroverts[j], NULL);                  next iteration of the for loop
   printf("Everyone's recharged!\n");
   return 0;
 }                                    Cplayground
Can we do the same in Rust?

  use std::thread;

  const NAMES: [&str; 7] = ["Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
      "Tagalong Introvert Jerry"];

  fn main() {
      let mut threads = Vec::new();
      for i in 0..6 {
          threads.push(thread::spawn(|| {
               println!("Hello from printer {}!", NAMES[i]);
          }));
      }
      // wait for all the threads to finish
      for handle in threads {
          handle.join().expect("Panic occurred in thread!");
      }
  }


                                  Rust playground
   Can we do the same in Rust?
error[E0373]: closure may outlive the current function, but it borrows `i`, which is owned by the
current function
  --> src/main.rs:9:36
   |
9 |          threads.push(thread::spawn(|| {
   |                                     ^^ may outlive borrowed value `i`
10 |              println!("Hello from printer {}!", NAMES[i]);
   |                                                       - `i` is borrowed here
   |
note: function requires argument type to outlive `'static`
  --> src/main.rs:9:22
   |
9 |            threads.push(thread::spawn(|| {
   | ______________________^
10 | |              println!("Hello from printer {}!", NAMES[i]);
11 | |         }));
   | |__________^
help: to force the closure to take ownership of `i` (and any other referenced variables), use the
`move` keyword
   |
9 |          threads.push(thread::spawn(move || {
   |                                     ^^^^^^^
   Can we do the same in Rust?
error[E0373]: closure may outlive the current function, but it borrows `i`, which is owned by the
current function
  --> src/main.rs:9:36
   |
9 |          threads.push(thread::spawn(|| {
   |                                     ^^ may outlive borrowed value `i`
10 |              println!("Hello from printer {}!", NAMES[i]);
   |                                                       - `i` is borrowed here
   |
note: function requires argument type to outlive `'static`
  --> src/main.rs:9:22
   |
9 |            threads.push(thread::spawn(|| {
   | ______________________^
10 | |              println!("Hello from printer {}!", NAMES[i]);
11 | |         }));
   | |__________^
help: to force the closure to take ownership of `i` (and any other referenced variables), use the
`move` keyword
   |
9 |          threads.push(thread::spawn(move || {
   |                                     ^^^^^^^
Can we do the same in Rust?

  use std::thread;

  const NAMES: [&str; 7] = ["Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
      "Tagalong Introvert Jerry"];
                                                Closure function takes ownership of i
  fn main() {
      let mut threads = Vec::new();              (under the hood, value of i is copied
      for i in 0..6 {                            into thread’s stack)
          threads.push(thread::spawn(move || {
               println!("Hello from printer {}!", NAMES[i]);
          }));
      }
      // wait for all the threads to finish
      for handle in threads {
          handle.join().expect("Panic occurred in thread!");
      }
  }


                                  Rust playground
 Ticket agents demo (CS 110)
static void ticketAgent(size_t id, size_t& remainingTickets) { Multiple threads get mutable
    while (remainingTickets > 0) {                             reference to remainingTickets
        handleCall(); // sleep for a small amount of time to emulate conversation time.
        remainingTickets--;   Value decremented simultaneously: ends up underflowing!
        cout << oslock << "Agent #" << id << " sold a ticket! (" << remainingTickets
             << " more to be sold)." << endl << osunlock;
        if (shouldTakeBreak()) // flip a biased coin
            takeBreak();         // if comes up heads, sleep for a random time to take a break
    }
    cout << oslock << "Agent #" << id << " notices all tickets are sold, and goes home!"
         << endl << osunlock;
}

int main(int argc, const char *argv[]) {
    thread agents[10];
    size_t remainingTickets = 250;
    for (size_t i = 0; i < 10; i++)
        agents[i] = thread(ticketAgent, 101 + i, ref(remainingTickets));
    for (thread& agent: agents) agent.join();
    cout << "End of Business Day!" << endl;
    return 0;
}                                         Cplayground
Can we do the same in Rust?


   fn ticketAgent(id: usize, remainingTickets: &mut usize) {
       while *remainingTickets > 0 {
           handleCall();
           *remainingTickets -= 1;
           println!("Agent #{} sold a ticket! ({} more to be sold)",
               id, remainingTickets);
           if shouldTakeBreak() {
               takeBreak();
           }
       }
       println!("Agent #{} notices all tickets are sold, and goes home!", id);
   }


                                 Rust playground
Can we do the same in Rust?

       fn main() {
           let mut remainingTickets = 250;

           let mut threads = Vec::new();
           for i in 0..10 {
               threads.push(thread::spawn(|| {
                    ticketAgent(i, &mut remainingTickets)
               }));
           }
           // wait for all the threads to finish
           for handle in threads {
               handle.join().expect("Panic occurred in thread!");
           }
           println!("End of business day!");
       }


                             Rust playground
   Can we do the same in Rust?
error[E0499]: cannot borrow `remainingTickets` as mutable more than once at a time
  --> src/main.rs:38:36
   |
38 |           threads.push(thread::spawn(|| {
   |                         -             ^^ mutable borrow starts here in previous iteration of
loop
   | ______________________|
   | |
39 | |              ticketAgent(i, &mut remainingTickets)
   | |                                  ---------------- borrows occur due to use of
`remainingTickets` in closure
40 | |         }));
   | |__________- argument requires that `remainingTickets` is borrowed for `'static`

error[E0373]: closure may outlive the current function, but it borrows `i`, which is owned by the
current function
...

error[E0373]: closure may outlive the current function, but it borrows `remainingTickets`, which
is owned by the current function
...
```

---

## Lecture 10: Shared Memory
*Thursday, May 7, 2020*

```
Multithreading in Rust:
     Shared Data

    Ryan Eberhardt and Armin Namavari
              May 7, 2020
Extroverts demo (CS 110)
 static const char *kExtroverts[] = {
    "Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
    "Tagalong Introvert Jerry"
 };
 static const size_t kNumExtroverts = sizeof(kExtroverts)/sizeof(kExtroverts[0]) - 1;

 static void *recharge(void *args) {
   const char *name = kExtroverts[*(size_t *)args];
   printf("Hey, I'm %s. Empowered to meet you.\n", name);
   return NULL;
 }

 int main() {
   printf("Let's hear from %zu extroverts.\n", kNumExtroverts);
   pthread_t extroverts[kNumExtroverts];
   for (size_t i = 0; i < kNumExtroverts; i++)           Passes a pointer to i, but then the
     pthread_create(&extroverts[i], NULL, recharge, &i); main thread changes i on the
   for (size_t j = 0; j < kNumExtroverts; j++)
     pthread_join(extroverts[j], NULL);                  next iteration of the for loop
   printf("Everyone's recharged!\n");
   return 0;
 }                                    Cplayground
Can we do the same in Rust?

  use std::thread;

  const NAMES: [&str; 7] = ["Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
      "Tagalong Introvert Jerry"];

  fn main() {
      let mut threads = Vec::new();
      for i in 0..6 {
          threads.push(thread::spawn(|| {
               println!("Hello from printer {}!", NAMES[i]);
          }));
      }
      // wait for all the threads to finish
      for handle in threads {
          handle.join().expect("Panic occurred in thread!");
      }
  }


                                  Rust playground
   Can we do the same in Rust?
error[E0373]: closure may outlive the current function, but it borrows `i`, which is owned by the
current function
  --> src/main.rs:9:36
   |
9 |          threads.push(thread::spawn(|| {
   |                                     ^^ may outlive borrowed value `i`
10 |              println!("Hello from printer {}!", NAMES[i]);
   |                                                       - `i` is borrowed here
   |
note: function requires argument type to outlive `'static`
  --> src/main.rs:9:22
   |
9 |            threads.push(thread::spawn(|| {
   | ______________________^
10 | |              println!("Hello from printer {}!", NAMES[i]);
11 | |         }));
   | |__________^
help: to force the closure to take ownership of `i` (and any other referenced variables), use the
`move` keyword
   |
9 |          threads.push(thread::spawn(move || {
   |                                     ^^^^^^^
   Can we do the same in Rust?
error[E0373]: closure may outlive the current function, but it borrows `i`, which is owned by the
current function
  --> src/main.rs:9:36
   |
9 |          threads.push(thread::spawn(|| {
   |                                     ^^ may outlive borrowed value `i`
10 |              println!("Hello from printer {}!", NAMES[i]);
   |                                                       - `i` is borrowed here
   |
note: function requires argument type to outlive `'static`
  --> src/main.rs:9:22
   |
9 |            threads.push(thread::spawn(|| {
   | ______________________^
10 | |              println!("Hello from printer {}!", NAMES[i]);
11 | |         }));
   | |__________^
help: to force the closure to take ownership of `i` (and any other referenced variables), use the
`move` keyword
   |
9 |          threads.push(thread::spawn(move || {
   |                                     ^^^^^^^
Can we do the same in Rust?

  use std::thread;

  const NAMES: [&str; 7] = ["Frank", "Jon", "Lauren", "Marco", "Julie", "Patty",
      "Tagalong Introvert Jerry"];
                                                Closure function takes ownership of i
  fn main() {
      let mut threads = Vec::new();              (under the hood, value of i is copied
      for i in 0..6 {                            into thread’s stack)
          threads.push(thread::spawn(move || {
               println!("Hello from printer {}!", NAMES[i]);
          }));
      }
      // wait for all the threads to finish
      for handle in threads {
          handle.join().expect("Panic occurred in thread!");
      }
  }


                                  Rust playground
 Ticket agents demo (CS 110)
static void ticketAgent(size_t id, size_t& remainingTickets) { Multiple threads get mutable
    while (remainingTickets > 0) {                             reference to remainingTickets
        handleCall(); // sleep for a small amount of time to emulate conversation time.
        remainingTickets--;   Value decremented simultaneously: ends up underflowing!
        cout << oslock << "Agent #" << id << " sold a ticket! (" << remainingTickets
             << " more to be sold)." << endl << osunlock;
        if (shouldTakeBreak()) // flip a biased coin
            takeBreak();         // if comes up heads, sleep for a random time to take a break
    }
    cout << oslock << "Agent #" << id << " notices all tickets are sold, and goes home!"
         << endl << osunlock;
}

int main(int argc, const char *argv[]) {
    thread agents[10];
    size_t remainingTickets = 250;
    for (size_t i = 0; i < 10; i++)
        agents[i] = thread(ticketAgent, 101 + i, ref(remainingTickets));
    for (thread& agent: agents) agent.join();
    cout << "End of Business Day!" << endl;
    return 0;
}                                         Cplayground
Attempt 1: Just Pass it in :^)
fn main() {
    let mut remainingTickets = 250;

    let mut threads = Vec::new();
    for i in 0..10 {
        threads.push(thread::spawn(|| {
             ticketAgent(i, &mut remainingTickets)
        }));
    }
    // wait for all the threads to finish
    for handle in threads {
        handle.join().expect("Panic occurred in thread!");
    }
    println!("End of business day!");
}

Rust playground
Attempt 2: RefCell and Rc

! Oh right, we need to move the value in
! Let’s just use RefCell and Rc
! Let's see how the Rust compiler feels about it
Attempt 3: Mutex and Arc

! We need to have memory that we can safely share between threads
! You can think of “Arc” as a thread safe version of the Rc safe pointer
! You can think of “Mutex” as a thread safe version of RefCell that allows
  exclusive access to the piece of data it wraps.
! Association between the lock and the data it protects!
! Deadlock danger: although the lock is released once the value returned by
  “.lock()” is dropped, you can still create situations with deadlock.
! Finished Example
Send and Sync

! Marker traits — you don’t implement functions for them, they serve a symbolic
  purpose
! Send: Transfer ownership (move) between threads
   ! Rc can’t be Send: what if you clone() an Rc (so there are two handles to the
      underlying object + reference count), give one of those handles to a different
      thread, and the two threads update the reference count at the same time?
   ! Arc implements the Send trait since the refcount update happens atomically.
      So does Mutex
! Sync: Allow this thing to be referenced from multiple threads
   ! Mutex and Arc both implement Sync.
! Read more here
Link Explorer

! You and your friends are bored so
  you decided to play a game where
  you go to a random Wikipedia page
  and try to find a link to another
  wikipedia page that is the longest (by
  length of the html)
    ! Trust me, it’s fun!
! You decide to enlist Rust (along with
  the reqwest and select crates) to
  help you.
Sequential Link Explorer

!   The most straightforward approach
!   No threads => no race conditions :^)
!   Let’s see how fast it is…
!   (code)
Multithreaded Link Explorer

! The web requests are network bound, so we can easily overlap the wait
  times for these requests by running them in separate threads.
! You can see this runs considerably faster!
! Problems
    ! We have this funky batching thing going on — it’s not super flexible and
      generalizable (what if we want to dynamically handle requests?)
    ! We can easily reuse threads (really, we should be using a threadpool
      which you will implement in assignment 6 of CS110)


     Sequential                                                Multithreaded
Next time

! Other synchronization primitives
! Beyond shared memory
```

---

## Lecture 11: Synchronization
*Tuesday, May 12, 2020*

```
Multithreading in Rust:
  Synchronization

    Ryan Eberhardt and Armin Namavari
              May 12, 2020
Link Explorer

! You and your friends are bored so
  you decided to play a game where
  you go to a random Wikipedia page
  and try to find a link to another
  wikipedia page that is the longest (by
  length of the html)
    ! Trust me, it’s fun!
! You decide to enlist Rust (along with
  the reqwest and select crates) to
  help you.
Sequential Link Explorer

!   The most straightforward approach
!   No threads => no race conditions :^)
!   Let’s see how fast it is…
!   (code)
Multithreaded Link Explorer

! The web requests are network bound, so we can easily overlap the wait
  times for these requests by running them in separate threads.
! You can see this runs considerably faster!
! Problems
    ! We have this funky batching thing going on — What’s wrong with it?
    ! We can easily reuse threads (really, we should be using a threadpool
      which you will implement in assignment 6 of CS110)


     Sequential                                              Multithreaded
Can we do better than batching…?

! First of all, why did we need batching?
   ! What happens if I just make the batch size really big…
! What’s a more effective way to limit the number of active threads/outgoing
  connections?
   ! You saw in CS110 lecture that we can use condition variables and
        semaphores to impose a limit on the number of “permission slips”
   ! You will see this again in Assignment 5 (News Aggregator) — as an
        exercise, you may wish to upgrade the link explorer example to impose
        limits in this way!
Condition Variables in C++
Condition Variables in Rust

! Idiomatic to associate a condition variable with a mutex by putting them in a
  pair together and wrapping that pair in an Arc.
! We clone this pair before we move it into a thread.
    ! Recall: we are NOT cloning the mutex, but rather a (reference-counted)
       pointer to it!
! You pass in the return value of mutex.lock().unwrap() to cv.wait(…) (or
  cv.wait_while(…))
! The Mutex<T> and Condvar interfaces in Rust enable us to write shorter,
  safer, and more legible code.
! We’ll see this in today’s live-coding example.
SemaPlusPlus

! Semaphores can mediate access to a limited resource through giving out a
  limited number of “permission slips.” They can also synchronize threads to
  wait until a piece of data is ready (see producer/consumer) — we’ll focus on
  this second use case in the following example.
! But they only let you increment and decrement — let’s do something more
  interesting.
! Instead of just sema.signal — let’s do sema.send (msg)
! Instead of just sema.wait — lets’ do sema.recv() (which returns a msg that
  was previously sent)
! Why might we want an abstraction like this?
SemaPlusPlus
SemaPlusPlus Implementation

! Starter code
! Finished Example
```

---

## Lecture 12: Channels
*Thursday, May 14, 2020*

```
Channels

Ryan Eberhardt and Armin Namavari
          May 14, 2020
Logistics

!   Congrats on making it through week 6!
!   Week 5 exercises due Saturday
!   Project 1 due Tuesday
!   Let us know if you have questions! We have OH after class
Reconsidering multithreading
Characteristics of multithreading

! Why do we like multithreading?
  ! It’s fast (lower context switching overhead than multiprocessing)
  ! It’s easy (sharing data is straightforward when you share memory)
! Why do we not like multithreading?
  ! It’s easy to mess up: data races
Radical proposition

! What if we didn’t share memory?
  ○ Could we come up with a way to do multithreading that is just as fast and
       just as easy?
! If threads don’t share memory, how are they supposed to work together when
  data is involved?
! Golang concurrency slogan: “Do not communicate by sharing memory;
  instead, share memory by communicating.” (Effective Go)
! Message passing: Independent threads/processes collaborate by exchanging
  messages with each other
  ○ Can’t have data races because there is no shared memory
Communicating Sequential Processes

! Theoretical model introduced in 1978: sequential processes communicate via
  by sending messages over “channels”
  ○ Sequential processes: easy peasy
  ○ No shared state -> no data races!
! Serves as the basis for newer systems languages such as Go and Erlang
! Also served as an early model for Rust!
  ○ Channels used to be the only communication/synchronization primitive
! Channels are available in other languages as well (e.g. Boost includes an
  implementation for C++)
Channels: like semaphores
Semaphores


                       thread1


                                 SomeStruct {
   Mutex: Unlocked   Buffer:       …
                                 }
Semaphores
                semaphore.wait()


                        thread1


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
                semaphore.wait()


                        thread1


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
                semaphore.wait()


                        thread1


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
                     mutex.lock()


                         thread1


                                   SomeStruct {
   Mutex: Unlocked     Buffer:       …
                                   }
Semaphores
                   mutex.lock()


                       thread1


                                 SomeStruct {
   Mutex: Locked     Buffer:       …
                                 }
Semaphores


    SomeStruct {
      …
    }


                     thread1


   Mutex: Locked   Buffer:
Semaphores
                   mutex.unlock()


    SomeStruct {
      …
    }


                         thread1


   Mutex: Locked       Buffer:
Semaphores
                     mutex.unlock()


    SomeStruct {
      …
    }


                           thread1


   Mutex: Unlocked       Buffer:
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
    }


                        thread1


   Mutex: Unlocked    Buffer:
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
    }


                     thread1 (blocked)


   Mutex: Unlocked    Buffer:
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
                                                   SomeStruct {
    }
                                                     …
                                                   }


                     thread1 (blocked)   thread2


   Mutex: Unlocked    Buffer:
Semaphores
        semaphore.wait() (again)         mutex.lock()


    SomeStruct {
      …
                                                        SomeStruct {
    }
                                                          …
                                                        }


                     thread1 (blocked)   thread2


   Mutex: Unlocked    Buffer:
Semaphores
        semaphore.wait() (again)         mutex.lock()


    SomeStruct {
      …
                                                        SomeStruct {
    }
                                                          …
                                                        }


                     thread1 (blocked)   thread2


   Mutex: Locked      Buffer:
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
    }


                     thread1 (blocked)           thread2


                                  SomeStruct {
   Mutex: Locked      Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)                 mutex.unlock()


    SomeStruct {
      …
    }


                     thread1 (blocked)           thread2


                                  SomeStruct {
   Mutex: Locked      Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)                 mutex.unlock()


    SomeStruct {
      …
    }


                     thread1 (blocked)           thread2


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)                 semaphore.signal()


    SomeStruct {
      …
    }


                     thread1 (blocked)           thread2


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)                 semaphore.signal()


    SomeStruct {
      …
    }


                     thread1 (blocked)           thread2


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
    }


                        thread1                  thread2


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
        semaphore.wait() (again)


    SomeStruct {
      …
    }


                        thread1                  thread2


                                  SomeStruct {
   Mutex: Unlocked    Buffer:       …
                                  }
Semaphores
                     mutex.lock()


    SomeStruct {
      …
    }


                         thread1                  thread2


                                   SomeStruct {
   Mutex: Unlocked     Buffer:       …
                                   }
Semaphores
                   mutex.lock()


    SomeStruct {
      …
    }


                       thread1                  thread2


                                 SomeStruct {
   Mutex: Locked     Buffer:       …
                                 }
Semaphores


    SomeStruct {
      …
    }


    SomeStruct {
      …
    }


                     thread1   thread2


   Mutex: Locked   Buffer:
Semaphores
                   mutex.unlock()


    SomeStruct {
      …
    }


    SomeStruct {
      …
    }


                         thread1    thread2


   Mutex: Locked       Buffer:
Semaphores
                     mutex.unlock()


    SomeStruct {
      …
    }


    SomeStruct {
      …
    }


                           thread1    thread2


   Mutex: Unlocked       Buffer:
Channels


                     SomeStruct {
                       …
                     }


           thread1
 Channels

let struct = receive_end.recv().unwrap()


                                           SomeStruct {
                                             …
                                           }


                               thread1
 Channels

let struct = receive_end.recv().unwrap()


                                           SomeStruct {
                                             …
                                           }


                               thread1
 Channels

let struct = receive_end.recv().unwrap()


                                     SomeStruct {
                                       …
                                     }


                               thread1
 Channels

let struct2 = receive_end.recv().unwrap() (again)


                                     SomeStruct {
                                       …
                                     }


                               thread1
 Channels

let struct2 = receive_end.recv().unwrap() (again)


                      SomeStruct {
                        …
                      }

                              thread1 (blocked)
 Channels

let struct2 = receive_end.recv().unwrap() (again)


                      SomeStruct {
                        …
                      }

                              thread1 (blocked)     thread2
 Channels

let struct2 = receive_end.recv().unwrap() (again)                  send_end.send(struct).unwrap()


                                                    SomeStruct {
                                                      …
                                                    }


                      SomeStruct {
                        …
                      }

                              thread1 (blocked)            thread2
 Channels

let struct2 = receive_end.recv().unwrap() (again)                    send_end.send(struct).unwrap()


                                                  SomeStruct {
                                                    …
                      SomeStruct {                }
                        …
                      }

                              thread1 (blocked)                  thread2
 Channels

let struct2 = receive_end.recv().unwrap() (again)


                                               SomeStruct {
                                                 …
                      SomeStruct {             }
                        …
                      }

                                     thread1                  thread2
 Channels

let struct2 = receive_end.recv().unwrap() (again)


                                           SomeStruct {
                                             …
                                           }


                      SomeStruct {
                        …
                      }

                                     thread1              thread2
Channels: like strongly-typed pipes
 Chrome architecture diagram


 Inter-Process Communication channels:
      Pipes, but with an extra layer of
abstraction to serialize/deserialize objects


               https://www.chromium.org/developers/design-documents/multi-process-architecture (slightly out of date)
Using channels
Isn’t message passing bad for performance?

! If you don’t share memory, then you need to copy data into/out of messages.
  That seems expensive. What gives?
! Theory != practice
  ○ We share some memory (the heap) and only make shallow copies into
      channels
Partly-shared memory (shallow copies only)


                                                  Vec {
                                                    len: 6,
                                                    alloc_len: 16,
                                                    data: Box<>,
                                                  }


                   thread1                                       thread2


            Heap
                             [3, 4, 5, 6, 7, 8]
Partly-shared memory (shallow copies only)


                             Vec {
                               len: 6,
                               alloc_len: 16,
                               data: Box<>,
                             }


                   thread1                        thread2


            Heap
                             [3, 4, 5, 6, 7, 8]
Partly-shared memory (shallow copies only)


                             Vec {
                               len: 6,
                               alloc_len: 16,
                               data: Box<>,
                             }


                   thread1                        thread2


            Heap
                             [3, 4, 5, 6, 7, 8]
Partly-shared memory (shallow copies only)


                             Vec {
                               len: 6,
                               alloc_len: 16,
                               data: Box<>,
                             }


                   thread1                        thread2


            Heap
                             [3, 4, 5, 6, 7, 8]
Partly-shared memory (shallow copies only)


                         Vec {
                           len: 6,
                           alloc_len: 16,
                           data: Box<>,
                         }


                   thread1                                  thread2


            Heap
                                       [3, 4, 5, 6, 7, 8]
Isn’t message passing bad for performance?

! If you don’t share memory, then you need to copy data into/out of messages. That
  seems expensive. What gives?
! Theory != practice
   ○ We share some memory (the heap) and only make shallow copies into channels
! In Go, passing pointers is potentially dangerous! Channels make data races less
  likely but don’t preclude races if you use them wrong
! In Rust, passing pointers (e.g. Box) is always safe despite sharing memory
   ○ When you send to a channel, ownership of value is transferred to the channel
   ○ The compiler will ensure you don’t use a pointer after it has been moved into
       the channel
Channel APIs and implementations

! The ideal channel is an MPMC (multi-producer, multi-consumer) channel
  ○ We implemented one of these on Tuesday! A simple Mutex<VecDeque<>>
       with a CondVar
  ○ However, that approach is much slower than we’d like. (Why?)
! It’s really, really hard to implement a fast and safe MPMC channel!
  ○ Go’s channels are known for being slow
       ■ They essentially implement Mutex<VecDeque<>>, but using a “fast
          userspace mutex” (futex)
  ○ A fast implementation needs to use lock-free programming techniques to
       avoid lock contention and reduce latency
Channel APIs and implementations

! The Rust standard library includes an MPSC (multi-producer, single-
  consumer) channel, but it’s not ideal (one of the oldest APIs in Rust stdlib)
  ○ Great if you want multiple threads to send to one thread (e.g. aggregating
     results of an operation)
  ○ Also great for thread-to-thread communication (superset of SPSC)
  ○ Not so great if you want to distribute data/work (e.g. a work queue)
  ○ Additionally, the API has some oddities (great article)
  ○ There’s a good chance this channel implementation will be replaced within
     the next year or two (discussion)
Channel APIs and implementations

! The crossbeam crate recently (2018) added an excellent MPMC
  implementation
  ○ “If we were to redo Rust channels from scratch, how should they look?”
     Much improved API
  ○ Mostly lock free
  ○ Even faster than the existing MPSC channels
  ○ Great read here
  ○ Likely to replace the stdlib channels in some capacity
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();


                                                                                 Heap
                                                                Thread 1 stack
                                                                                  channel {
                                                                 Sender             senders: 1,
                                                                                    receivers: 1,
                                                                 Receiver           …
                                                                                  }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {

                                                                                 Heap
                                                                Thread 1 stack
                                                                                  channel {
                                                                 Sender             senders: 1,
                                                                                    receivers: 1,
                                                                 Receiver           …
                                                                                  }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
                                                                                 Heap
                                                                Thread 1 stack
                                                                                  channel {
                                                                 Sender             senders: 1,
                                                                                    receivers: 1,
                                                                 Receiver           …
                                                                                  }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
                                                                Thread 1 stack   Heap
                                                                 Sender
                                                                                  channel {
                                                                                    senders: 1,
                                                                 Receiver           receivers: 1,
                                                                                    …
                                                                 Receiver         }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                     Thread 1 stack   Heap
                                                                 Sender
                                                                                  channel {
                                                                                    senders: 1,
                                                                 Receiver           receivers: 1,
                                                                                    …
                                                                 Receiver         }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                     Thread 1 stack   Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);                         Sender
                                                                                  channel {
            }
                                                                                    senders: 1,
       }));                                                      Receiver
   }
                                                                                    receivers: 1,
                                                                                    …
                                                                 Receiver         }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                     Thread 1 stack   Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);                         Sender
                                                                                  channel {
            }
                                                                                    senders: 1,
       }));                                                      Receiver
   }
                                                                                    receivers: 1,
                                                                                    …
                                                                 Receiver         }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {                                Thread 1 stack
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                      Sender          Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                 Receiver         channel {
            }
                                                                                    senders: 1,
       }));
   }
                                                                                    receivers: 2,
                                                                                    …
                                                                Thread 2 stack    }
                                                                 Receiver
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {                                         Thread 1 stack
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                               Sender          Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                          Receiver         channel {
            }
       }));
                             Read until recv() returns Err (i.e. until                       senders: 1,
   }                         the channel is closed)                                          receivers: 2,
                                                                                             …
                                                                         Thread 2 stack    }
                                                                          Receiver
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {                                Thread 1 stack
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                      Sender          Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                 Receiver         channel {
            }
                                                                                    senders: 1,
       }));
   }
                                                                                    receivers: 2,
                                                                                    …
                                                                Thread 2 stack    }
   let stdin = std::io::stdin();
   for line in stdin.lock().lines() {
                                                                 Receiver
       let num = line.unwrap().parse::<u32>().unwrap();
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {                                      Thread 1 stack
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                            Sender          Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                       Receiver         channel {
            }
                                                                                          senders: 1,
       }));
   }
                                                                                          receivers: 2,
                                                                                          …
                                                                      Thread 2 stack    }
   let stdin = std::io::stdin();
   for line in stdin.lock().lines() {
                                                                       Receiver
       let num = line.unwrap().parse::<u32>().unwrap();
       sender
           .send(num)
           .expect("Tried writing to channel, but there are no receivers!");
   }
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {                                      Thread 1 stack
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                            Sender          Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                       Receiver         channel {
            }
                                                                                          senders: 1,
       }));
   }
                                                                                          receivers: 2,
                                                                                          …
                                                                      Thread 2 stack    }
   let stdin = std::io::stdin();
   for line in stdin.lock().lines() {
                                                                       Receiver
       let num = line.unwrap().parse::<u32>().unwrap();
       sender
           .send(num)
           .expect("Tried writing to channel, but there are no receivers!");
   }

   drop(sender);
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
                                                                      Thread 1 stack
       threads.push(thread::spawn(move || {                                            Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                       Receiver
                                                                                        channel {
            }
                                                                                          senders: 0,
       }));
   }
                                                                                          receivers: 2,
                                                                      Thread 2 stack      …
                                                                                        }
   let stdin = std::io::stdin();                                       Receiver
   for line in stdin.lock().lines() {
       let num = line.unwrap().parse::<u32>().unwrap();
       sender
           .send(num)
           .expect("Tried writing to channel, but there are no receivers!");
   }

   drop(sender);
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
                                                                      Thread 1 stack
       threads.push(thread::spawn(move || {                                                      Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                       Receiver
                                                                                                   channel {
            }
                                                                                                     senders: 0,
       }));
   }
                                                                                                     receivers: 2,
                                                                      Thread 2 stack                 …
                                                                                                   }
   let stdin = std::io::stdin();                                       Receiver
   for line in stdin.lock().lines() {
       let num = line.unwrap().parse::<u32>().unwrap();
       sender
           .send(num)                                                                Channel is closed! Worker
           .expect("Tried writing to channel, but there are no receivers!");       threads will break out of while
   }
                                                                                                 loop
   drop(sender);
  Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

   let mut threads = Vec::new();
   for _ in 0..num_cpus::get() {
       let receiver = receiver.clone();
       threads.push(thread::spawn(move || {                                           Heap
            while let Ok(next_num) = receiver.recv() {
                factor_number(next_num);
                                                                     Thread 1 stack    channel {
            }
                                                                                         senders: 0,
       }));                                                           Receiver
   }
                                                                                         receivers: 1,
                                                                                         …
   let stdin = std::io::stdin();                                                       }
   for line in stdin.lock().lines() {
       let num = line.unwrap().parse::<u32>().unwrap();
       sender
           .send(num)
           .expect("Tried writing to channel, but there are no receivers!");
   }

   drop(sender);
    Implementing farm v3.0
fn main() {
    let (sender, receiver) = crossbeam::channel::unbounded();

    let mut threads = Vec::new();
    for _ in 0..num_cpus::get() {
        let receiver = receiver.clone();
        threads.push(thread::spawn(move || {                                           Heap
             while let Ok(next_num) = receiver.recv() {
                 factor_number(next_num);
                                                                      Thread 1 stack    channel {
             }
                                                                                          senders: 0,
        }));                                                           Receiver
    }
                                                                                          receivers: 1,
                                                                                          …
    let stdin = std::io::stdin();                                                       }
    for line in stdin.lock().lines() {
        let num = line.unwrap().parse::<u32>().unwrap();
        sender
            .send(num)
            .expect("Tried writing to channel, but there are no receivers!");
    }

    drop(sender);

    for thread in threads {
        thread.join().expect("Panic occurred in thread");
    }
}
Pick the right tool for the job

! Using channels is often much simpler and safer than using mutexes + CVs
  ○ Even in Rust, mutexes can still cause problems if you lock/unlock at the
     wrong times
  ○ E.g. semaphore will break if you unlock after cv.wait() and then re-lock
     before decrementing the counter. You hold the lock while touching the
     counter, so the compiler doesn’t complain, but there is still a race
     condition
! However, channels aren’t always the best choice
  ○ Not very well suited for global values (e.g. caches or global counters)
```

---

## Lecture 13: Scalability and Availability
*Tuesday, May 19, 2020*

```
Scalability and
 Availability

 Ryan Eberhardt and Armin Namavari
           May 19, 2020
Logistics

!   Project 1 due tonight
!   Week 6 exercises coming out today
!   Project 2 coming out end of this week
!   Let us know how we can help!
This week

! Moving up a level of abstraction: Discussing safety in the context of systems
  design
! How do you keep big systems running?
! How do you keep information secure from attackers?
! This could be an entire class. We will just skim the surface and talk about the
  parts we feel are most important to understand
Networking in a Nutshell
IP addresses

! Every computer on a network has an “IP address” uniquely identifying it on the
  network
   ○ An IPv4 address is 4 bytes. Usually written as 4 numbers, 0-255, separated by
       periods (e.g 192.168.1.230)
! If you want to talk to a computer, you need to know its IP address
! How do you find the IP address? (Too hard to remember!)
   ○ Your computer is configured with the address of a DNS server (can be hardcoded)
   ○ When you want to reach “www.google.com,” ask the DNS server for the IP address
   ○ IP address of www.google.com:
       🍌 dig +noall +answer www.google.com
       www.google.com.                 204       IN        A         216.58.194.16
DNS resolution

                     Hi 8.8.8.8, what’s the IP address for www.google.com?


                          www.google.com is at 216.58.194.16!


   10.0.4.110                                                                     8.8.8.8


                Hi 216.58.194.16, can you give me the www.google.com home page?

                                         Here you go!


                                                                             216.58.194.16
Understanding port numbers
“Host” (computer) = apartment complex
“Host” (computer) = apartment complex
 “Host” (computer) = apartment complex
“IP address” = apartment complex address
                  “Host” (computer) = apartment complex
                 “IP address” = apartment complex address


171.67.215.200                          10.0.4.128
                  “Host” (computer) = apartment complex
                 “IP address” = apartment complex address
                    “Port number” = apartment number


171.67.215.200                          10.0.4.128
                        “Host” (computer) = apartment complex
                       “IP address” = apartment complex address
                          “Port number” = apartment number


171.67.215.200                                     10.0.4.128

 …   22      …    80     …     443    …              …   22     …       80       …   443   …


                             Want to go to http://web.stanford.edu?
                 Use DNS to find web.stanford.edu's IP address: 171.67.215.200
                                 Go to that apartment complex
                  Knock on the apartment that runs the HTTP service (port 80)
                       “Host” (computer) = apartment complex
                      “IP address” = apartment complex address
                         “Port number” = apartment number


171.67.215.200                                     10.0.4.128

 …   22      …   80     …     443    …              …    22     …      80       …   443   …


                             Want to SSH into myth.stanford.edu?
                 Use DNS to find myth.stanford.edu's IP address: 171.64.15.29
                                Go to that apartment complex
                  Knock on the apartment that runs the SSH service (port 22)
Starting a server
      Apartment complex = host


171.67.215.200

 …   22      …   80   …   443    …
           Apartment complex = host
Each host will have some processes running on it

     171.67.215.200

      …   22      …   80   …    443   …
Each host will have some processes running on it


                                 pid 1234

       FD table                                       …


       OF table       R/W                             …


       Vnode table    terminal                        …


     171.67.215.200

      …     22        …           80        …   443   …
                 “Binding” to a port:


                            pid 1234

  FD table                                       …


  OF table       R/W                             …


  Vnode table    terminal                        …


171.67.215.200

 …     22        …           80        …   443   …
                            “Binding” to a port:
Process “sets up shop” in an apartment. (Only one process per apartment)


                                           pid 1234

                 FD table                                       …


                 OF table       R/W                             …


                 Vnode table    terminal                        …


               171.67.215.200

                 …    22        …           80        …   443   …
                            “Binding” to a port:
Process “sets up shop” in an apartment. (Only one process per apartment)


                                           pid 1234

                 FD table                                       …


                 OF table       R/W                             …


                 Vnode table    terminal                        …


               171.67.215.200

                 …    22        …           80        …   443   …
                            “Binding” to a port:
Process “sets up shop” in an apartment. (Only one process per apartment)
          Process installs a “waiting list” outside the apartment


                                           pid 1234

                 FD table                                       …


                 OF table       R/W                             …


                 Vnode table    terminal                        …


               171.67.215.200

                 …    22        …           80        …   443   …
                            “Binding” to a port:
Process “sets up shop” in an apartment. (Only one process per apartment)
          Process installs a “waiting list” outside the apartment


                                           pid 1234

                 FD table                                       …


                 OF table       R/W                             …


                 Vnode table    terminal                        …


               171.67.215.200

                 …    22        …           80        …   443   …
                                      “Binding” to a port:
       Process “sets up shop” in an apartment. (Only one process per apartment)
                    Process installs a “waiting list” outside the apartment
Waiting list is attached to a file descriptor, so the process can see when someone arrives

                                                   pid 1234

                         FD table                                       …


                         OF table       R/W                             …


                         Vnode table    terminal                        …


                       171.67.215.200

                         …    22        …           80        …   443   …
                                      “Binding” to a port:
       Process “sets up shop” in an apartment. (Only one process per apartment)
                    Process installs a “waiting list” outside the apartment
Waiting list is attached to a file descriptor, so the process can see when someone arrives

                                                   pid 1234

                         FD table                                       …


                         OF table       R/W    R/W                      …


                         Vnode table    terminal   socket               …


                       171.67.215.200

                         …    22        …            80       …   443   …
                              “Binding” to a port:
                   Other processes can bind to other ports
(no two processes can bind to the same port — one application per apartment!)


                                              pid 1234

                    FD table                                       …


                    OF table       R/W    R/W                      …


                    Vnode table    terminal   socket               …


                  171.67.215.200

                   …     22        …            80       …   443   …
                                   “Binding” to a port:
                        Other processes can bind to other ports
     (no two processes can bind to the same port — one application per apartment!)

                         pid 1234                                                    pid 2345

FD table                                           …        FD table                            …


OF table      R/W    R/W                           …        OF table      R/W    R/W            …


Vnode table   terminal   socket                    …        Vnode table   terminal   socket     …


                                  171.67.215.200

                                    …    22        …   80   …      443      …
                                           “Binding” to a port:
                             A process can bind to multiple ports, if it desires


                         pid 1234                                                    pid 2345

FD table                                           …        FD table                            …


OF table      R/W    R/W                           …        OF table      R/W    R/W            …


Vnode table   terminal   socket                    …        Vnode table   terminal   socket     …


                                  171.67.215.200

                                    …    22        …   80   …      443      …
                                           “Binding” to a port:
                             A process can bind to multiple ports, if it desires


                         pid 1234                                                    pid 2345

FD table                                           …        FD table                                   …


OF table      R/W    R/W                           …        OF table      R/W    R/W    R/W            …


Vnode table   terminal   socket                    …        Vnode table   terminal   socket   socket   …


                                  171.67.215.200

                                    …    22        …   80   …      443      …
Connecting a client
Say we have a server bound on 171.67.215.200:80

                                  pid 1234

        FD table                                       …


        OF table       R/W    R/W                      …


        Vnode table    terminal   socket               …


      171.67.215.200


       …     22        …            80       …   443   …
                       On some other computer, we want to talk to that server

                            pid 1234                                            pid 1234

  FD table                                       …     FD table                                    …


  OF table       R/W    R/W                      …     OF table      R/W                           …


  Vnode table    terminal   socket               …     Vnode table   terminal                      …


171.67.215.200                                       10.0.4.110


 …     22        …            80       …   443   …
                                                                                              Garage/
                                                                                           outgoing ports
                        The “client” walks out to try to find 171.67.215.200:80

                            pid 1234                                             pid 1234

  FD table                                       …      FD table                                    …


  OF table       R/W    R/W                      …      OF table      R/W                           …


  Vnode table    terminal   socket               …      Vnode table   terminal                      …


171.67.215.200                                        10.0.4.110


 …     22        …            80       …   443   …
                                                                                               Garage/
                                                                                            outgoing ports
                                   If successful, it adds itself to the waiting list

                            pid 1234                                                      pid 1234

  FD table                                        …              FD table                                    …


  OF table       R/W    R/W                        …             OF table      R/W                           …


  Vnode table    terminal   socket                …              Vnode table   terminal                      …


171.67.215.200                                                 10.0.4.110


 …     22        …            80       …    443    …
                                                                                                        Garage/
                                                                                                     outgoing ports
                 The server sees the client through its waiting list file descriptor

                            pid 1234                                            pid 1234

  FD table                                       …     FD table                                    …


  OF table        R/W   R/W                      …     OF table      R/W                           …


  Vnode table    terminal   socket               …     Vnode table   terminal                      …


171.67.215.200                                       10.0.4.110


 …     22         …           80       …   443   …
                                                                                              Garage/
                                                                                           outgoing ports
             It takes the client off the waiting list and creates a new bidirectional
                     “socket” that it can use to talk directly with the client
                            pid 1234                                            pid 1234

  FD table                                       …     FD table                                    …


  OF table       R/W    R/W                      …     OF table      R/W                           …


  Vnode table    terminal   socket               …     Vnode table   terminal                      …


171.67.215.200                                       10.0.4.110


 …     22        …            80       …   443   …
                                                                                              Garage/
                                                                                           outgoing ports
             It takes the client off the waiting list and creates a new bidirectional
                     “socket” that it can use to talk directly with the client
                            pid 1234                                               pid 1234

  FD table                                          …     FD table                                    …


  OF table       R/W    R/W    R/W                  …     OF table      R/W                           …


  Vnode table    terminal   socket   socket         …     Vnode table   terminal                      …


171.67.215.200                                          10.0.4.110


 …     22        …            80       …      443   …
                                                                                                 Garage/
                                                                                              outgoing ports
             Successful in making a connection, the client also creates a new file
                           descriptor it can use to talk to the server
                            pid 1234                                               pid 1234

  FD table                                          …     FD table                                    …


  OF table       R/W    R/W    R/W                  …     OF table      R/W    R/W                    …


  Vnode table    terminal   socket   socket         …     Vnode table   terminal   socket             …


171.67.215.200                                          10.0.4.110


 …     22        …            80       …      443   …
                                                                                                 Garage/
                                                                                              outgoing ports
             If the client writes to its fd 3, it will be readable on the server’s fd 4

                            pid 1234                                               pid 1234
                                                                                          hello!
  FD table                                          …     FD table                                         …


  OF table       R/W    R/W    R/W                  …     OF table      R/W    R/W                         …


  Vnode table    terminal   socket   socket         …     Vnode table   terminal   socket                  …


171.67.215.200                                          10.0.4.110


 …     22        …            80       …      443   …
                                                                                                      Garage/
                                                                                                   outgoing ports
       Similarly, if the server writes to fd 4, it will be readable on the client’s fd 3

                            pid 1234                                                     pid 1234
                                              hi!
  FD table                                                …     FD table                                    …


  OF table       R/W    R/W    R/W                        …     OF table      R/W    R/W                    …


  Vnode table    terminal   socket   socket               …     Vnode table   terminal   socket             …


171.67.215.200                                                10.0.4.110


 …     22        …            80       …            443   …
                                                                                                       Garage/
                                                                                                    outgoing ports
Scalability and Availability
Properties of networked systems

! Scalability: How well can the system grow as demands increase over time?
  ○ An unscalable system will not be able to grow to meet demand no matter
     how much resources you throw at it
! Availability: How well is the system able to stay available and avoid
  downtime?
  ○ Becomes increasingly challenging as a system scales
  ○ If an server is available 99.99% of the time (down only 0.88 hours/year), a
     system not engineered for fault tolerance relying on 1,000 servers will be
     available 99.99% ^ 1000 = 90.48% of the time (down 834 hours/year)
! (There are many more properties we will not talk about today)
Simple server setup
                     10.0.4.110                   171.67.215.200

                      Client                         Server
                                    Internet


! Client looks up server’s IP address using DNS
! Client connects to server’s IP over the network
! Client and server each create a file descriptor for communication with each
  other
Simple server setup
                    10.0.4.110                    171.67.215.200

                     Client                          Server
                                    Internet


! Is it scalable?
! Individual computers aren’t scalable
  ○ Becomes exponentially more expensive as you try to upgrade performance
  ○ Much cheaper if we could use two machines with commodity performance
       than one machine with 2x performance
  ○ Internet traffic has grown far faster than hardware has increased in power.
       Hardware can’t keep up even if our wallets could
! Scale out, not up!
Simple server setup
                    10.0.4.110                  171.67.215.200

                     Client                        Server
                                   Internet


! Is it available?
! Hardly.
  ○ Server could get overloaded and run out of resources (memory, CPU time,
       file descriptors, etc)
  ○ Server could fail (system crashes, hardware fails, dog eats power cable,
       network outage, etc)
Distributed systems

! We want to distribute a system’s functionality over a large number of servers
  to achieve scalability and availability
! These servers talk to each other using networking to collaborate on whatever
  problem we are trying to solve
Scaling out


                 10.0.4.110                    171.67.215.200

                  Client                          Server
                                Internet


     How can we design our system to make use of multiple servers?
Scaling out


                                               171.67.215.200


                 10.0.4.110                       Server
                  Client
                                Internet
                                                  Server


     How can we design our system to make use of multiple servers?
Scaling out


                                              171.67.215.200


              10.0.4.110                         Server
               Client
                               Internet
                                                 Server


          Simply duplicating our current setup won’t work.
Scaling out

                                                 171.67.215.200

                                                 Logic/compute
                  10.0.4.110                     Persistent data
                                                    storage
                   Client
                                  Internet
                                                 Logic/compute

                                                 Persistent data
                                                    storage


              Simply duplicating our current setup won’t work.
    The duplicate servers would need to synchronize their data storage.
      This is a very hard problem that is already solved by databases!
Scaling out


                                      171.67.215.200

       10.0.4.110                                         172.16.12.50
                                     Logic/compute
                                                          Persistent data
        Client                                               storage
                       Internet
                                     Logic/compute
                                                        MySQL, Postgres,
                                                        Redis, MongoDB,
                                                               etc.


              Simply duplicating our current setup won’t work.
    The duplicate servers would need to synchronize their data storage.
      This is a very hard problem that is already solved by databases!
Scaling out


                                     171.67.215.200

        10.0.4.110                                       172.16.12.50
                                     Logic/compute
                                                         Persistent data
         Client                                             storage
                       Internet
                                     Logic/compute
                                                       MySQL, Postgres,
                                                       Redis, MongoDB,
                                                              etc.


 These database systems come with mechanisms to scale to multiple servers
                      for reliability and performance
Scaling out

                                                        Take CS 245, CS 244B!

                                171.67.215.200     172.16.12.50
                                                   Persistent data
  10.0.4.110                                          storage         172.16.12.50
                               Logic/compute
   Client                                                             Persistent data
                  Internet                         172.16.12.51          storage
                               Logic/compute
                                                   Persistent data
                                                      storage

                                                           MySQL, Postgres,
                                                           Redis, MongoDB,
                                                                  etc.

 These database systems come with mechanisms to scale to multiple servers
                      for reliability and performance
Scaling out


                                     171.67.215.200        172.16.12.50
                                                          Persistent data
  10.0.4.110                                                 storage         172.16.12.50
                                     Logic/compute
   Client                                                                    Persistent data
                     Internet                              172.16.12.51         storage
                                     Logic/compute
                                                          Persistent data
                                                             storage

                                                                  MySQL, Postgres,
                                                                  Redis, MongoDB,
                                                                         etc.


               Still have a problem: Multiple servers, but only one IP!
Scaling out


                                     171.67.215.200      172.16.12.50
                                                         Persistent data
  10.0.4.110                                                storage         172.16.12.50
                                     Logic/compute
   Client                                                                   Persistent data
                      Internet                           172.16.12.51          storage
                                     Logic/compute
                                                         Persistent data
                                                            storage

                                                                 MySQL, Postgres,
                                                                 Redis, MongoDB,
                                                                        etc.


               Load balancers: Distribute traffic across compute nodes
Scaling out

                         Public internet   Private datacenter network

                                                                        172.16.12.50
                                                        172.17.1.100
                                                                        Persistent data
  10.0.4.110                      171.67.215.200      Logic/compute        storage         172.16.12.50
                                     Load                                                  Persistent data
   Client                                               172.17.1.101
                  Internet          balancer                            172.16.12.51          storage
                                                      Logic/compute     Persistent data
                                                                           storage

                                                                                MySQL, Postgres,
                                                                                Redis, MongoDB,
                                                                                       etc.


               Load balancers: Distribute traffic across compute nodes
  Load balancers
                               Public internet   Private datacenter network
                                                                              172.16.12.50
                                                              172.17.1.100
                                                                              Persistent data
       10.0.4.110                       171.67.215.200 hi there!
                                                            Logic/compute        storage        172.16.12.50
                                            Load                                                Persistent data
        Client hello!              hi there!    hello!        172.17.1.101
                        Internet          balancer                            172.16.12.51         storage
                                                            Logic/compute     Persistent data
                                                                                 storage


! When a client opens a connection to the load balancer, it selects a compute node and opens a
  connection to that compute node
   ○ Any traffic the client sends is relayed to the compute node. Any traffic the compute node sends
      is proxied back to the client
   ○ There are a variety of strategies for selecting the compute node (e.g. random selection, picking
      the one with the lowest load, round-robin, etc)
! The load balancer doesn’t do anything else; anything resource-intensive is offloaded to the compute
  nodes. Consequently, load balancers can handle a large number of concurrent connections
Load balancers
                       Public internet   Private datacenter network
                                                                      172.16.12.50
                                                      172.17.1.100
                                                                      Persistent data
   10.0.4.110                   171.67.215.200      Logic/compute        storage        172.16.12.50
                                   Load                                                 Persistent data
    Client                                            172.17.1.101
                Internet          balancer                            172.16.12.51         storage
                                                    Logic/compute     Persistent data
                                                                         storage


! Scalability: If many clients are connecting, we can add more compute nodes
Load balancers
                        Public internet   Private datacenter network
                                                       172.17.1.100
                                                                       172.16.12.50
                                                     Logic/compute
   10.0.4.110                    171.67.215.200                        Persistent data
                                                       172.17.1.101       storage        172.16.12.50
                                    Load
    Client                                           Logic/compute                       Persistent data
                 Internet          balancer                            172.16.12.51         storage
                                                       172.17.1.101    Persistent data
                                                                          storage
                                                     Logic/compute


! Scalability: If many clients are connecting, we can add more compute nodes
! Availability: If one of the compute nodes fails, load balancer will detect that it
  isn’t able to contact that server, and it can stop relaying traffic there
! Client never needs to know that our infrastructure is changing!
! Can we stop here?
Load balance your load balancers
Load balance your load balancers!

! Systems carrying large amounts of traffic can’t rely on a single load balancer
  ○ YouTube currently accounts for 15% of all internet traffic (source)
  ○ There’s no way a single machine can handle that much traffic passing
      through it
! A lone load balancer introduces a single point of failure
  ○ Hardware failures are uncommon, but they do happen
  ○ Entire-datacenter failures are uncommon, but they do happen
  ○ Murphy’s Law of large-scale systems: anything that can go wrong will go
      wrong! If you need high availability, you have to be prepared for the worst
Possible solution: Round-robin DNS

! DNS can return multiple IP addresses for a given hostname, shuffling the order
! Clients will pick the first one, moving down the list if IPs are unreachable
! You can specify multiple load balancers in this list, potentially in different datacenters
!   🍌 dig +noall +answer reddit.com
    reddit.com.            147          IN        A         151.101.193.140
    reddit.com.            147          IN        A         151.101.129.140
    reddit.com.            147          IN        A         151.101.65.140
    reddit.com.            147          IN        A         151.101.1.140
! Second time:
    🍌 dig +noall +answer reddit.com
    reddit.com.            339          IN        A         151.101.1.140
    reddit.com.            339          IN        A         151.101.129.140
    reddit.com.            339          IN        A         151.101.193.140
    reddit.com.            339          IN        A         151.101.65.140
Downsides of DNS load balancing

! Not very intelligent: can’t take into account whether some servers are more
  overloaded than others
! DNS infrastructure has a lot of caching. It’s hard to consistently rotate the
  order of IPs if your DNS responses get cached
  ○ Leads to uneven distribution of load
! If one of the servers fails, DNS will happily continue announcing its IP address
  ○ Clients will eventually try one of the other IP addresses when they realize
      the dead server is dead, but this can significantly increase latency to
      establish a connection
Huge sites, one IP?

!   🍌 dig +noall +answer www.google.com
    www.google.com.                 69      IN      A        216.58.217.196
!   🍌 dig +noall +answer www.facebook.com
    www.facebook.com.       4314    IN      CNAME   star-mini.c10r.facebook.com.
    star-mini.c10r.facebook.com. 32 IN      A       31.13.70.36
! What’s going on?
Geographic routing with DNS
Geographic routing with DNS

                              ! DNS servers can
                                respond with the IP for
                                the load balancer that
                                is closest to the client
                              ! Reduces connection
                                latency and helps to
                                distribute traffic
                              ! Doesn’t fix availability…
                                If local datacenter goes
                                down, want to fail over
                                to other datacenters
IP Anycast
! Though we don’t usually think like this, it’s possible for a single IP address to correspond to
  multiple computers
! Multiple datacenters can announce to the internet that they “own” a particular IP


                                                                     171.67.215.200            Logic/compute
                                                                      SFO load                 Logic/compute
                                                                      balancer                 Logic/compute
              10.0.4.110                                                                       Logic/compute

               Client                                                                                      Logic/compute
                                                                                 171.67.215.200
                                                                                   NYC load                Logic/compute
                                                                                   balancer                Logic/compute
                                                                                                           Logic/compute


        Note: a datacenter will almost always have multiple load balancers to distribute load and provide availability.
IP Anycast
! Though we don’t usually think like this, it’s possible for a single IP address to correspond to
  multiple computers
! Multiple datacenters can announce to the internet that they “own” a particular IP


                                                                          171.67.215.200            Logic/compute

                                                         h      g h                   SFO load            Logic/compute
                                                      a c ou
                                                    e
                                                   r t 0   h r    ! ”                 balancer            Logic/compute
                                               a n 0 f1                SFO
                                                     0
                                              c .2 t o                                                    Logic/compute
                                            u
                                         o 1 o   5       s            router
         10.0.4.110                     Y
                                      “ 7.2 a c
                                         . 6 at
                                      7 1 e
          Client                     1 m                           “You can reach            171.67.215.200         Logic/compute
                                                           171.67.215.200 through                                   Logic/compute
                                    Stanford                                       NYC
                                                               me at a cost of 100!”
                                                                                               NYC   load
                                     router                                       router       balancer             Logic/compute
                      Routing table:                                                                            Logic/compute
                      171.67.215.200 -> SFO router (10)
                      171.67.215.200 -> NYC router (100)
IP Anycast
! Though we don’t usually think like this, it’s possible for a single IP address to correspond to
  multiple computers
! Multiple datacenters can announce to the internet that they “own” a particular IP
! When a client tries to connect to an IP, they’ll use the datacenter that is closest to them
! If one of the datacenters goes down, the internet will notice and reroute traffic
                                                                                  171.67.215.200          Logic/compute
                                                                                   SFO load               Logic/compute
                                                                                   balancer               Logic/compute
                                                                        SFO
                                                                                                          Logic/compute
         10.0.4.110                                                    router
                      Des
                         tinat
          Client              ion:
                                     171                                                     171.67.215.200         Logic/compute
                                           .67.
                                                  215
                                                     .200                                      NYC load             Logic/compute
                                                            Stanford             NYC
                                                             router             router         balancer             Logic/compute
                                 Routing table:                                                                     Logic/compute
                                 171.67.215.200 -> SFO router (10)
                                 171.67.215.200 -> NYC router (100)
IP Anycast
! Though we don’t usually think like this, it’s possible for a single IP address to correspond to
  multiple computers
! Multiple datacenters can announce to the internet that they “own” a particular IP
! When a client tries to connect to an IP, they’ll use the datacenter that is closest to them
! If one of the datacenters goes down, the internet will notice and reroute traffic
                                                                                  171.67.215.200          Logic/compute
                                                                                   SFO load               Logic/compute
                                                                                   balancer               Logic/compute
                                                                        SFO
                                                                                                          Logic/compute
         10.0.4.110                                                    router
                      Des
                         tinat
          Client              ion:
                                     171                                                     171.67.215.200         Logic/compute
                                           .67.
                                                  215
                                                     .200                                      NYC load             Logic/compute
                                                            Stanford             NYC
                                                             router             router         balancer             Logic/compute
                                 Routing table:                                                                     Logic/compute
                                 171.67.215.200 -> SFO router (10)
                                 171.67.215.200 -> NYC router (100)
Engineer for failure
Chaos engineering

! To design reliable networked systems, you must assume any part of the
  system can fail
! But in a complex system, it’s hard to predict all failure modes
! Hard to learn how a system will fail until it fails
! Solution? Intentionally induce failure!
  ○ (in a controlled environment, where we can fix problems quickly, instead of
      having unexpected disasters at 3am)
! Netflix philosophy of Chaos Engineering: “the discipline of experimenting on a
  system in order to build confidence in the system’s capability to withstand
  turbulent conditions in production.”
Netflix Simian Army

                  ! Chaos Monkey
                     ○ Original tool, intended to simulate a thought
                        experiment: If you were to give a monkey a wrench
                        and let it loose in a datacenter, what would happen?
                     ○ Randomly terminates servers in production,
                        exposing engineers to frequent failures and
                        incentivizing fault-tolerant design
                  ! Chaos Gorilla: Randomly terminates an entire datacenter
                  ! Chaos Kong: Randomly terminates an entire geographic
                    region
                  ! Others: Latency Monkey, Doctor Monkey, Janitor
                    Monkey, Conformity Monkey, etc.
More reading

! https://blog.codinghorror.com/working-with-the-chaos-monkey/
  ○ “Raise your hand if where you work, someone deployed a daemon or
      service that randomly kills servers and processes in your server farm. Now
      raise your other hand if that person is still employed by your company.

      Who in their right mind would willingly choose to work with a Chaos
      Monkey?”
! https://netflixtechblog.com/the-netflix-simian-army-16e57fbab116
! http://principlesofchaos.org/
```

---

## Lecture 14: Information Security
*Thursday, May 21, 2020*

```
Information Security

   Ryan Eberhardt and Armin Namavari
             May 21, 2020
Today

! How do you keep information safe and sound?
! Could be an entire class by itself!
  ○ Today’s lecture isn’t even a high-level overview… it’s just a slice of the
    topic, from the perspective of networked systems design
Networked services

! Recall: In a networked service, a server listens for connections from one or
  more clients
  ○ When a connection is established, the client sends the server some
      request (usually using a protocol/“language” like HTTP)
  ○ The server interprets the request and sends some response back over the
      connection
! What threats might we need to defend against if our server has sensitive
  information?
Today

! Today:
  ○ Don’t give information to attackers that ask nicely
  ○ Make sure your dependencies don’t give information to attackers that ask
     nicely
  ○ Don’t give information to attackers that don’t ask nicely
Level 1: Don’t give information to
    attackers that ask nicely
Level 1: Don’t give information to attackers that ask nicely

! Stupid attack:
                           GET /super/secret/sauce HTTP/1.1


                Attacker          HTTP/1.1 200 OK             Server
                               The secret sauce is MSG


! No one would be that silly, right?
  Panera Bread mobile ordering app
                                              GET /foundation-api/users/uramp/7382194 HTTP/1.1


                             Attacker                                                                                                 Server

                                          "phones": [                          "isSmsGlobalOpt": false,                  "subscriptions": {
HTTP/1.1 200 OK
                                            {                                    "isEmailGlobalOpt": true,                  "subscriptions": [
                                              "id": 18295989,                    "isMobilePushOpt": false,                    {
{
                                              "phoneNumber": "redacted",         "birthDate": {                                 "subscriptionCode": 1,
  "customerId": 7382194,
                                              "phoneType": "Residential",          "birthDay": "redacted",                      "displayName": "Reward Reminders & Expiration Alert
  "username": "redacted@cox.net",
                                              "countryCode": "1",                  "birthMonth": "redacted",                    "isSubscribed": false,
  "firstName": "redacted",
                                              "extension": null,                   "birthYear": "redacted"                      "tncVersion": null
  "lastName": "redacted",
                                              "name": null,                      },                                           },
  "loyalty": {
                                              "isSmsOpt": false,                 "userPreferences": {                         {
    "cardNumber": "redacted"
                                              "isCallOpt": false,                  "foodPreferences": [                         "subscriptionCode": 2,
  },
                                              "isDefault": true,                     {                                          "displayName": "Panera Bread Updates & Special Offe
  "emails": [
                                              "isValid": true,                         "code": 3,                               "isSubscribed": false,
    {
                                              "smsPreferences": [                      "displayName": "Low Fat"                 "tncVersion": null
      "id": redacted,
                                                {                                    }                                        }
      "emailAddress": “redacted@cox.net",
                                                  "programName": "Delivery",       ],                                       ],
      "emailType": "Personal",
                                                  "isOpt": false,                  "gatherPreference": {                    "suppressors": [
      "isDefault": true,
                                                  "isOptPending": false              "code": 7,                               {
      "isOpt": true,
                                                }                                    "displayName": "Meal with family"          "suppressionCode": 1,
      "isVerified": true
                                              ]                                    }                                            "displayName": "Catering",
    }
                                            }                                    },                                             "isSuppressed": false
  ],
                                          ],                                                                                  },
Panera Bread mobile ordering app
                           GET /foundation-api/users/uramp/7382194 HTTP/1.1


                Attacker                                                            Server


! Sequential IDs: you could trivially enumerate every ID and download their entire database
! Case study in how not to handle a security breach:
   ○ Blew off security researcher for 8 months
   ○ Within two hours of researcher going to the press, announces issue is fixed and only 10k users affected
        ■ Look at the user ID above! 7382194 >> 10000
   ○ Did not actually fix vulnerability! Same mistake was present on dozens of other API “endpoints” as well
       as other applications
! https://medium.com/@djhoulihan/no-panera-bread-doesnt-take-security-seriously-bf078027f815
! Note: Not trying to pick on Panera. Bad attitudes towards security are endemic throughout industry (part of
  the motivation for teaching this class!)
How do we avoid this?
Authentication and authorization

! Authentication: who are you?
  ○ Established by supplying credentials (e.g. username/password, 2FA
     authentication token, secret key, etc.)
! Authorization: are you allowed to do what you’re trying to do?
  ○ Established by some security policy (e.g. a user may access his/her own
     emails, but not the emails of other people)
! A secure service must establish both
Common setup
                                                                           Authentication
                  My username is cactus and my password is prickly

                  Great! Use this token next time you talk to me: abc123

                   Show me emails for user cactus. My token is abc123
         Client                                                                   Server
                                                                               Validate abc123
                                                                            Check that cactus has
                           Here are emails for user cactus: …               necessary permissions


                                                                                             Authorization

! Authentication: clients must demonstrate their identities
! Authorization: server must check permission before carrying out request
! Tokens aren’t strictly necessary here, but provide a mechanism for expiring credentials
  after some time
  ○ Cookies = tokens
Life without authentication: SaltStack

! Last week, we alluded to clusters of hundreds or thousands of machines
  used to provide scale and availability
! You can’t manage that many machines by SSHing in individually

                                                             Compute node
                                                               Application
                  SaltStack   🔐 My CPU usage is 68%!
                                                                SS Minion
                   master
                              🔐
                                  My
                                     CPU
                                           usa               Compute node
                                              ge is            Application
                                                      20
                                                        %!
                                                                SS Minion
Life without authentication: SaltStack

! Last week, we alluded to clusters of hundreds or thousands of machines
  used to provide scale and availability
! You can’t manage that many machines by SSHing in individually
                                                                Compute node
                                                                  Application
                         SaltStack    🔐 Install version 10
                          master                                   SS Minion
                         Job queue:
                                      🔐
                                          Ins
                                             tall               Compute node
                                                    ver
                                                       sio
       🔐 Please update the                                n1      Application
                                                            0
       servers to version 10                                       SS Minion


                        System
                      administrator
Life without authentication: SaltStack

! SaltStack accidentally exposed a function to network requests that enqueues
  messages
! Was never intended to be called directly in network requests
                                                                                                  Compute node
                 _send_pub(): install                                                               Application
                 bitcoin miner and kill     SaltStack     🔐 Install bitcoin miner
                         SSH                 master                                                  SS Minion
    Attacker 😈
                                            Job queue:
                                                          🔐
                                                              Ins
                                                                    tall                          Compute node
                                                                           bit
                                                                              co
                                                                                 in m               Application
                          🔐 Please update the                                           ine
                          servers to version 10                                               r
                                                                                                     SS Minion


                                            System
                                          administrator
Life without authentication: SaltStack

! Exactly three weeks ago, companies’ entire clusters started becoming
  unreachable
  ○ Many of them targeted with bitcoin mining + backdoor
  ○ DigiCert, Algolia, Ghost, Xen Orchestra, LineageOS, others
  ○ Nightmare to fix! Once you manage to get back in, how do you verify
     attackers aren’t still hiding?
  ○ https://duo.com/decipher/saltstack-flaw-used-in-numerous-attacks
  ○ https://blog.sonatype.com/saltstack-20-breaches-within-four-days
Life without authorization: LocationSmart

! LocationSmart is a location tracking service that partners with every major US
  cell carrier and sells location data (e.g. to law enforcement, marketing
  agencies, companies wanting to track corporate devices)
  ○ Location data is collected via cell phone tower triangulation. Impossible to
      opt-out
Life without authorization: LocationSmart

! The company offered a demo website that shows your own location on a map
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                                     HTTP/1.1 200 OK
               {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
         “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", “network":
             {"carrier":"T-Mobile", “locatable":"True", “callType":"wireless", "locAccuracySupport":"Precise
                  Possible”, “nationalNumber":"8005551212", “countryCode":"1", “regionCode":"US",
            "regionCountry":"UNITED STATES”}, “subscriptionGroup":[{"name":"LOCA-D01-LOCNOPIN",
Client   “locatable":"False", “smsAvailable":"False"}, {“name":"LOCA-D02-WELCOME", “locatable":"False",        Server
                “smsAvailable":"False"}], “smsAvailable":"True", “privacyConsentRequired":"True",
                 “clientLocatable":"false", "clientSMSAvailable":"Not supported”, "whiteListed":"false"}
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                               HTTP/1.1 200 OK
             {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
            “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", …
                                           POST /try/api HTTP/1.1
                requestdata={"subscriptionAction":"status","tn":"8005551212","carrierReq":"true"}
                                       &requesttype=subscriptionreq
Client                                                                                               Server
                                                   HTTP/1.1 200 OK
                                        <?xml version="1.0" encoding="UTF-8"?>
                                                      <LocResp>
                                                <uid>REDACTED</uid>
                              <requestTime>2018-05-17T00:03:46.073+00:00</requestTime>
                                            <statusCode>42</statusCode>
                                   <statusMsg>SubscriptionNotActive</statusMsg>
                                               <carrier>T-Mobile</carrier>
                                          <deviceId>8005551212</deviceId>
                                                 <tn>8005551212</tn>
                                                      </LocResp>
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                               HTTP/1.1 200 OK
             {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
            “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", …
                                           POST /try/api HTTP/1.1
                requestdata={"subscriptionAction":"status","tn":"8005551212","carrierReq":"true"}
                                       &requesttype=subscriptionreq
Client                                                                                               Server
                                                     HTTP/1.1 200 OK
                                         <?xml version="1.0" encoding="UTF-8"?>
                                                   <SubscriptionResp>
                                                  <uid>REDACTED</uid>
                              <requestTime>2018-05-17T00:43:44.631+00:00</requestTime>
                                              <statusCode>0</statusCode>
                                            <statusMsg>Success</statusMsg>
                                                   <tn>8005551212</tn>
                             <subscriptionGroup>LOCA-D01-LOCNOPIN</subscriptionGroup>
                               <subscriptionOptInState>requested</subscriptionOptInState>
                                                 <contact>sms</contact>
                                                   </SubscriptionResp>
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                               HTTP/1.1 200 OK
             {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
            “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", …
                                            POST /try/api HTTP/1.1
                 requestdata={"subscriptionAction":"status","tn":"8005551212","carrierReq":"true"}
                                        &requesttype=subscriptionreq
Client                                                                                                     Server
                                                HTTP/1.1 200 OK
                                                      …
                                             POST /try/api HTTP/1.1
         requestdata={“civicAddressReq”:"True","geoAddressReq":"True","extAddressReq":"True","nearby
         PoiReq":"True","privacyConsent":"True","token":"TOKEN","locationtype":"network","accuracyReq":"
                      Coarse","tnDetailReq":"False","carrierReq":"true"}&requesttype=locreq
                                                HTTP/1.1 200 OK
                                           Location data in XML format
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                               HTTP/1.1 200 OK
             {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
            “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", …
                                            POST /try/api HTTP/1.1
                 requestdata={"subscriptionAction":"status","tn":"8005551212","carrierReq":"true"}
                                        &requesttype=subscriptionreq
Client                                                                                                     Server
                                                HTTP/1.1 200 OK
                                                      …
                                             POST /try/api HTTP/1.1
         requestdata={“civicAddressReq”:"True","geoAddressReq":"True","extAddressReq":"True","nearby
         PoiReq":"True","privacyConsent":"True","token":"TOKEN","locationtype":"network","accuracyReq":"
                      Coarse","tnDetailReq":"False","carrierReq":"true"}&requesttype=locreq


                           Error if user has not consented (or location info if they have)
Life without authorization: LocationSmart
                                      POST /try/api HTTP/1.1
         requestdata={“deviceType":"Wireless","deviceID":"8005551212","devicedetails":"true",
                          "carrierReq":"true"}&requesttype=statusreq.json
                                                HTTP/1.1 200 OK
              {“uid":"REDACTED", “requestTime":"2018-05-16T21:25:50.689+00:00", “statusCode”:0,
             “statusMsg":"Success", “deviceId":"8005551212", “token":"TOKEN", “locatable":"True", …
                                            POST /try/api HTTP/1.1
                 requestdata={"subscriptionAction":"status","tn":"8005551212","carrierReq":"true"}
                                        &requesttype=subscriptionreq
Client                                                                                                     Server
                                                HTTP/1.1 200 OK
                                                      …
                                             POST /try/api HTTP/1.1
         requestdata={“civicAddressReq”:”True","geoAddressReq":"True","extAddressReq":"True","nearby
         PoiReq":"True","privacyConsent":"True","token":"TOKEN","locationtype":"network","accuracyReq":"
                   Coarse","tnDetailReq":"False","carrierReq":"true"}&requesttype=locreq.json


                              Location info (regardless of whether user consented)
Life without authorization: LocationSmart

! Almost certainly a bad case of copy/paste
! Trivial to exploit
! Overview and context: https://krebsonsecurity.com/2018/05/tracking-firm-
  locationsmart-leaked-location-data-for-customers-of-all-major-u-s-mobile-
  carriers-in-real-time-via-its-web-site/
! Technical writeup: https://www.robertxiao.ca/hacking/locationsmart/
How can we prevent this?

! Standard approach: Use a framework that handles every request, checks
  authentication/authorization, then calls your application code
! Experimental/research approaches: Use type systems to track the flow of
  information
Level 2: Make sure your dependencies don’t
give information to attackers that ask nicely
Level 2: Make sure your dependencies don’t give information to attackers that
                                ask nicely


                                                               172.16.12.50
                                            172.17.1.100
                                                               Persistent data
  10.0.4.110              171.67.215.200   Logic/compute          storage        172.16.12.50
                            Load                                                 Persistent data
   Client                                   172.17.1.101
               Internet    balancer                            172.16.12.51         storage
                                           Logic/compute       Persistent data
                                                                  storage


                                                           These servers have IP addresses too!
Elasticsearch

! “Elasticsearch is a distributed, open source search and analytics engine for all
  types of data, including textual, numerical, geospatial, structured, and
  unstructured” (Elastic website)
  ○ Used for application search, website search, logging and log analytics,
     infrastructure metrics, geospatial data analysis and visualization, etc.
! Extremely handy! You can throw up an Elasticsearch cluster, throw data in
  there as it comes in, and quickly run queries on that data
Elasticsearch default settings

! By default, only responds to local connections (i.e. connections coming from
  the machine Elasticsearch is installed on)
  ○ This is a problem if you want to use Elasticsearch in the context of a
     cluster of machines
! No problem! Just change the configuration to accept external connections
Elasticsearch default settings

! By default, only responds to local connections (i.e. connections coming from
  the machine Elasticsearch is installed on)
  ○ This is a problem if you want to use Elasticsearch in the context of a
     cluster of machines
! No problem! Just change the configuration to accept external connections
HIBP “db8151dd" breach

! Have I Been Pwned is a free service that will notify you if your information has been
  found in an online data dump
! Last week, I was notified my data was compromised in a company’s data breach
  involving 103M records
   ○ Big twist: No one has any idea which company!
   ○ Found on an Elasticsearch instance on the Internet. No one knows who it belongs to
! Records include social media profiles, contact information, addresses, employment
  information, and random stuff like “Recommended by Andie [redacted last name].
  Arranged for carpenter apprentice Devon [redacted last name] to replace bathroom
  vanity top at [redacted street address], Vancouver, on 02 October 2007.”
! Excellent read: https://www.troyhunt.com/the-unattributable-db8151dd-data-breach/
Elasticsearch: It’s not our fault

! According to ES, breaches are caused by “a poor understanding of
  Elasticsearch security and how the software works: ‘Reports usually involve
  instances where individuals or organizations have actively configured their
  installations to allow unauthorized and authenticated users to access their
  data over the internet.’” (source)
! I’m picking on Elasticsearch, but if you Google “S3 data breach” or
  “MongoDB data breach,” you’ll find just as many severe cases (some are
  even worse)
Why does this happen?

! Bad default settings
  ○ Databases commonly have a default username and password
  ○ MongoDB used to accept all network connections by default
  ○ We’re slowly getting better at this
! Negligent/inexperienced engineers and system administrators
  ○ “I need to access my database from a different server, so let’s open it up on the
     network!”
  ○ Systemic problem: Security is often a poorly-understood afterthought in
     organizations
  ○ I’m not really sure if we’ve been improving very much
! We’ve designed systems where the path of least resistance = bad security
  ○ It needs to be harder to do things wrong than it is to do things right
  ○ In many places, only beginning to think about this
Takeaways

! If you run a big service with sensitive information, you have to be regularly
  testing for things like this
  ○ Can configure automated scans to ensure no servers are publicly
      reachable that shouldn’t be
  ○ Pay auditing / penetration testing firms to find weaknesses in your system
! There’s a lot of work to be done in figuring out how to improve security for
  systems we don’t operate
  ○ E.g. Github has started scanning repositories for known vulnerabilities in
      dependencies
  ○ How can we design libraries and frameworks and systems that are secure
      by default?
Level 3: Don’t give information to
 attackers that don’t ask nicely
Level 3: Don’t give information to attackers that don’t ask nicely

! Imagine you’re trying to hack into a system. How would you go about it?
! Try the easy things first (e.g. finding obvious weaknesses, or social
  engineering)
! Next best thing: known vulnerabilities
  ○ Most of the time, you don’t even need to find new vulnerabilities yourself!
      People are generally bad at updating software
  ○ If your target is using outdated software (e.g. HTTP server, graphics
      library, Linux, you name it) with known bugs, you can simply exploit those
      bugs
WannaCry

! Ransomware: Encrypts all of the files on your computer and demands Bitcoin
  payment before you can get them back
! Estimated 200,000 machines infected across 150 countries, up to $4B in
  economic damage
! Crippled National Health Service in UK: infected computers, MRI scanners,
  blood storage refrigerators, and more
WannaCry

! Timeline
  ○ At some point, the NSA discovered an exploitable buffer overflow in the
     Windows SMB (file sharing) stack. Did not share it with Microsoft (used it
     for offensive exploits)
  ○ March 14, 2017: Microsoft independently discovers bug, releases patch
     and security advisory
  ○ April 14, 2017: The Shadow Brokers announce they hacked the NSA, and
     they release NSA’s EternalBlue exploit
  ○ May 12, 2017: WannaCry begins to spread across the internet
Equifax breach

! Scope: 143 million affected (basically every adult with a credit history in the US)
! March 7, 2017: Apache releases a patch and a security advisory for a critical
  vulnerability in Apache Struts (web application framework)
! Mid-May 2017: attackers use this vulnerability to get RCE in Equifax systems
! July 29, 2017: Equifax finally discovers the breach
! September 7(!!!), 2017: Equifax finally announces they’ve been hacked
! https://www.csoonline.com/article/3444488/equifax-data-breach-faq-what-
  happened-who-was-affected-what-was-the-impact.html
! https://krebsonsecurity.com/2017/09/equifax-breach-response-turns-
  dumpster-fire/
Update and isolate

! Take the low-hanging fruit: Updating may be annoying, but being compromised is
  much worse
! Much of the last decade has been spent trying to figure out how to get people to
  update
  ○ Chrome updates in the background
  ○ Android has tried to move more functionality into apps that can be updated via
     Google Play, since carriers are bad at updating the OS
  ○ Windows has forced updates now
  ○ Still more room for creativity!
! Reduce your attack surface: Don’t expose anything to the Internet that doesn’t
  need to be exposed to the Internet
Zero days

! The last resort for an attacker is to find a brand new flaw in your system
! If you want to stop the attackers, you have to find and fix the flaws before they do
! This is really hard! Need to pay people to do this
  ○ Larger tech companies have dedicated security “red teams” that try to find
      ways to attack their systems
  ○ Also a good idea to crowdsource: bug bounty programs pay out to people
      that find exploitable vulnerabilities
! If you need high security, you should also be looking for bugs in dependencies
  ○ Heartbleed (2014): Realized everyone uses OpenSSL, but no one pays for it
  ○ Google operates an incredible team called Project Zero that hunts for bugs in
      any commonly-used software
```

---

## Lecture 15: Futures I
*Tuesday, May 26, 2020*

```
Futures I

Ryan Eberhardt and Armin Namavari
          May 26, 2020
Logistics

! Congrats on making it to week 8! 🔥
  ○ I can’t believe it’s week 8 😳
! It’s exciting to see people saying they’re starting to appreciate Rust more!
  ○ Thanks for sharing your thoughts in #reflections!
Today

! The Plan
  ○ Threads — the perfect solution to scalable I/O?
       ■ This is a rhetorical question, the answer is no.
  ○ Nonblocking I/O
  ○ Rust Futures
! These concepts are really tricky so please ask questions!
! It’s OK if futures don’t make sense today, we’ll review them and practice them
  on Thursday as well.
But first… what do you think this code does?
// Pretend you don’t see the unfamiliar syntax! (i.e. async/await)
tokio::spawn(async move { // example from the Tokio docs
    let mut buf = [0; 1024];
    loop {
        let n = match socket.read(&mut buf).await {
            Ok(n) if n == 0 => return,
            Ok(n) => n,
            Err(e) => {
                eprintln!("failed to read from socket; err = {:?}", e);
                return;
            }
        };
        if let Err(e) = socket.write_all(&buf[0..n]).await {
            eprintln!("failed to write to socket; err = {:?}", e);
            return;
        }
    }
});
Review: Threads

! A “virtual process”
  ○ Control: the routine (i.e. function) running inside of the thread
  ○ State: a stack, CPU registers, status (ready/running/blocked), etc.
! The OS manages threads
  ○ The dispatcher is responsible for assigning threads to run on cores,
     swapping them on and off as appropriate.
     ■ These context switches aren’t the cheapest thing e.g. the overhead of
          copying stuff, cache evictions etc.
  ○ The scheduler is responsible for deciding what thread to run next.
The Dispatcher

! What sorts of things can move us from
  “running” to “blocked”?
  ○ I/O: reading and writing
  ○ Waiting: waitpid, sigsuspend, join,
       cv.wait(…) etc.
  ○ lock()
  ○ sleep()
! If a thread is blocked, it can’t waste CPU
  resources
  ○ This is why threading lets us overlap wait
       times for I/O bound operations.
Building a High Performance Server with Threads

! Great, so if we want to build a server that can handle many requests at once,
  we just declare a big thread pool with ~4000 threads, right?
  ○ Each thread needs its own stack…
  ○ 4000 lil’ stacks adds up to a LOT of memory!
  ○ This ends up being very cache unfriendly
  ○ The OS also has to manage resources on behalf of these 4000 threads
! Upshot: if you use blocking operations, you are fundamentally limited by the
  number of threads you can run at once 😕
! Also, threads are often hard to get right
  ○ Race conditions, deadlock, etc.
Non-blocking I/O

! Traditionally, the read sys call would block if there is more data to be read but
  not available
! Instead, we could have read return a special error value instead of blocking
  so that we can do other useful work on this thread e.g. reading from other
  descriptors we’re managing.
  ○ This is especially relevant for I/O intensive pieces of software like servers.
  ○ Often times you’d call these nonblocking I/O operations in a loop and use
      something like epoll to keep track of which are ready
! This allows us to have concurrent I/O with one thread!
Non-blocking I/O visualized

! Epoll is a kernel-provided
  mechanism that notifies us of
  what fds are ready for I/O.
  ○ Why should we attempt to do
     I/O on fds that aren’t even
     ready?
! We perform I/O only on
  descriptors that are ready until
  they are no longer ready.
State management

! Epoll is nifty, but it forces us to
  manage state in tricky ways
  ○ If you have one thread per
     connection, all the state for
     each connection is stored in
     each thread’s stack
  ○ If you’re trying to use epoll, you
     have to store the state yourself
     and somehow associate each
     file descriptor with state
State management

! Rust (and a handful of other
  languages) us in two ways:
  ○ Futures allow us to keep track
     of in-progress operations
     along with associated state, in
     one package
  ○ async/await syntax allows us
     to easily chain futures together,
     creating “threads” of futures
Intro to Futures

! Future: the result of a computation that may or
  may not have completed.
  ○ A “computation in progress”
  ○ Very similar to promises in Javascript (if you’re
      familiar with those)
  ○ A single thread can run multiple futures =>
! In Rust, futures are structs that implement the
  Future trait
  ○ These structs could represent, for instance, a
      nonblocking I/O operation.
The Future Trait

trait Future { // This is a simplified version of the Future definition
    type Output;
    fn poll(&mut self, cx: &mut Context) -> Poll<Self::Output>;
    // cx contains a “waker” that provides a notification mechanism
    // to indicate that the Future is ready to make more progress
    // e.g. data becomes available to read
}

enum Poll<T> {
    Ready(T),
    Pending,
}
Executors

! In order to actually execute futures, we need some sort of runtime or
  “executor” that repeatedly calls the “poll” function of the Future object.
  ○ This is a generalization of the loop for nonblocking I/O we had earlier.
! A popular executor in the Rust ecosystem is Tokio and it’s what you’ll be
  using in Project 2!
! If you have multiple cores on your machine, you can actually execute futures
  truly in parallel!
  ○ This means that if you have multiple async tasks running, you need to
      protect shared data using synchronization primitives.
What is an executor really doing?
Combining futures together

! Map — apply some function to the output of the future
  ○ We can combine a function and a future to get a new future!
! Join — start executing a group of futures concurrently
  ○ We can take futures, put them together, and get a new future!
! Rust lets us ergonomically chain futures together by using the await keyword.
Async/Await Code Example
tokio::spawn(async move { // example from the Tokio docs for a TCP echo server
    let mut buf = [0; 1024];

      // In a loop, read data from the socket and write the data back.
      loop {
          let n = match socket.read(&mut buf).await { // non-blocking read!
              // socket closed
              Ok(n) if n == 0 => return, // no more data to read
              Ok(n) => n,
              Err(e) => {
                  eprintln!("failed to read from socket; err = {:?}", e);
                  return;
              }
          };

          // Write the data back
          if let Err(e) = socket.write_all(&buf[0..n]).await { // non-blocking write!
              eprintln!("failed to write to socket; err = {:?}", e);
              return;
          }
      }
});
Async: Under the Hood
Await vs. Join

async fn assemble_book() -> String {
    // The request returns a future for a non-blocking read operation
    let half1 = request_first_half_server();
    let half2 = request_second_half_server();
    let first_half_str: String = half1.await;
    let second_half_str: String = half2.await;
    format!("{}{}", first_half_str, second_half_str)
}

async fn assemble_book() -> String {
    // The request returns a future for a non-blocking read operation
    let half1 = request_first_half_server();
    let half2 = request_second_half_server();
    let (first_half_str, second_half_str) = futures::join!(half1, half2);
    format!("{}{}", first_half_str, second_half_str)
}
Async/Await in Rust

! Rust enables us to write our code in a way that looks blocking, but actually
  runs asynchronously
  ○ Like many fancy features in Rust, we get this from the magic of the Rust
     compiler — async/await provide us with syntactic sugar.
  ○ Long story short: the Rust compiler is able to transform your chain of
     async computation (i.e. futures) into an efficient state machine.
! This is amazing! You get the ergonomics of writing code that looks like it’s
  blocking but the performance benefits of nonblocking operations!
General Tips for Async Rust

! Never block in async code!
  ○ Asynchronous tasks are cooperative (not preemptive)
! You can only use await in async functions.
! Rust won’t let you write async functions in traits (for technical reasons that have to
  do with lifetimes and the fact that you can’t have associated type bounds yet)
  ○ You can use a crate called async-trait though!
! Be cognizant of shared state between tasks and synchronize appropriately! (e.g.
  you may need a Mutex<T>, but of course, one that will play well with Futures)
  ○ Tokio provides its own async implementations of concurrency primitives. E.g.
     you can replace std::sync::mutex with tokio::sync::mutex (the API is
     nearly identical)
Additional Resources/References

! A great talk about how Rust arrived on the design for futures
! Another great talk about futures
! Phil Levis' CS110 Lecture on Events, Threads, and Async I/O
! The Rust Docs on Futures
! An article on futures
! John Ousterhout on why threads are a bad idea
! A great (and very accessible) Medium article explaining epoll (also has great
  illustrations!)
! A CS242 Assignment on Implementing Futures
! Note: the syntax for futures has changed over time so some of these articles may
  use outdated syntax — for the most up-to-date syntax, check out the docs.
```

---

## Lecture 16: Futures II
*Thursday, May 28, 2020*

```
Futures II

Ryan Eberhardt and Armin Namavari
          May 28, 2020
Today

! The Plan
  ○ Review futures from last time
  ○ Talk about how futures can be combined together
  ○ Live coding example
  ○ Parting thoughts on async/await
! These concepts are really tricky so please ask questions!
  ○ You will get practice with these concepts in project 2!
Non-blocking I/O and Futures
What is an executor really doing?
Combining futures together

! Map — apply some function to the output of the future
  ○ We can combine a function and a future to get a new future!
! Join — start executing a group of futures concurrently
  ○ We can take futures, put them together, and get a new future!
! Rust lets us ergonomically chain futures together by using the await keyword.
Async/Await Code Example
tokio::spawn(async move { // example from the Tokio docs for a TCP echo server
    let mut buf = [0; 1024];

      // In a loop, read data from the socket and write the data back.
      loop {
          let n = match socket.read(&mut buf).await { // non-blocking read!
              // socket closed
              Ok(n) if n == 0 => return, // no more data to read
              Ok(n) => n,
              Err(e) => {
                  eprintln!("failed to read from socket; err = {:?}", e);
                  return;
              }
          };

          // Write the data back
          if let Err(e) = socket.write_all(&buf[0..n]).await { // non-blocking write!
              eprintln!("failed to write to socket; err = {:?}", e);
              return;
          }
      }
});
Async: Under the Hood
Async: Under the Hood

! The Rust compiler
  transforms the async
  function into a function that
  returns a future.
! This particular future will
  apply tokenize to the
  output of the future returned
  by download_webpage
Await vs. Join

async fn assemble_book() -> String {
    // The request returns a future for a non-blocking read operation
    let half1 = request_first_half_server();
    let half2 = request_second_half_server();
    let first_half_str: String = half1.await;
    let second_half_str: String = half2.await;
    format!("{}{}", first_half_str, second_half_str)
}

async fn assemble_book() -> String {
    // The request returns a future for a non-blocking read operation
    let half1 = request_first_half_server();
    let half2 = request_second_half_server();
    let (first_half_str, second_half_str) = futures::join!(half1, half2);
    format!("{}{}", first_half_str, second_half_str)
}
Link-Explorer Revisited with Async/Await

! Let’s revamp link-explorer link explorer example with async/await!
! Recall the version we had with threading.
  ○ I’ve upgraded it to work with a ThreadPool
  ○ Let’s see how well it does
! Now we’re going to code up the async version of it
  ○ And we’ll have to use async synchronization primitives to protect shared
      data!
Results

! Threadpool (20 threads, implicitly limits the number of files open at once)


! Async/await (Tokio, max 20 threads + a semaphore to restrict how many files
  can be open at once)
Async/Await in Rust

! Rust enables us to write our code in a way that looks blocking, but actually runs
  asynchronously
  ○ Like many fancy features in Rust, we get this from the magic of the Rust compiler
      — async/await provide us with syntactic sugar.
  ○ Long story short: the Rust compiler is able to transform your chain of async
      computation (i.e. futures) into an efficient state machine.
! This is amazing! You get the ergonomics of writing code that looks like it’s blocking
  but the performance benefits of nonblocking operations! 🔥
! However, this also means that a lot of your code ends up having to become async —
  you can only call an async function in an async block
  ○ It also makes backtraces harder to interpret 😕
General Tips for Async Rust

! Never block in async code!
  ○ Asynchronous tasks are cooperative (not preemptive)
! You can only use await in async functions.
! Rust won’t let you write async functions in traits (for technical reasons that have to
  do with lifetimes and the fact that you can’t have associated type bounds yet)
  ○ You can use a crate called async-trait though!
! Be cognizant of shared state between tasks and synchronize appropriately! (e.g.
  you may need a Mutex<T>, but of course, one that will play well with Futures)
  ○ Tokio provides its own async implementations of concurrency primitives. E.g.
     you can replace std::sync::mutex with tokio::sync::mutex (the API is
     nearly identical)
```

---

## Lecture 17: Macros
*Tuesday, June 2, 2020*

```
Rust Macros

Ryan Eberhardt and Armin Namavari
          June 2, 2020
Logistics

! CS110L shouldn’t be your priority right now
! Project 2 is out and we’ve updated our policy on it with regards to current
  circumstances — please check out Ryan’s Slack post.
! Please fill out Week 8 survey tonight: https://forms.gle/PEmptvXLx5TdTm4A9
Today

! The Plan
  ○ Preliminaries
  ○ Rust Macros
      ■ Declarative Macros
      ■ Procedural Macros (of which there are three kinds)
! Goal: understand what Rust macros are and how they work.
! This is one of the strangest concepts we’ll cover (yes, maybe even weirder than
  nonblocking I/O and futures). Please ask questions.
! Next week we’ll have a guest speaker who will talk about some exciting systems
  work he’s done with Rust and how that work draws on the power of Rust macros.
  ○ You may want to review this lecture before next Tuesday!
        What are Macros? (in C)

         ! Basically fancy find-and-replace
         ! When found, the macro is replaced
           with some chunk of code
         ! It’s almost like there aren’t any rules
           (see the example on the bottom)
         ! What about:
           ○ #define MAX(X, Y) (((X)
                > (Y)) ? (X) : (Y))


https://stackoverflow.com/questions/3437404/min-and-max-in-c, https://danielkeep.github.io/tlborm/book/mbe-syn-source-analysis.html
Why Macros?

! Because it’s cool to write code that writes other code
! Because code reuse is nice
  ○ i.e. Having to write boilerplate code over and over again is bad. Why?
! Rust does macros pretty differently from C and this has some cool
  implications for the kind of code you can write.
  ○ Rust macros can let you execute arbitrary code at compile-time
  ○ Could you imagine doing something like derive with C macros?
You have already used macros in Rust

!   println!(“hello {}!”, name);
!   vec![1, 2, 3];
!   #[derive(Clone, Copy)]
!   #[tokio::main]
First, a little bit about languages and compilers

! Processors on your computer don’t speak Rust
! The rust compiler (rustc) must take your Rust code and translate it into assembly
  language
! Compilers usually operate in four steps:
   ○ Lexing — find the tokens e.g. “fn” “if” “struct” “trait” “pub" etc.
   ○ Parsing — understand the structure of these tokens e.g. what part of code
      corresponds to this if statement? produce an abstract syntax tree (AST)
   ○ Type-checking/Semantic Analysis — Make sure the code makes sense e.g.
      you can’t pass in a String to a function that expects a u32, borrow-checking
   ○ Code generation — convert your type-labeled AST into assembly.
   ○ If you’d like to learn more and build your very own compiler, take CS143!
Abstract Syntax Trees and Token Trees

! Rust macros operate over token trees which are somewhere between the
  abstract syntax tree and the raw tokens themselves.
  ○ Identifiers (variable names, keywords), literals (e.g. int and string literals),
     punctuation (not a delimiter, e.g. “.”), and groups.
! An AST provides us full info about the expression as a whole
! The token-tree tells us about how tokens are grouped together with (…), {…},
  and […]
  ○ We’ll see pictures of this in the following slides
Token Tree(s) Example
   AST Example

    !         a + b + (c + d[0]) + e


https://danielkeep.github.io/tlborm/book/mbe-syn-source-analysis.html
Declarative Macros with macro_rules!

! Very fancy pattern matching. Sort of like C macros on steroids
! Patterns look like this:
  ○ {$pattern} => {expansion}
! Tries to find match (over token tree) and expand to the code indicated by that
  case of the match (we’ll see an example in the next slide)
! If you’d like to learn more about all the possible patterns/rules, take a look
  through the links on the last slide.
Peeking under the hood of vec!

#[macro_export]
macro_rules! vec {
    ( $( $x:expr ),* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}
Peeking under the hood of vec!
Procedural Macros

! Functions that take in code as input and produce code as output
  ○ Declarative macros feel more like match statements than they do like
     functions.
  ○ Procedural macros are more powerful than declarative macros but often
     harder to use (not to imply that macro_rules! is easy!)
     ■ the power vs. simplicity tradeoff is a common theme
! Three kinds:
  ○ Derive-type macros
  ○ Attribute-like macros
  ○ Function-like macros
“Derive” Macros

! Recall that we can automatically derive traits for structs we define
! We’ll take a look at an example from the Rust book for how we can
  automatically generate code that implements traits for a given type
! We’ll have to deal with TokenStreams: stream of token trees
“Derive” Macros — The Plan

!   We’re going to walk through an example from the Rust Book.
!   We will define a function that takes in the struct as input as a TokenStream
!   It will then parse the TokenStream as an AST
!   It will use the AST to figure out the name of the struct
!   We will then use another macro called quote! to define a trait implementation
    for our struct and output this implementation as a TokenStream
“Derive” Macros — Code Example

// Client of the macro
use hello_macro::HelloMacro;
use hello_macro_derive::HelloMacro;

#[derive(HelloMacro)]
struct Pancakes;

fn main() {
    Pancakes::hello_macro();
}
“Derive” Macros — Code Example
extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn;

#[proc_macro_derive(HelloMacro)]
pub fn hello_macro_derive(input: TokenStream) -> TokenStream {
    // Construct a representation of Rust code as a syntax tree
    // that we can manipulate
    let ast = syn::parse(input).unwrap();

    // Build the trait implementation
    impl_hello_macro(&ast)
}
“Derive” Macros — Code Example
fn impl_hello_macro(ast: &syn::DeriveInput) -> TokenStream {
    let name = &ast.ident;
    let gen = quote! {
        impl HelloMacro for #name {
            fn hello_macro() {
                println!("Hello, Macro! My name is {}!", stringify!(#name));
            }
        }
    };
    gen.into()
}
Attribute-like procedural macros

! Like the derive macros but more general
! You can apply these macros to other syntactic entities e.g. functions
! You can write an attribute macro that verifies that you write your enum
  variants in sorted order (check out the project link on the last slide)
! You can write an attribute macro that packages a struct into a bitfield (also on
  the same project link)
! You can write an attribute macro that generates code for an HTTP request
  handler function (our guest speaker might talk about a project related to this
  next Tuesday!)
Attribute-like procedural macros (example)
#[bitfield]
pub struct MyFourBytes {
    a: B1,
    b: B3,
    c: B4,
    d: B24,
}
// Emits the code below (and rewrites struct definition to contain a private byte array)
impl MyFourBytes {
    // Initializes all fields to 0.
    pub fn new() -> Self;

    // Field getters and setters:
    pub fn get_a(&self) -> u8;
    pub fn set_a(&mut self, val: u8);
    pub fn get_b(&self) -> u8;
    pub fn set_b(&mut self, val: u8);
    pub fn get_c(&self) -> u8;
    pub fn set_c(&mut self, val: u8);
    pub fn get_d(&self) -> u32;
    pub fn set_d(&mut self, val: u32);
}
Function-like procedural macros

! Macro that looks like a function call
! e.g. sql! Macro from the Rust book — will construct some sort of SQL query
  object from SQL syntax.
let sql = sql!(SELECT * FROM posts WHERE id=1);

#[proc_macro]
pub fn sql(input: TokenStream) -> TokenStream {
 …
}
Recursive Macros

!   Macros can invoke other macros
!   Macros can invoke themselves
!   This can happen with declarative macros and with procedural macros
!   We’ll see an example on the next slide
A Declarative Recursive Macro
macro_rules! write_html {
    ($w:expr, ) => (());

    ($w:expr, $e:tt) => (write!($w, "{}", $e));

    ($w:expr, $tag:ident [ $($inner:tt)* ] $($rest:tt)*) => {{
        write!($w, "<{}>", stringify!($tag));
        write_html!($w, $($inner)*);
        write!($w, "</{}>", stringify!($tag));
        write_html!($w, $($rest)*);
    }};
}
// Usage:
write_html!(&mut out,
    html[
        head[title["Macros guide"]]
        body[h1["Macros are the best!"]]
    ]);

// https://doc.rust-lang.org/1.7.0/book/macros.html
Summary

! Declarative macros
  ○ macro_rules!
  ○ Match expressions and expand out, emitting code accordingly
! Procedural macros
  ○ Procedures that take in TokenStreams and emit TokenStreams
  ○ More powerful than declarative macros but trickier to use
  ○ Derive
  ○ Attribute
  ○ Function-like
Resources

!   The Rust Book on Macros
!   The Little Book of Rust Macros
!   A Great Blog Post about Procedural Macros by Alex Crichton
!   A Great Blog Post About Macros
!   A Workshop on Procedural Macros
!   A Blog Post about Recursive Macros
```

---

## Lecture 18: Reflecting on Rust
*Thursday, June 4, 2020*

```
Reflecting on Rust

  Ryan Eberhardt and Armin Namavari
            June 4, 2020
Logistics

! This is our last lecture together 😢
  ○ We are so, so proud of everything you have learned this quarter, and we
     hope you are too!
! Next Tuesday, will have a guest lecture from Sergio Benitez
  ○ Please come!
! Please fill out Week 8 survey if you haven’t already (link in Slack)
! Project 2 due Wednesday, but we will accept it until Saturday with no penalty,
  and we are happy to give further accommodations if you aren’t graduating
Why are we here?

! What was the point of this class?
  ○ Learn about common safety issues in designing/building systems
  ○ Learn about how people are responding to those problems
  ○ Get first-hand experience with those responses
! This lecture will focus on Rust in particular
  ○ Why do we care about Rust?
  ○ Why is Rust effective and what can we learn from its design?
  ○ How can we work to write safer C++?
Why do we care about Rust?

             Manual memory                                            Garbage
              management                       ???                    collection
                                                                          Safe,
                    Fast
                                                                         simple
                                           Can we have
                                             both??


! Manual memory management has led to countless security vulnerabilities (70% of Chrome
  security bugs are memory safety issues)
! Garbage collection introduces unpredictable latency and unacceptable overhead for many
  applications
! Is there some way we get the benefits of both approaches?
   ○ Rust seems to do this for us! In this lecture, we’ll look at why it works, and how we might
       be able to apply lessons from Rust to other languages
Why is Rust effective?
Why is Rust effective?

! Using a strong type system
! Safety by default
Type systems
Why is C frustrating?
Imagine you are a construction worker, and your boss tells you to connect the gas pipe in the basement to the street's
gas main. You go downstairs, and find that there's a glitch; this house doesn't *have* a basement. Perhaps you decide to
do nothing, or perhaps you decide to whimsically interpret your instruction by attaching the gas main to some other
nearby fixture, perhaps the neighbor's air intake. Either way, suppose you report back to your boss that you're done.

KWABOOM! When the dust settles from the explosion, you'd be guilty of criminal negligence.

Yet this is exactly what happens in many computer languages. In C/C++, the programmer (boss) can write
"house"[-1] * 37. It's not clear what was intended, but clearly some mistake has been made. It would certainly be
possible for the language (the worker) to report it, but what does C/C++ do?

• It finds some non-intuitive interpretation of "house"[-1] (one which may vary each time the program runs!, and
    which can't be predicted by the programmer),
•   then it grabs a series of bits from some place dictated by the wacky interpretation,
•   it blithely assumes that these bits are meant to be a number (not even a character),
•   it multiplies that practically-random number by 37, and
•   then reports the result, all without any hint of a problem.              https://www.radford.edu/ibarland/Manifestoes/whyC++isBad.shtml
Why is C frustrating?


                typedef struct vector {
                    size_t length;
                    size_t capacity;
                    size_t elem_size;
                    void *data;
                } vector;
Why is C frustrating?
int prctl(int option, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
   Why is C frustrating?


                                                struct sockaddr {
                                                    unsigned short   sa_family;
                                     16 bytes       char             sa_data[14];
                                                };


                                                              struct sockaddr_in6 {
           struct sockaddr_in {
                                                                  sa_family_t     sin6_family;   /* AF_INET6 */
               short int            sin_family;
                                                                  in_port_t       sin6_port;     /* port number */
               unsigned short int   sin_port;
16 bytes       struct in_addr       sin_addr;
                                                   16 bytes       uint32_t        sin6_flowinfo; /* IPv6 flow information */
                                                                  struct in6_addr sin6_addr;     /* IPv6 address */
               unsigned char        sin_zero[8];
                                                                  uint32_t        sin6_scope_id; /* Scope ID (new in 2.4) */
           };
                                                              };
Why is C frustrating?
Why is C frustrating?

! C is designed and used by brilliant people. What is the reason for the madness?
! C is tightly coupled to the machine executing the code
  ○ Machines don’t have notions of vectors, generic types, or polymorphism
  ○ Prctl is the way it is because of how the syscall call/return mechanism passes
      arguments through registers, not because it’s convenient for anyone to think
      about in that way
  ○ C code is often the way it is because it maps well to how computers work
! Side note: When introduced, C was actually a big advancement in that it targeted
  an abstract machine model, so C programmers don’t need to think about the
  specifics of the processors they are running on
  ○ However, it is tightly coupled to that abstract machine model
Rust’s perspective

! By contrast, Rust is designed to match how programmers think
! Want a vector containing strings? Just create one and add the desired
  strings!
! No need to think about allocating memory, casting void* pointers
  appropriately, passing the correct number of bytes each element occupies, or
  freeing memory
Type systems

! Types are the unit of dialogue in a language
  ○ When you talk in a language, what do you talk about?
! A compiler uses types to figure out:
  ○ What are you trying to say?
  ○ Does what you’re saying make sense?
Type systems

! C’s type system is oriented around primitives, structs, and pointers
  ○ When you write "house"[-1] * 37, the compiler figures out what you’re
      saying in terms of pointers and verifies that it makes sense
! C has a very small language surface, which is nice
! However, because of the limited constructs it can express, you must do a lot of
  work to translate ideas into C code
! Similarly, when reading C code, it’s difficult to build a mental model of what the
  authors were thinking when writing the code
  ○ E.g. when reading a codebase, it may take a while to figure out where the
      authors intended for some memory to be freed
  ○ Consequently, the compiler has very little understanding of the intent of a
      programmer
Type systems

! Rust’s type system tries to encode high-level ideas into the language
  ○ When you write code, there is a notion of ownership in the code
  ○ When you have a vector, there is a notion of the type of elements in the vector
  ○ When you have a type, there is a notion of whether it’s safe to share values of
      that type between threads (Sync/Send)
! Because we express high-level ideas in the language, the compiler can understand
  what we’re trying to do, and can warn us when we do something dumb
! By the same token, other programmers can more easily understand what is going
  on from reading your code
! This is about much more than just memory safety! This is why Rust was designed
  with powerful macros: We can extend the language with new ideas that can be
  expressed and checked at compile time
Takeaways for systems design

! You may never design a programming language, but you will very likely need to design
  or implement an API
  ○ E.g. creating a software library, or implementing a service over HTTP
! Good API design is very hard and has a lot of overlap with good language design
! Design from the client’s perspective with the implementation in mind, not the other way
  around
  ○ If you expose a complex interface, every client will need to deal with that complexity
  ○ If you expose a simple interface with a complex implementation, it may be hard to
      build, but you can do it once and move on
  ○ It’s so tempting to build an API that directly maps to the implementation, since
      that’s what you understand as an implementor. But take extra time to consider what
      “types” a client thinks in terms of!
Safety by default
Safety by default

! Rust safety features are a core part of the language
! You can opt-out using unsafe, but it’s discouraged and sometimes more
  trouble than it’s worth
! C++ has many safety features, but they are opt-in
  ○ Worse, even the “safe” STL classes have unsafe parts that are easy to
      accidentally use
Takeaways for systems design

! Design systems that are harder to misuse than they are to use correctly
! As we saw in the information security lecture, sometimes safety by default
  isn’t good enough (e.g. if disabling safety features makes life significantly
  easier for a user)
Rust is not a panacea!
Rust is not a panacea!

! I think you’ve learned this from your assignments, but it’s worth stating
  explicitly

                                   Valid C programs


                                                           Programs with
                        Valid Rust programs
                                                           memory errors


                      Buggy Rust
                        program     Buggy programs


                                   Invalid Rust program
                                   with no memory errors
Rust is not a panacea!

! I think you’ve learned this from your assignments, but it’s worth stating
  explicitly
! Additionally, some Rust code uses unsafe. If you use libraries that have
  incorrect usage of unsafe, your code will also be susceptible to
  vulnerabilities
! We still have a ways to go in making the language fast and usable
Safety in C++
You still need to learn C/C++

! C and C++ suck, but in many cases, we don’t have a choice
! There is lots of existing code that must be supported
! Rewriting projects introduces bugs (and sometimes reintroduces old, long-
  fixed bugs)
  ○ I have never heard of a real-life project where this wasn’t the case
  ○ Mozilla’s experience rewriting Firefox CSS engine in Rust
! People are still writing in Fortran… There’s no way we’re ditching C/C++ any
  time in the near future
Applying Rust to C++

! In many ways, Rust codifies best practices that you should be doing in other
  languages anyways
! Writing good code may not be as natural as it is in Rust, but many of the
  same ideas can be applied
! There is a ton of material in the next few slides. We don’t expect you to
  understand it all; we just want you to know it exists so that you can look it up
  when you recognize a need to use it
Allocating/freeing memory

! The traditional (and error-prone) way to initialize objects is to have functions like
  vec_init that allocate memory and vec_destroy that free associated resources
! RAII is a horrible name for the practice of acquiring resources (e.g. allocating
  memory) in the constructor of an object and freeing the memory in the destructor
  ○ The destructor is called when the object goes out of scope
  ○ No memory leaks or double frees!
  ○ Most C++ STL classes are RAII (e.g. vector manages the memory allocations
     for you)
  ○ Applies to more than just memory (e.g. lock_guard releases the lock when it
     goes out of scope)
Ownership

! When RAII is used, we can talk about ownership similar to Rust. A variable “owns” the value inside
! The = operator copies by default
   ○ You may have encountered this in the form of unexpected performance hits
! You can use std::move() to indicate you would like to move instead of copying
   ○ E.g. string val2 = move(val1);
   ○ Note that the compiler will not complain if you subsequently use val1. Use linters like clang-tidy
      to catch mistakes like this
! You can “borrow” references to a value of type T by assigning to variables/parameters of type &T
   ○ Not as explicit as Rust about when references are being borrowed, but the same thing is
      happening
   ○ Beware: Unlike Rust, there is no borrow checker doing lifetime analysis, so dangling pointers are
      still a thing. 36.1% of Chrome high-severity security bugs (52% of memory-related security
      bugs) caused by use-after-free!
Smart pointers

! Similar to Rust, C++ objects are stack-allocated by default
! Heap allocation can be done with new and delete, but this is error-prone
! Smart pointers are wrapper objects that automatically manage memory allocations
  for you
! std::unique_ptr is like Box: single owner, ownership can be transferred (can also
  borrow references, as long as owner lives long enough)
  ○ unique_ptr<string> s = make_unique<string>("hello world");
      cout << *s << endl;
      unique_ptr<string> s2 = move(s);
      cout << *s2 << endl;
      (cplayground)
Smart pointers

! std::shared_ptr is like Rc: multiple owners (via reference counting)
  ○ shared_ptr<string> s = make_shared<string>("hello world");
      cout << *s << endl;
      shared_ptr<string> s2 = s; // makes a copy, inc refcount
      cout << *s2 << endl;
      (cplayground)
Arrays/vectors

! std::vector is like Vec (allocates a growable vector on the heap), except
  the [] operator does not do bounds checks! Use the .at(i) method to get
  an element with bounds checking
! std::array encapsulates a C array with its length
  ○ Never need to worry about remembering to pass the proper length
  ○ Can use the .at(i) method to do bounds checking
  ○ Automatically frees the array when it goes out of scope
! std::span is like a slice (provides a view into a segment of a vector or array)
Avoiding null dereferences

! C++17 introduced std::optional, which is like Option
  ○ An optional<T> can either be std::nullopt or a value of type T
  ○ Example: https://en.cppreference.com/w/cpp/utility/optional#Example
  ○ Use .value() to get the value inside an optional (an exception is thrown if the
      optional is empty)
  ○ Unfortunately, optional also defines the * and -> operators to get the value inside,
      which return uninitialized values if the optional is empty :-/
! C++20 introduces map, and_then, and or_else functions like ones you may have used in
  Rust
! Be aware that nullptr is widely used in C++ code, and optional is mostly used in places
  where nullptr doesn’t work well
  ○ Pretty good blog post from Microsoft here
Error handling

! There is no consensus on how to do error handling in C++
! Exceptions only work if all of your code is RAII
  ○ Imagine function A has a try/catch that calls function B, which calls function C, which
     calls some other functions
  ○ One of the functions called by function C throws an unexpected exception
  ○ Function A catches the exception, but function B is “skipped” and never has a chance
     to free the resources
  ○ In general, exceptions also complicate control flow
! There is a Result-like type being debated, but it hasn’t made it into the standard library yet
! A whole lot of code uses int return values to indicate errors. This has its own problems
  ○ So many bugs caused by forgetting to check the return value, or from doing it
     incorrectly
  ○ Pain in the butt to do everywhere
Error handling

! Google style guide forbids exceptions: https://google.github.io/styleguide/
  cppguide.html#Exceptions
! Mozilla also forbids exceptions in Firefox:
  ○ https://firefox-source-docs.mozilla.org/code-quality/coding-style/
     using_cxx_in_firefox_code.html
  ○ https://firefox-source-docs.mozilla.org/code-quality/coding-style/
     coding_style_cpp.html#error-handling (good read on error handling in general)
! Microsoft doesn’t have a public, general style guide, but their language reference
  encourages using exceptions: https://docs.microsoft.com/en-us/cpp/cpp/errors-
  and-exception-handling-modern-cpp?view=vs-2019
Multithreading

! Use RAII wrappers for synchronization primitives whenever possible (e.g.
  lock_guard)
! Use higher-level communication abstractions when applicable (e.g. channels)
Use code quality tools!

! These language features help a lot, but they don’t even come close to
  addressing C++’s safety issues
  ○ The language features only help if you use them
  ○ Trying to use these features in an existing codebase has the same
     problem that switching to Rust does: you still have a lot of legacy code
     using a lot of antipatterns
! Since C++ does not ensure safety by default, you should use tools to get
  better assurances about your code
! These tools typically fall into two categories: static analysis (done on the
  source code) and dynamic analysis (done on a running program)
Static analysis

! Limited in what it can say about a program (for fully general programs, you
  don’t really know what the program will do until you execute it)
  ○ Can’t really follow the control flow of a program at a high level
  ○ Often simply analyze code at a function level
  ○ Often define a set of rules for safe behavior. Code that violates those rules
     might not be unsafe, but the static analysis tools will give you errors
     anyways. (Better safe than sorry)
Built-in static analysis
! The compiler already does some amount of static analysis and can be configured to give you different
  warnings/errors. You can pass various -W flags to enable certain warnings
! -Wall does not enable all warnings!! It enables “all the warnings about constructions that some users
  consider questionable, and that are easy to avoid” (GCC manual)
    ○ 🙄
! -Wextra adds some extra warning flags (but not all of them)
    ○ 🙄
! It’s not uncommon to end up with compiler invocations like this: -Wall -Werror -Wextra -Wpedantic -
  Wvla -Wextra-semi -Wnull-dereference -Wswitch-enum -fvar-tracking-assignments -Wduplicated-
  cond -Wduplicated-branches -rdynamic -Wsuggest-override
! https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md#compilers
! https://kristerw.blogspot.com/2017/09/useful-gcc-warning-options-not-enabled.html
Linting

! A “linter” enforces code style rules
  ○ Bad style (e.g. deeeeeeply nested code) obscures logic and makes it
      much harder to spot bugs
  ○ Linters also commonly do some basic static analysis to spot obvious
      errors (e.g. calling unsafe functions like strcpy, or using a value after it
      has been moved out of a variable)
! clang-tidy is one of the most powerful and commonly used linters
Higher-level static analysis

! More powerful static analyzers attempt to build a graph of the flow of data in
  a program, in order to spot buffer overflows, null pointers, integer overflows,
  and other common errors
! Pretty good open source project: Cppcheck
! This is an area of active research!
  ○ E.g. symbolic execution can theoretically audit all control flow paths a
     program can take, but it’s currently too slow to be practical for large
     programs
Dynamic analysis

! Dynamic analysis involves inspecting the behavior of a running program
  ○ Not comprehensive: can only complain about behavior that it actually
     observes (if a program only does something bad 0.00001% of the time,
     dynamic analysis may not catch it)
  ○ However, not many false positives: observed problems are usually real
     problems
Sanitizers

! Sanitizers are LLVM compiler plugins that inject extra code to keep track of
  what your program is doing and record dangerous behavior
! AddressSanitizer (detects accesses to invalid addresses), LeakSanitizer
  (detects memory leaks), MemorySanitizer (detects use of uninitialized
  memory), ThreadSanitizer (detects data races and deadlocks), and more
! Example: ThreadSanitizer tracks accesses to data and locks. If two threads
  read/write without first acquiring a lock, ThreadSanitizer will log an error
! This is similar to what valgrind does, except the instrumentation is generated
  by the compiler instead of being injected just-in-time while the program is
  executing
Fuzzers

! Fuzzers are programs that repeatedly provide semi-random input to your
  program until it crashes
! AFL and libFuzzer are the two most common fuzzers
  ○ The former is very useful for end-to-end fuzzing programs that take input
     via stdin
  ○ The latter is built into LLVM and fuzzes individual functions. Faster than
     AFL and useful when the code in question doesn’t take input via stdin
Bonus: Test, test, test!

! Automated tests are absolutely critical to any large project
! This is true for any project in any language
! Any time there is a bug, add a test case to protect against regressions
Summary: Using C++

! Use safety features when you can
! Often, you may not be able to use safety features. Even when you do, it’s
  easy to screw up
! As a result, it’s important to set up a development environment with
  automated code quality tests
  ○ Not too hard to set up infrastructure that runs a linter, automated test
      suite, and sanitizer checks on each commit
! Side note: Automatic code checking is an active area of research! If you’re
  interested, we can connect you to people in the CS department that work on
  these sorts of things
Closing remarks
Closing remarks

! Thank you for taking this class! It has been such a pleasure having you, and
  we hope you’ve enjoyed it
! You all have come so far!


! Please come next Tuesday for our guest speaker — it should be a really
  interesting talk
```

---
