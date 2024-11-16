let
  vps =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1maMdLslN32frKSs489iz+9vMmnox7Sxop5LSJjUU/";
  personal_projects =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFNSePweS1I3ucce46M50qXbr0330RUOMG9ZiGchvxN";

  all = [ vps personal_projects ];
in {
  "secrets/secret1.age".publicKeys = all;
  "secrets/test-github-runner-token.age".publicKeys = all;
}
