# check-mirrors

This is a small utility which checks the functionality of all listed community mirrors. It does this
by fetching a subset of available tarballs and signatures from each mirror, and checking that the
returned files exactly match the corresponding files served by ziglang.org.

This check is automatically run once per day by the 'check-mirrors' workflow. It also runs when a PR
modifies the mirror list.
