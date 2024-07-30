---
title: "Αρχική"
mobile_menu_title: "Αρχική"
---
{{< slogan get_started="GET STARTED" docs="Documentation" notes="Changes" lang="el" >}}
Η Zig είναι μία γλώσσα προγραμματισμού γενικής χρήσης κι εργαλεία για τη συντήρηση **στιβαρού**, **βέλτιστου** κι **επαναχρησιμοποιούμενου** λογισμικού.
{{< /slogan >}}

{{< flexrow class="container" style="padding: 20px 0; justify-content: space-between;" >}}
{{% div class="features" %}}

# ⚡ Μια απλή γλώσσα
Εστιάζει στον εντοπισμό των σφαλμάτων της εφαρμογής σας, αντί στον εντοπισμό σφαλμάτων στις γνώσεις της γλώσσας προγραμματισμού.

- Χωρίς κρυφές ροές ελέγχου.
- Χωρίς κρυφές δεσμεύσεις μνήμης.
- Χωρίς προεπεξεργαστή, χωρίς μακροεντολές. 

# ⚡ Κατά το χρόνο μεταγλώττισης (Comptime)
Μια νέα προσέγγιση στον μεταπρογραμματισμό βασισμένη στην εκτέλεση κώδικα κατά την μεταγλώττιση και την οκνηρή αποτίμηση.

- Κλήση οποιασδήποτε συνάρτησης κατά τον χρόνο μεταγλώττισης.
- Χειρισμός τύπων ως τιμές χωρίς καμία επιβάρυνση κατά την εκτέλεση.
- Προσομοίωση της αρχιτεκτονικής προορισμού κατά την εκτέλεση σε χρόνο μεταγλώττισης.

# ⚡ Συντήρηση με Zig
Βελτιώστε σταδιακά τον κώδικα σε C/C++/Zig.

- Χρησιμοποιήστε τη Zig ως ένα μεταγλωττιστή C/C++ δίχως εξαρτήσεις, που υποστηρίζει μεταγλώττιση για άλλες πλατφόρμες προορισμού (cross-compilation).
- Αξιοποιήστε το `zig build` για ένα συνεπές περιβάλλον ανάπτυξης σε κάθε πλατφόρμα.
- Προσθέστε τη Zig σε έργα C/C++. Η βελτιστοποίηση κατά τον χρόνο σύνδεσης (LTO) είναι διαγλωσσική κι ενεργοποιημένη.

{{% flexrow style="justify-content:center;" %}}
{{% div %}}
<h1>
    <a href="learn/overview/" class="button" style="display: inline;">Επισκόπηση σε βάθος</a>
</h1>
{{% /div %}}
{{% div  style="margin-left: 5px;" %}}
<h1>
    <a href="learn/samples/" class="button" style="display: inline;">Περισσότερα παραδείγματα κώδικα</a>
</h1>
{{% /div %}}
{{% /flexrow %}}
{{% /div %}}
{{< div class="codesample" >}}

{{% zigdoctest "assets/zig-code/index.zig" %}}

{{< /div >}}
{{< /flexrow >}}


{{% div class="alt-background" %}}
{{% div class="container"  style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Community" %}}

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div style="width:25%" %}}
<img src="/ziggy.svg" style="max-height: 200px">
{{% /div %}}

{{% div class="community-message" %}}
# Η κοινότητα της Zig είναι αποκεντρωμένη
Όλες κι όλοι έχουν την ελευθερία να ξεκινήσουν και να συντηρήσουν τον δικό τους κοινοτικό χώρο.
Δεν υπάρχει η έννοια «επίσημο» ή «ανεπίσημο», ωστόσο κάθε κοινοτικός χώρος έχει τους δικούς του κανόνες και συντονίστριες ή συντονιστές.

<div style="">
<h1>
	<a href="https://github.com/ziglang/zig/wiki/Community" class="button" style="display: inline;">Όλες οι Κοινότητες</a>
</h1>
</div>
{{% /div %}}
{{< /flexrow >}}
<div style="height: 50px;"></div>

{{< flexrow class="container" style="justify-content: center;" >}}
{{% div class="main-development-message" %}}
# Κύρια ανάπτυξη
Το αποθετήριο της Zig βρίσκεται στη διεύθυνση [https://github.com/ziglang/zig](https://github.com/ziglang/zig), όπου φιλοξενούμε επίσης ζητήματα και συζητάμε προτάσεις.
Όλοι οι συντελεστές αναμένεται να ακολουθούν τον [Κώδικα Δεοντολογίας](https://github.com/ziglang/zig/blob/master/.github/CODE_OF_CONDUCT.md) της Zig.
{{% /div %}}
{{% div style="width:40%" %}}
<img src="/zero.svg" style="max-height: 200px">
{{% /div %}}
{{< /flexrow >}}
{{% /div %}}
{{% /div %}}


{{% div class="container" style="display:flex;flex-direction:column;justify-content:center;text-align:center; padding: 20px 0;" title="Zig Software Foundation" %}}
## Ο ZSF είναι μη κερδοσκοπικός οργανισμός 501(c)(3).

O οργανισμός ZSF (Zig Software Foundation) είναι μια μη κερδοσκοπική εταιρεία που ιδρύθηκε το 2020 από τον Andrew Kelley, τον δημιουργό της Zig, με στόχο την υποστήριξη της ανάπτυξης της γλώσσας. Επί του παρόντος, ο ZSF είναι σε θέση να προσφέρει αμειβόμενη εργασία σε ανταγωνιστικές τιμές σε μικρό αριθμό βασικών συντελεστών. Ελπίζουμε να μπορέσουμε να επεκτείνουμε αυτήν την προσφορά σε περισσότερους βασικούς συντελεστές στο μέλλον.

Ο οργανισμός ZSF συντηρείται από δωρεές.

<h1>
	<a href="zsf/" class="button" style="display:inline;">Learn More</a>
</h1>
{{% /div %}}


{{< div class="alt-background" style="padding: 20px 0;">}}
{{% div class="container" title="Sponsors" %}}
# Εταιρικοί Χορηγοί
Οι ακόλουθες εταιρείες παρέχουν άμεση οικονομική υποστήριξη στον οργανισμό ZSF.

{{% monetary-sponsor-logos %}}


# Χορηγοί GitHub
Ευχαριστούμε όσες κι όσους είναι [χορηγοί της Zig](zsf/), το έργο είναι υπόλογο στην κοινότητα ανοιχτού κώδικα και όχι στους εταιρικούς μετόχους. Συγκεκριμένα, οι παρακάτω χορηγούν στην Zig 200 δολάρια το μήνα ή περισσότερο:

{{< ghsponsors >}}

Αυτή η ενότητα ανανεώνεται στην αρχή κάθε μήνα.
{{% /div %}}
{{< /div >}}
