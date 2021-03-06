require 'formula'

class DocbookSlides < Formula
  homepage 'http://docbook.sourceforge.net/'
  url 'http://sourceforge.net/projects/docbook/files/slides/3.4.0/docbook-slides-3.4.0.tar.bz2'
  sha256 "0aee34fe68ba9b45e8a70ef43ff2b85878cd8f374c646fe8d8bcd4ad0db3400e"

  depends_on 'docbook'

  def install
    prefix.install %w[AUTHORS
      BUGS
      COPYING
      INSTALL
      NEWS
      README
      RELEASE-NOTES.html
      RELEASE-NOTES.txt
      RELEASE-NOTES.xml
      TODO
      VERSION
      browser
      catalog
      catalog.xml
      doc
      graphics
      install.sh
      locatingrules.xml
      schema
      xsl]
    catalog = prefix/'catalog.xml'
    system "xmlcatalog", "--noout", "--del",
                         "file://#{catalog}", "#{etc}/xml/catalog"
    system "xmlcatalog", "--noout", "--add", "nextCatalog",
                         "", "file://#{catalog}", "#{etc}/xml/catalog"
  end
end
