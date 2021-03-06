self: super:

{
  afew = super.afew.overrideAttrs(old: {
    postPatch = ''
      sed -i "s|'notmuch', 'new'|'test', '1'|g" afew/MailMover.py
    '';
  });

  aspellDicts = super.recurseIntoAttrs (super.callPackages ./aspell/dictionaries.nix {});

  sikulix = super.callPackage ./sikulix {};

  robotframework-sikulilibrary = super.callPackage ./sikulilibrary {
    pythonPackages = self.python3Packages;
  };

  findimagedupes = super.callPackage ./findimagedupes {};

  zest-releaser-python2 = (super.callPackage ./zest-releaser {
    pythonPackages = self.python2Packages;
  }).build."zest.releaser";

  zest-releaser-python3 = (super.callPackage ./zest-releaser {
    pythonPackages = self.python3Packages;
  }).build."zest.releaser";

  gmime = super.gmime.overrideAttrs(old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.gpgme.dev ];
  });

  jetbrains = (super.recurseIntoAttrs (super.callPackages ./jetbrains {
    jdk = self.oraclejdk8;
  }));

  pidgin-with-plugins = super.pidgin-with-plugins.override {
    plugins = [ self.pidginsipe ];
  };

  inkscape = let
    myPython2Env = self.python2.withPackages(ps: with ps; [
      numpy
      lxml
      (buildPythonPackage rec {
        name = "${pname}-${version}";
        pname = "scour";
        version = "0.36";
        src = super.fetchurl {
          url = "https://pypi.python.org/packages/1a/9a/7e9f7a40241c1d2659655a5f10ef3d9a84b18365c845f030825d709d59b1/scour-0.36.tar.gz";
          # url = "mirror://pypi/r/${pname}/${name}.tar.gz";
          sha256 = "0aizn6yk1nqqz0gqj70hkynf9zgqnab552aix4svy0wygcwlksjb";
        };
        propagatedBuildInputs = [
          six
        ];
      })
    ]);
  in super.inkscape.overrideAttrs(old: {
    postPatch = ''
      patchShebangs share/extensions
      patchShebangs fix-roff-punct
      # Python is used at run-time to execute scripts, e.g., those from
      # the "Effects" menu.
      substituteInPlace src/extension/implementation/script.cpp \
        --replace '"python-interpreter", "python"' '"python-interpreter", "${myPython2Env}/bin/python"'
    '';
    buildInputs = old.buildInputs ++ [ myPython2Env ];
  });
}
