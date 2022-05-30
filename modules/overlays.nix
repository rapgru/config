[
  (final: prev: {
    
    #sf-mono-liga-bin = pkgs.callPackage ./pkgs/sf-mono-liga-bin { };
    ckubectl =
      let mkKubectl = { version, sha256 }: final.stdenv.mkDerivation rec {
        inherit version;
        pname = "kubectl";

        src = final.fetchurl {
          url = "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl";
          inherit sha256;
        };

        dontUnpack = true;

        installPhase = ''
          install -Dm755 $src $out/bin/kubectl
        '';
      };
    in
    {
      "v1.17.17" = mkKubectl { version = "v1.17.17"; sha256 = "sha256-gyn6yUxmv3pHW2MJcqjAsDa6sfKKVYQRXo3SZIPeg0k="; }; 
    };

    chelm =
      let mkHelm = { version, sha256 }: final.stdenv.mkDerivation rec {
        inherit version;
        pname = "helm";

        src = final.fetchurl {
          url = "https://get.helm.sh/helm-${version}-linux-amd64.tar.gz";
          inherit sha256;
        };

        installPhase = ''
          install -Dm755 helm $out/bin/helm
        '';
      };
    in
    {
      "v2.16.6" = mkHelm { version = "v2.16.6"; sha256 = "sha256-44/qWbw4L+sPgDItWCJmRl12q3Ks3AB5wjUMw/2KP0w="; }; 
    };
  })
]