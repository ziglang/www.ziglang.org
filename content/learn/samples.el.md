---
title: "Παραδείγματα κώδικα"
mobile_menu_title: "Παραδείγματα"
toc: true
---

## Ανίχνευση διαρροής μνήμης
Χρησιμοποιώντας το `std.heap.GeneralPurposeAllocator` μπορείτε να εντοπίσετε διπλές απελευθερώσεις μνήμης και διαρροές μνήμης.

{{< zigdoctest "assets/zig-code/samples/1-memory-leak.zig" >}}


## Διαλειτουργικότητα με C
Παράδειγμα εισαγωγής ενός αρχείου κεφαλίδας C (.h) και σύνδεσης (link) με τις βιβλιοθήκες libc και raylib.

{{< zigdoctest "assets/zig-code/samples/2-c-interop.zig" >}}


## Ζιγκ Ζαγκ
Η Zig είναι *βελτιστοποιημένη* για συνεντεύξεις κώδικα (όχι στ' αλήθεια).

{{< zigdoctest "assets/zig-code/samples/3-ziggzagg.zig" >}}


## Γενικοί Τύποι
Στη Zig οι τύποι είναι τιμές κατά την μεταγλώττιση, χρησιμοποιούμε συναρτήσεις που επιστρέφουν έναν τύπο για να υλοποιήσουμε γενικούς αλγόριθμους δομές δεδομένων. Σε αυτό το παράδειγμα υλοποιούμε μια απλή γενική ουρά και δοκιμάζουμε τη συμπεριφορά της.

{{< zigdoctest "assets/zig-code/samples/4-generic-type.zig" >}}


## Χρησιμοποιώντας το cURL από τη Zig

{{< zigdoctest "assets/zig-code/samples/5-curl.zig" >}}
