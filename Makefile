# 使い方
# 	html(単一、複数)、infoを作成する場合は、make
# 	全部(pdf、txt、tarを含む)を作成する場合は、make && make pdf && make txt && make tar

# 必要なもの
#
# po4a(https://po4a.alioth.debian.org/index.php.ja)が必要です
# 理由:	翻訳前のtexiとpoファイルから翻訳済みのtexiを生成するため
#
# Texinfo(https://www.gnu.org/software/texinfo/)が必要です
# 理由:	        texiファイルからhtml、infoを生成するため
# コンパイル:	make
#
# tar(https://www.gnu.org/software/tar/)が必要です(オプション)
# 理由:		texiファイルをアーカイブするため
# コンパイル:	make tar
#
# TeX Live(http://www.tug.org/texlive/)が必要です(オプション)
# 理由:		texiファイルから日本語PDFを作成するため
# コンパイル:	make pdf
# 注意:		使用したTeX LiveはTeX Live 2020です。

.PHONY: all single-html multi-html info
.PHONY: txt pdf tar epub texinfo-js

# デフォルトは単一html、分割html、info
all: single-html multi-html info

# 単一html用のターゲット
single-html: emacs-ja.html

# 分割html用のターゲット
# html/*.htmlが生成されます
multi-html: html/index.html

# info用のターゲット
info: emacs-ja.info

# ASCII text用のターゲット
txt: emacs-ja.txt

# pdf用のターゲット(オプション)
pdf: emacs-ja.pdf emacs-xtra-ja.pdf

# tar.gz用のターゲット(オプション)
tar: emacs-ja.texis.tar.gz

# EPUB用のターゲット(オプション、experimental)
epub: emacs-ja.epub

# texinfo-js用のターゲット(オプション、experimental)
texinfo-js: emacs-ja-html/index.html


.PHONY: clean

clean:
	rm -f *.texi
	rm -f *.html
	rm -fR html/
	rm -f *.info
	rm -f *.pdf
	rm -f *.txt
	rm -f *.tar.gz
	rm -fR emacs-ja.texis/
	rm -fR *.epub *.docbook mimetype META-INF OEBPS
	rm -fR emacs-ja-html/


TEXIS := \
abbrevs-ja.texi \
ack.texi \
anti-ja.texi \
arevert-xtra-ja.texi \
basic-ja.texi \
buffers-ja.texi \
building-ja.texi \
cal-xtra-ja.texi \
calendar-ja.texi \
cmdargs-ja.texi \
commands-ja.texi \
custom-ja.texi \
dired-ja.texi \
dired-xtra-ja.texi \
display-ja.texi \
doclicense.texi \
docstyle.texi \
emacs-ja.texi \
emacs-xtra-ja.texi \
emacsver.texi \
emerge-xtra-ja.texi \
entering-ja.texi \
files-ja.texi \
fixit-ja.texi \
fortran-xtra-ja.texi \
frames-ja.texi \
glossary.texi \
gnu.texi \
gpl.texi \
help-ja.texi \
indent-ja.texi \
killing-ja.texi \
kmacro-ja.texi \
m-x-ja.texi \
macos-ja.texi \
maintaining-ja.texi \
mark-ja.texi \
mini-ja.texi \
misc-ja.texi \
modes-ja.texi \
msdos-ja.texi \
msdos-xtra-ja.texi \
mule-ja.texi \
package-ja.texi \
picture-xtra-ja.texi \
programs-ja.texi \
regs-ja.texi \
rmail-ja.texi \
screen-ja.texi \
search-ja.texi \
sending-ja.texi \
text-ja.texi \
trouble-ja.texi \
vc-xtra-ja.texi \
vc1-xtra-ja.texi \
windows-ja.texi \
xresources-ja.texi

%-ja.texi: %.texi.po original_texis/%.texi
	po4a-translate -f texinfo -k 0 -M utf8 -m $(word 2,$^) -p $< -l $@
	./replace.sh $@

%.texi: original_texis/%.texi
	cp -pf $< $@
	./replace.sh $@

emacs-ja.html: $(TEXIS)
	texi2any --set-customization-variable TEXI2HTML=1 emacs-ja.texi

html/index.html: $(TEXIS)
	makeinfo -o html/ --html emacs-ja.texi

emacs-ja.info: $(TEXIS)
	makeinfo --no-split -o emacs-ja.info emacs-ja.texi

emacs-ja.pdf: $(TEXIS)
	PDFTEX=luatex texi2pdf -c -I ./misc emacs-ja.texi

emacs-xtra-ja.pdf: $(TEXIS)
	PDFTEX=luatex texi2pdf -c -I ./misc emacs-xtra-ja.texi

emacs-ja.txt: $(TEXIS)
	texi2any --plaintext emacs-ja.texi > emacs-ja.txt

emacs-ja.texis.tar.gz: $(TEXIS)
	if [ ! -d emacs-ja.texis ]; \
	then \
		mkdir emacs-ja.texis/; \
	fi

	cp -fp *.texi emacs-ja.texis
	tar cvfz ./emacs-ja.texis.tar.gz ./emacs-ja.texis

emacs-ja.epub: $(TEXIS)
	makeinfo --docbook emacs-ja.texi -o emacs-ja.docbook
	xsltproc http://docbook.sourceforge.net/release/xsl/current/epub/docbook.xsl emacs-ja.docbook
	echo "application/epub+zip" > mimetype
	zip -0Xq emacs-ja.epub mimetype
	zip -Xr9D emacs-ja.epub META-INF OEBPS

emacs-ja-html/index.html: $(TEXIS)
	texinfo-js emacs-ja.texi
