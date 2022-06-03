[
  (final: prev: let
    buildFromVersionList = mkPkg: versionList:
      builtins.listToAttrs (builtins.map (pkg: { name = pkg.version; value = mkPkg pkg;}) versionList);
  in
  {
    
    #sf-mono-liga-bin = pkgs.callPackage ./pkgs/sf-mono-liga-bin { };
    ckubectl =
      let mkKubectl = { version, sha256, binName ? "kubectl" }: final.stdenv.mkDerivation rec {
        inherit version;
        pname = "kubectl";

        src = final.fetchurl {
          url = "https://dl.k8s.io/release/${version}/bin/linux/amd64/kubectl";
          inherit sha256;
        };

        dontUnpack = true;

        installPhase = ''
          install -Dm755 $src $out/bin/${binName}
        '';
      };

      kubectls = [
        { version = "v1.17.17"; sha256 = "sha256-gyn6yUxmv3pHW2MJcqjAsDa6sfKKVYQRXo3SZIPeg0k="; }
      ];
    in
      buildFromVersionList mkKubectl kubectls;

    kubectl17 = final.ckubectl."v1.17.17";

    chelm =
      let mkHelm = { version, sha256, binName ? "helm" }: final.stdenv.mkDerivation rec {
        inherit version;
        pname = "helm";

        src = final.fetchurl {
          url = "https://get.helm.sh/helm-${version}-linux-amd64.tar.gz";
          inherit sha256;
        };

        installPhase = ''
          install -Dm755 helm $out/bin/${binName}
        '';
      };

      helms = [
        { version = "v2.16.6"; sha256 = "sha256-44/qWbw4L+sPgDItWCJmRl12q3Ks3AB5wjUMw/2KP0w="; binName = "helm2"; }
      ];
    in
      buildFromVersionList mkHelm helms;

    helm2 = final.chelm."v2.16.6";
    helm3 = prev.kubernetes-helm;

    ctanka =
      let mkTanka = { version, sha256 }: final.stdenv.mkDerivation rec {
        inherit version;
        pname = "tanka";

        src = final.fetchurl {
          url = "https://github.com/grafana/tanka/releases/download/${version}/tk-linux-amd64";
          inherit sha256;
        };

        dontUnpack = true;

        installPhase = ''
          install -Dm755 $src $out/bin/tk
        '';
      };
      tankas = [ { version = "v0.21.0"; sha256 = "sha256-zWCgBfhP2Zdj8m0H1MtibnWFpigAqulyNNgYcSnu0ew="; } ];
    in
      buildFromVersionList mkTanka tankas;
  })
]