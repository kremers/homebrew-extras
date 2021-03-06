require 'formula'

class Qscintilla2Qt5 < Formula
  homepage 'http://www.riverbankcomputing.co.uk/software/qscintilla/intro'
  url "https://downloads.sf.net/project/pyqt/QScintilla2/QScintilla-2.8.4/QScintilla-gpl-2.8.4.tar.gz"
  sha256 "9b7b2d7440cc39736bbe937b853506b3bd218af3b79095d4f710cccb0fabe80f"

  bottle do
    root_url "https://github.com/glehmann/homebrew-extras-bottle/blob/master/qscintilla2-qt5-2.8.4.mavericks.bottle.tar.gz?raw=true"
    sha256 "852b60acb291bc078bfb98868cbd5be7a2914b175575286a76ce9abbcfc35b9b" => :mavericks
  end

  depends_on :python => :optional
  depends_on :python3 => :optional

  keg_only "Qt 5 conflicts Qt 4 (which is currently much more widely used)."

  option "without-plugin", "Skip building the Qt Designer plugin"

  if build.with? "python3"
    depends_on "pyqt5" => "with-python3"
  elsif build.with? "python"
    depends_on "pyqt5"
  else
    depends_on "qt5"
  end

  def install
    args = %W[-config release QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}]

    cd 'Qt4Qt5' do
      inreplace 'qscintilla.pro' do |s|
        s.gsub! '$$[QT_INSTALL_LIBS]', lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
        s.gsub! "$$[QT_INSTALL_TRANSLATIONS]", "#{prefix}/trans"
        s.gsub! "$$[QT_INSTALL_DATA]", "#{prefix}/data"
      end

      inreplace "features/qscintilla2.prf" do |s|
        s.gsub! '$$[QT_INSTALL_LIBS]', lib
        s.gsub! "$$[QT_INSTALL_HEADERS]", include
      end

      system "qmake", "qscintilla.pro", *args
      system "make"
      system "make", "install"
    end

    # Add qscintilla2 features search path, since it is not installed in Qt keg's mkspecs/features/
    ENV["QMAKEFEATURES"] = "#{prefix}/data/mkspecs/features"

    if build.with? "python" or build.with? "python3"
      cd 'Python' do
        Language::Python.each_python(build) do |python, version|
          (share/"sip").mkpath
          system python, "configure.py", "-o", lib, "-n", include,
                           "--apidir=#{prefix}/qsci",
                           "--destdir=#{lib}/python#{version}/site-packages/PyQt5",
                           "--qsci-sipdir=#{share}/sip",
                           "--pyqt-sipdir=#{HOMEBREW_PREFIX}/share/sip",
                           "--spec=#{spec}"
          system 'make'
          system 'make', 'install'
          system "make", "clean"
        end
      end
    end

    if build.with? "plugin"
      mkpath prefix/"plugins/designer"
      cd "designer-Qt4Qt5" do
        inreplace "designer.pro" do |s|
          s.sub! "$$[QT_INSTALL_PLUGINS]", "#{prefix}/plugins"
          s.sub! "$$[QT_INSTALL_LIBS]", "#{lib}"
        end
        system "qmake", "designer.pro", *args
        system "make"
        system "make", "install"
      end
      # symlink Qt Designer plugin (note: not removed on qscintilla2 formula uninstall)
      ln_sf prefix/"plugins/designer/libqscintillaplugin.dylib",
            Formula["qt5"].opt_prefix/"plugins/designer/"
    end
  end

  test do
    Pathname("test.py").write <<-EOS.undent
      import PyQt4.Qsci
      assert("QsciLexer" in dir(PyQt4.Qsci))
    EOS
    Language::Python.each_python(build) do |python, version|
      system python, "test.py"
    end
  end
end
